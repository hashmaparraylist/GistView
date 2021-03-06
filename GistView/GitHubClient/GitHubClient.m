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
#import "Gist.h"
#import "Keys.h"

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
    
    // load token from data file
//    NSString *path = [self authorizeFilePath];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//        self.token = [unarchiver decodeObjectForKey:GitHubAuthorizeContentKeyToken];
//        [unarchiver finishDecoding];
//    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:GitHubAuthorizeContentKeyToken];
    if (token) {
        self.token = token;
    }
    
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
        AFHTTPRequestOperation *operation = [self syncAuthenticatedUserInfo:nil failure:nil];
        [operation waitUntilFinished];
    }
    return _authenticatedUser;
}

# pragma mark - Public

- (void) authorize {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    
    NSCharacterSet *slashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSString *baseURLString = [GitHubURLBaseWeb stringByTrimmingCharactersInSet:slashSet];
    
    NSString *urlString = [[NSString alloc] initWithFormat: GitHubApiAuthorize, baseURLString, GitHubClientID, @"gist", uuidString];
    NSURL *webUrl = [NSURL URLWithString:urlString];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: webUrl];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    if(![self openURL:webUrl]) {
        // Error Handle
        NSError *error = [NSError errorWithDomain:GitHubClientErrorDomain
                                             code:GitHubClientErrorOpeningBrowserFailed
                                         userInfo:@{
                                                    @"code" : @(GitHubClientErrorOpeningBrowserFailed),
                                                    @"message" : @"无法打开浏览器，请确认你是否设置了默认的浏览器"
                                                    }];
        [[NSNotificationCenter defaultCenter] postNotificationName:GitHubAuthenticatedNotifiactionFailure object:error];
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
    NSString *baseURLString = [GitHubURLBaseWeb stringByTrimmingCharactersInSet:slashSet];
    NSString *urlString = [[NSString alloc] initWithFormat: GitHubApiAccessToken, baseURLString];
    
    NSDictionary *parameters = @{@"client_id" : GitHubClientID, @"client_secret" : GitHubClientSecret, @"code" : queryStringDictionary[@"code"]};

    [self callApiByMethod:@"POST" url:urlString parameters:parameters needToken:NO success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = (NSDictionary *)responseObject;
        // temporary code 过期
        if (jsonObject[@"error"] != nil) {
            NSError *error = [NSError errorWithDomain:GitHubClientErrorDomain
                                                 code:GitHubClientErrorAuthenticationFailed
                                             userInfo:@{
                                                        @"code" : @(GitHubClientErrorAuthenticationFailed),
                                                        @"message" : jsonObject[@"error_description"]
                                                        }];
            [[NSNotificationCenter defaultCenter] postNotificationName:GitHubAuthenticatedNotifiactionFailure object:error];
        }
        self.token = jsonObject[@"access_token"];
        // Save token to datefile
        [self saveFileWithKey:GitHubAuthorizeContentKeyToken value:self.token];
        // Notify ViewController authorize is success
        [[NSNotificationCenter defaultCenter] postNotificationName:GitHubAuthenticatedNotifiactionSuccess object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self clearAllStoreFile];
        [[NSNotificationCenter defaultCenter] postNotificationName:GitHubAuthenticatedNotifiactionFailure object:error];
    }];
}

- (AFHTTPRequestOperation *)syncAuthenticatedUserInfo:(void (^)(GitHubUser *))success failure:(void (^)(NSError *))failure {
    NSString *urlString = [[NSString alloc] initWithFormat: GitHubApiAuthenticatedUser, GitHubURLApiEndpoint];
    
    AFHTTPRequestOperation *operation = [self callApiByMethod:@"GET" url:urlString parameters:nil needToken:YES
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        GitHubUser *user = [[GitHubUser alloc] initWithDictionary:responseObject];
        _authenticatedUser = user;
        // save user id and avatar url to file
        [self saveFileWithKey:GitHubAuthorizeContentKeyUserID value:user.login];
        [self saveFileWithKey:GitHubAuthorizeContentKeyAvatarURL value:user.avatarUrl];
        
        success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _authenticatedUser = nil;
        _token = nil;
        [self clearAllStoreFile];
        failure(error);
    }];

    return operation;
}

- (AFHTTPRequestOperation *)listAuthenticatedUserAllGist:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *apiUrl = [NSString stringWithFormat:GitHubApiListAuthenticatedUserAllGist, GitHubURLApiEndpoint];
    AFHTTPRequestOperation *operation = [self getGistsWithURL:apiUrl needToken:YES success:success failure:failure];
    return operation;
}

- (AFHTTPRequestOperation *)listAuthenticatedUserStarredGist:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *apiUrl = [NSString stringWithFormat:GitHubApiListAuthenticatedUserStarredGist, GitHubURLApiEndpoint];
    AFHTTPRequestOperation *operation = [self getGistsWithURL:apiUrl needToken:YES success:success failure:failure];
    return operation;
}

- (AFHTTPRequestOperation *)listAllGist:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *apiUrl = [NSString stringWithFormat:GitHubApiListAuthenticatedUserAllGist, GitHubURLApiEndpoint];
    AFHTTPRequestOperation *operation = [self getGistsWithURL:apiUrl needToken:NO success:success failure:failure];
    return operation;
}

- (NSString *)doucmentsDirecotry {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)authorizeFilePath {
    return [[self doucmentsDirecotry] stringByAppendingPathComponent:@"gistview.plist"];
}

- (void)clearAllStoreFile {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:GitHubAuthorizeContentKeyAvatarURL];
    [defaults removeObjectForKey:GitHubAuthorizeContentKeyToken];
    [defaults removeObjectForKey:GitHubAuthorizeContentKeyUserID];
    [defaults synchronize];
}

- (AFHTTPRequestOperation *)deleteAuthorization:(void (^)(void))success failure:(void(^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:GitHubApiRevokeAuthorization, GitHubURLApiEndpoint, GitHubClientID, self.token];
    AFHTTPRequestOperation *operation = [self callApiByMethodEx:@"DELETE" url:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    return operation;
}

# pragma mark - Private

- (void)saveFileWithKey:(NSString *)key value:(id)value {
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:value forKey:key];
//    [archiver finishEncoding];
//    [data writeToFile:[self authorizeFilePath] atomically:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

// 通过URL获取Gists
- (AFHTTPRequestOperation *)getGistsWithURL:(NSString *)url needToken:(BOOL)isNeedToken success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    AFHTTPRequestOperation * operation = [self callApiByMethod:@"GET" url:url parameters:nil needToken:isNeedToken success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *gists = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSDictionary *rawData in responseObject) {
            Gist *gist = [[Gist alloc] initWithDictionary:rawData];
            [gists addObject:gist];
        }
        success(gists);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
    return operation;
}

// 调用GitHub API特别版
- (AFHTTPRequestOperation *)callApiByMethodEx:(NSString *)method url:(NSString *)apiURL parameters:(NSDictionary *)parameters
                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSLog(@"%@ => %@", method, apiURL);
    
    NSError *serializationError = nil;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:GitHubBasicAuthorize forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:apiURL parameters:parameters error:&serializationError];
    void (^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"%@ SUCCESS => Response[%@]", method, responseObject);
        success(operation, responseObject);
    };
    
    void (^failureBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ Failure => STATUS CODE:%ld, Error: %@", method, (long)operation.response.statusCode, error);
        NSError *errorInfo = [self errorFromRequestOperation:operation];
        failure(operation, errorInfo);
    };
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:successBlock failure:failureBlock];
    [manager.operationQueue addOperation:operation];
    return operation;
}

// 调用GitHub API
- (AFHTTPRequestOperation *)callApiByMethod:(NSString *)method url:(NSString *)apiURL parameters:(NSDictionary *)parameters needToken:(BOOL)isNeedToken
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSLog(@"%@ => %@", method, apiURL);
    
    NSError *serializationError = nil;
    AFHTTPRequestOperationManager *manager = [self makeOperationManagerNeedToken:isNeedToken];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:apiURL parameters:parameters error:&serializationError];
    void (^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@ SUCCESS => Response[%@]", method, responseObject);
        success(operation, responseObject);
    };
    
    void (^failureBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ Failure => STATUS CODE:%ld, Error: %@", method, (long)operation.response.statusCode, error);
        NSError *errorInfo = [self errorFromRequestOperation:operation];
        failure(operation, errorInfo);
    };
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:successBlock failure:failureBlock];
    [manager.operationQueue addOperation:operation];
    return operation;
}

- (AFHTTPRequestOperationManager *)makeOperationManagerNeedToken: (BOOL)isNeedToken {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
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
    NSInteger errorCode = GitHubClientErrorConnectionFailed;
    NSString *errorMessage = [self errorUserInfoFromRequestOperation:operation];
    switch (HTTPCode) {
        case 401:
            errorCode = GitHubClientErrorAuthenticationFailed;
            break;
        case 400:
            errorCode = GitHubClientErrorBadRequest;
            break;
        case 403:
            errorCode = GitHubClientErrorRequestForbidden;
            break;
        case 422:
            errorCode = GitHubClientErrorServiceRequestFailed;
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
                        errorCode = GitHubClientErrorSecureConnectionFailed;
                        errorMessage = @"安全连接失败，请稍后再试。";
                        break;
                    case NSURLErrorNotConnectedToInternet:
                        errorCode = NSURLErrorNotConnectedToInternet;
                        errorMessage = @"网路不给力，请稍后再试!";
                        break;
                }
            }
            break;
    }
    
    errorInfo[@"code"] = @(errorCode);
    errorInfo[@"message"] = [NSString stringWithFormat:@"%@(%ld)", errorMessage, (long)errorCode];
    
    return [[NSError alloc]initWithDomain:GitHubClientErrorDomain code:errorCode userInfo:errorInfo];
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
