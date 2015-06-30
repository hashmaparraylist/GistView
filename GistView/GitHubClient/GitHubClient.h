//
//  GitHubClient.h
//  GistView
//
//  Created by Sebastian Qu on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class GitHubUser;

@interface GitHubClient : NSObject

// 获取 GitHubClient's Singleton Instance
+ (instancetype)sharedInstance;
// 认证 (通过GitHub's oauth2.0)
- (void)authorize;
// 通过callback url中包含的code，获取token,完成登陆过程
- (void)completeAuthorizeWithCallbackURL:(NSURL *)callbackURL success:(void (^)(id responseObject))success failure:(void(^)(NSError *error))failure;

// 判断是否已取的GitHub认证
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;
// 认证用户的access_token
@property (nonatomic, strong, readonly) NSString *token;
// 认证用户的用户信息
@property (nonatomic, strong, readonly) GitHubUser *authenticatedUser;

@end
