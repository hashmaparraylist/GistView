//
//  GitHubClient.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "GitHubClient.h"
#import "ServerDefine.h"

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

- (void)completeAuthorizeWithCallbackURL:(NSURL *)callbackURL {
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
    
    NSDictionary *parameters = @{@"client_id" : CLIENT_ID, @"client_secret" : CLIENT_SECRET, @"code" : queryStringDictionary[@"code"]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Success
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Error
        NSLog(@"Error: %@", error);
    }];
    
    
}

# pragma mark - Private

- (BOOL) openURL:(NSURL *)URL {
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
