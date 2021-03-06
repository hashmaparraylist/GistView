//
//  GitHubClient.h
//  GistView
//
//  Created by Sebastian Qu on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>

#ifndef _GITHUBCLIENT_
#define _GITHUBCLIENT_
static NSString * const GitHubAuthenticatedNotifiactionSuccess = @"GitHubAuthenticatedNotifiactionSuccess";
static NSString * const GitHubAuthenticatedNotifiactionFailure = @"GitHubAuthenticatedNotifiactionFailure";

// Server Url
static NSString * const GitHubURLApiEndpoint = @"https://api.github.com";
static NSString * const GitHubURLBaseWeb = @"https://github.com";

// API URL PATH
static NSString * const GitHubApiAuthorize = @"%@/login/oauth/authorize?client_id=%@&scope=%@&state=%@";
static NSString * const GitHubApiAccessToken = @"%@/login/oauth/access_token";
static NSString * const GitHubApiAuthenticatedUser = @"%@/user";
static NSString * const GitHubApiListAuthenticatedUserAllGist = @"%@/gists";            // List the Authenticated user's gists
static NSString * const GitHubApiListAuthenticatedUserStarredGist = @"%@/gists/starred"; // List the Authenticated user's starred gists
//static NSString * const GitHubApiListAuthenticatedUserPublicGist = @"%@/gists/public";  // List the Authenticated user's public gists
static NSString * const GitHubApiRevokeAuthorization = @"%@/applications/%@/tokens/%@";

// NSError Domain
static NSString * const GitHubClientErrorDomain = @"GitHubClientErrorDomain";

// NSError Code
static NSInteger const GitHubClientErrorAuthenticationFailed = 9001;
static NSInteger const GitHubClientErrorServiceRequestFailed = 9002;
static NSInteger const GitHubClientErrorConnectionFailed = 9003;
static NSInteger const GitHubClientErrorJSONParsingFailed = 9004;
static NSInteger const GitHubClientErrorBadRequest = 9005;
static NSInteger const GitHubClientErrorTwoFactorAuthenticationOneTimePasswordRequired = 9006;
static NSInteger const GitHubClientErrorUnsupportedServer = 9007;
static NSInteger const GitHubClientErrorOpeningBrowserFailed = 9008;
static NSInteger const GitHubClientErrorRequestForbidden = 9009;
static NSInteger const GitHubClientErrorTokenAuthenticationUnsupported = 9010;
static NSInteger const GitHubClientErrorUnsupportedServerScheme = 9011;
static NSInteger const GitHubClientErrorSecureConnectionFailed = 9012;

// Raw Data's Fromatter
static NSString * const GitHubRawDataDateTimeFormatter = @"yyyy-MM-dd'T'HH:mm:ss'Z'";

// Authorize's File Key
static NSString * const GitHubAuthorizeContentKeyToken = @"GitHubAuthorizeContentKeyToken";
static NSString * const GitHubAuthorizeContentKeyUserID = @"GitHubAuthorizeContentKeyUserID";
static NSString * const GitHubAuthorizeContentKeyAvatarURL = @"GitHubAuthorizeContentKeyAvatarURL";

#endif

@class GitHubUser;

@interface GitHubClient : NSObject
// 获取document目录
- (NSString *)doucmentsDirecotry;
// 获取配置文件
- (NSString *)authorizeFilePath;
// 获取 GitHubClient's Singleton Instance
+ (instancetype)sharedInstance;
// 认证 (通过GitHub's oauth2.0)
- (void)authorize;
// 通过callback url中包含的code，获取token,完成登陆过程
- (void)completeAuthorizeWithCallbackURL:(NSURL *)callbackURL;
// 同步认证用户信息
- (AFHTTPRequestOperation *)syncAuthenticatedUserInfo:(void (^)(GitHubUser *user))success failure:(void (^)(NSError *error))failure;
// 获取认证用户的创建和Forked的Gists
- (AFHTTPRequestOperation *)listAuthenticatedUserAllGist:(void (^)(NSArray *gists))success failure:(void(^)(NSError *error))failure;
// 获取认证用户的Starred的Gists
- (AFHTTPRequestOperation *)listAuthenticatedUserStarredGist:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
// 获取所有的Gists
- (AFHTTPRequestOperation *)listAllGist:(void (^)(NSArray *gists))success failure:(void(^)(NSError *error))failure;
// 删除当前授权用户
- (AFHTTPRequestOperation *)deleteAuthorization:(void (^)(void))success failure:(void(^)(NSError *))failure;

- (void)clearAllStoreFile;

// 判断是否已取的GitHub认证
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;
// 认证用户的access_token
@property (nonatomic, strong, readonly) NSString *token;
// 认证用户的用户信息
@property (nonatomic, strong, readonly) GitHubUser *authenticatedUser;

@end
