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
    NSString *baseURLString = [GithubBaseWebURL stringByTrimmingCharactersInSet:slashSet];
    
    NSString *urlString = [[NSString alloc] initWithFormat: GithubApiAuthorize, baseURLString, GithubClientID, @"gist", uuidString];
    NSURL *webUrl = [NSURL URLWithString:urlString];
    
    if(![self openURL:webUrl]) {
        // Error Handle
        NSError *error = [NSError errorWithDomain:GithubClientErrorDomain
                                             code:GithubClientErrorOpeningBrowserFailed
                                         userInfo:@{
                                                    @"code" : @(GithubClientErrorOpeningBrowserFailed),
                                                    @"message" : @"无法打开浏览器，请确认你是否设置了默认的浏览器"
                                                    }];
        [[NSNotificationCenter defaultCenter] postNotificationName:GithubAuthenticatedNotifiactionFailure object:error];
    }
}

- (void)completeAuthorizeWithCallbackURL:(NSURL *)callbackURL {
    
    // 从callback url中取得temporary code
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
    NSString *baseURLString = [GithubBaseWebURL stringByTrimmingCharactersInSet:slashSet];
    NSString *urlString = [[NSString alloc] initWithFormat: GithubApiAccessToken, baseURLString];
    
    NSDictionary *parameters = @{@"client_id" : GithubClientID, @"client_secret" : GithubClientSecret, @"code1" : queryStringDictionary[@"code"]};

    [self postApiWithURL:urlString parameters:parameters needToken:NO success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = (NSDictionary *)responseObject;
        // temporary code 过期
        if (jsonObject[@"error"] != nil) {
            NSError *error = [NSError errorWithDomain:GithubClientErrorDomain
                                                 code:GithubClientErrorAuthenticationFailed
                                             userInfo:@{
                                                        @"code" : @(GithubClientErrorAuthenticationFailed),
                                                        @"message" : jsonObject[@"error_description"]
                                                        }];
            [[NSNotificationCenter defaultCenter] postNotificationName:GithubAuthenticatedNotifiactionFailure object:error];
        }
        self.token = jsonObject[@"access_token"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GithubAuthenticatedNotifiactionFailure object:error];
    }];
}

# pragma mark - Private

// 通过POST方法请求API
- (void)postApiWithURL:(NSString *)apiURL parameters:(NSDictionary *)parameters needToken:(BOOL)isNeedToken
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSLog(@"POST => [%@]", apiURL);
    AFHTTPRequestOperationManager *manager = [self makeOperationManagerNeedToken:YES];
    [manager POST:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS => Response[%@]", responseObject);
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST Failure => STATUS CODE:%ld, Error: %@", (long)operation.response.statusCode, error);
        NSError *errorInfo = [self errorFromRequestOperation:operation];
        failure(operation, errorInfo);
    }];
}

// 通过GET方法请求API
- (void)getApiWithURL:(NSString *)apiURL parameters:(NSDictionary *)parameters needToken:(BOOL)isNeedToken
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSLog(@"GET => [%@]", apiURL);
    AFHTTPRequestOperationManager *manager = [self makeOperationManagerNeedToken:YES];
    [manager GET:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS => Response[%@]", responseObject);
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST Failure => STATUS CODE:%ld, Error: %@", (long)operation.response.statusCode, error);
        NSError *errorInfo = [self errorFromRequestOperation:operation];
        failure(operation, errorInfo);
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

// 通过系统浏览器打开URL
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

// 获取API调用的错误信息
- (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation {

    NSInteger HTTPCode = operation.response.statusCode;
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    NSInteger errorCode = GithubClientErrorConnectionFailed;
    NSString *errorMessage = [self errorUserInfoFromRequestOperation:operation];
    switch (HTTPCode) {
        case 401:
            errorCode = GithubClientErrorAuthenticationFailed;
            break;
        case 400:
            errorCode = GithubClientErrorBadRequest;
            break;
        case 403:
            errorCode = GithubClientErrorRequestForbidden;
            break;
        case 422:
            errorCode = GithubClientErrorServiceRequestFailed;
            break;
        default:
            if ([operation.error.domain isEqual:NSURLErrorDomain]) {
                switch (operation.error.code) {
                    case NSURLErrorSecureConnectionFailed:
                    case NSURLErrorServerCertificateHasBadDate:
                    case NSURLErrorServerCertificateHasUnknownRoot:
                    case NSURLErrorServerCertificateUntrusted:
                    case NSURLErrorServerCertificateNotYetValid:
                    case NSURLErrorClientCertificateRejected:
                    case NSURLErrorClientCertificateRequired:
                        errorCode = GithubClientErrorSecureConnectionFailed;
                        break;
                }
            }
            break;
    }
    
    errorInfo[@"code"] = @(errorCode);
    errorInfo[@"message"] = errorMessage;
    
    return [[NSError alloc]initWithDomain:GithubClientErrorDomain code:errorCode userInfo:errorInfo];
}

// 从response中获取错误信息
-(NSString *)errorUserInfoFromRequestOperation:(AFHTTPRequestOperation *)operation {
    NSParameterAssert(operation != nil);
    
    NSDictionary *responseDictionary = nil;
  
    id JSON = [operation responseObject];
    if ([JSON isKindOfClass:NSDictionary.class]) {
        responseDictionary = JSON;
    } else {
        NSLog(@"Unexpected JSON for error response: %@", JSON);
    }
    
    
    NSString *message = responseDictionary[@"message"];
    
    NSArray *errorDictionaries = responseDictionary[@"errors"];
    NSString *errorMesage;
    if ([errorDictionaries isKindOfClass:NSArray.class]) {
        for (NSDictionary *errorDictionary in errorDictionaries) {
            NSString *error = errorDictionary[@"message"];
            errorMesage = [NSString stringWithFormat:@"%@:\n\n%@", errorMesage, error];
        }
    }
    
    if (message != nil) {
        return message;
    }
    if (errorMesage != nil) {
       return errorMesage;
    }
    
    return @"";
}


@end
