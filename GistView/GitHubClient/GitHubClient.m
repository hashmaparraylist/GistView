//
//  GitHubClient.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "GitHubClient.h"
#import "GitHubUser.h"
#import "ServerDefine.h"

@interface GitHubClient ()
@property (nonatomic, strong, readwrite) NSString *token;
@property (nonatomic, strong, readwrite) GitHubUser *authenticatedUser;
@end

@implementation GitHubClient

#pragma mark - Lifecycle

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static GitHubClient *singletonInstance;
    dispatch_once(&onceToken, ^{
        singletonInstance = [[self alloc] initSelf];
    });
    
    return singletonInstance;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"..." userInfo:nil];
}

- (instancetype)initSelf {
    self = [super init];
    return self;
}

#pragma mark - Custom Accessors

- (BOOL) isAuthenticated {
    if (self.token.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (GitHubUser *)authenticatedUser {
    if (!self.isAuthenticated) {
        return nil;
    }
    
    if (_authenticatedUser == nil) {
        // TODO get authenticated user
    }
    
    return _authenticatedUser;
}

# pragma mark - Public

- (void) authorize {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    
    NSCharacterSet *slashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSString *baseURLString = [BASE_WEB_URL stringByTrimmingCharactersInSet:slashSet];
    
    NSString *urlString = [[NSString alloc] initWithFormat: AUTHORIZE_API, baseURLString, CLIENT_ID, @"gist", uuidString];
    NSURL *webUrl = [NSURL URLWithString:urlString];
    
    if(![self openURL:webUrl]) {
        // Error Handle
    }
}

- (void)completeAuthorizeWithCallbackURL:(NSURL *)callbackURL success:(void (^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    NSString *queryString = callbackURL.query;

    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    
    NSCharacterSet *slashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSString *baseURLString = [BASE_WEB_URL stringByTrimmingCharactersInSet:slashSet];
    NSString *urlString = [[NSString alloc] initWithFormat: ACCESS_TOKEN_API, baseURLString];
    
    NSDictionary *parameters = @{@"client_id" : CLIENT_ID, @"client_secret" : CLIENT_SECRET, @"code1" : queryStringDictionary[@"code"]};

    [self postApiWithURL:urlString parameters:parameters needToken:NO success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = (NSDictionary *)responseObject;
        self.token = jsonObject[@"access_token"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}



# pragma mark - Private

- (void)postApiWithURL:(NSString *)apiURL
            parameters:(NSDictionary *)parameters
             needToken:(BOOL)isNeedToken
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSLog(@"POST => [%@]", apiURL);
    AFHTTPRequestOperationManager *manager = [self makeOperationManagerNeedToken:YES];
    [manager POST:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS => Response[%@]", responseObject);
        if ([self isResponseError:responseObject]) {
            NSError *error = [[NSError alloc]initWithDomain:NSOSStatusErrorDomain code:API_NSERROR_CODE userInfo:responseObject];
            failure(operation, error);
            return;
        }
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST Failure => STATUS CODE:%ld, Error: %@", (long)operation.response.statusCode, error);
        failure(operation, error);
    }];
}

- (void)getApiWithURL:(NSString *)apiURL
           parameters:(NSDictionary *)parameters
            needToken:(BOOL)isNeedToken
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSLog(@"GET => [%@]", apiURL);
    AFHTTPRequestOperationManager *manager = [self makeOperationManagerNeedToken:YES];
    [manager GET:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS => Response[%@]", responseObject);
        if ([self isResponseError:responseObject]) {
            NSError *error = [[NSError alloc]initWithDomain:NSOSStatusErrorDomain code:API_NSERROR_CODE userInfo:responseObject];
            failure(operation, error);
            return;
        }
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST Failure => STATUS CODE:%ld, Error: %@", (long)operation.response.statusCode, error);
        failure(operation, error);
    }];
}

- (AFHTTPRequestOperationManager *)makeOperationManagerNeedToken: (BOOL)isNeedToken {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (isNeedToken) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"token %@", self.token] forHTTPHeaderField:@"Authorization"];
    }
    return manager;
}

- (BOOL) isResponseError:(NSDictionary *)response {
    if (response[@"error"] != nil) {
        return YES;
    }
    
    return NO;
}

- (BOOL)openURL:(NSURL *)URL {
    NSLog(@"open url=%@", URL);
    NSParameterAssert(URL != nil);
    if ([UIApplication.sharedApplication canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
        return YES;
    } else {
        return NO;
    }
}

@end
