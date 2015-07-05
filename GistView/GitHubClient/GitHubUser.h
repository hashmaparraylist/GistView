//
//  GitHubUser.h
//  GistView
//
//  Created by Sebastian Qu on 15/6/29.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubUser : NSObject <NSCopying>

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *htmlUrl;
@property (nonatomic, copy) NSString *gistsUrl;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, assign) NSInteger publicRepos;
@property (nonatomic, assign) NSInteger publicGits;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, assign) NSInteger following;

- (instancetype)initWithDictionary: (NSDictionary *)githubUser;

@end
