//
//  GitHubClient.h
//  GistView
//
//  Created by Sebastian Qu on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>

static NSString * const GithubAuthenticatedNotifiactionSuccess = @"GithubAuthenticatedNotifiactionSuccess";
static NSString * const GithubAuthenticatedNotifiactionFailure = @"GithubAuthenticatedNotifiactionFailure";

// Server Url
static NSString * const GithubApiEndpointURL = @"https://api.github.com";
static NSString * const GithubBaseWebURL = @"https://github.com";

// API URL PATH
static NSString * const GithubApiAuthorize = @"%@/login/oauth/authorize?client_id=%@&scope=%@&state=%@";
static NSString * const GithubApiAccessToken = @"%@/login/oauth/access_token";
static NSString * const GithubApiAuthenticatedUser = @"%@/user";

// APP Setting
static NSString * const GithubClientID = @"fafb0af1c792afc8aac6";
static NSString * const GithubClientSecret = @"f30e7b2071b7dc763db53a38c0ad4528dadb013a";

// NSError Domain
NSString * const GithubClientErrorDomain = @"GithubClientErrorDomain";

// NSError Code
static NSInteger const GithubClientErrorAuthenticationFailed = 9001;
static NSInteger const GithubClientErrorServiceRequestFailed = 9002;
static NSInteger const GithubClientErrorConnectionFailed = 9003;
static NSInteger const GithubClientErrorJSONParsingFailed = 9004;
static NSInteger const GithubClientErrorBadRequest = 9005;
static NSInteger const GithubClientErrorTwoFactorAuthenticationOneTimePasswordRequired = 9006;
static NSInteger const GithubClientErrorUnsupportedServer = 9007;
static NSInteger const GithubClientErrorOpeningBrowserFailed = 9008;
static NSInteger const GithubClientErrorRequestForbidden = 9009;
static NSInteger const GithubClientErrorTokenAuthenticationUnsupported = 9010;
static NSInteger const GithubClientErrorUnsupportedServerScheme = 9011;
static NSInteger const GithubClientErrorSecureConnectionFailed = 9012;

@class GitHubUser;

@interface GitHubClient : NSObject

// 获取 GitHubClient's Singleton Instance
+ (instancetype)sharedInstance;
// 认证 (通过GitHub's oauth2.0)
- (void)authorize;
// 通过callback url中包含的code，获取token,完成登陆过程
- (void)completeAuthorizeWithCallbackURL:(NSURL *)callbackURL;

// 判断是否已取的GitHub认证
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;
// 认证用户的access_token
@property (nonatomic, strong, readonly) NSString *token;
// 认证用户的用户信息
@property (nonatomic, strong, readonly) GitHubUser *authenticatedUser;

@end
