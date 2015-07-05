//
//  Gist.h
//  GistView
//
//  Created by Sebastian Qu on 15/7/4.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GitHubUser;

@interface Gist : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *forksUrl;
@property (nonatomic, copy) NSString *commitsUrl;
@property (nonatomic, copy) NSString *gistDescription;
@property (nonatomic, copy) GitHubUser *owner;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, copy) GitHubUser *user;

@property (nonatomic, copy) NSDictionary *file;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, copy) NSString *commentsUrl;
@property (nonatomic, copy) NSString *htmlUrl;
@property (nonatomic, copy) NSString *gitPullUrl;
@property (nonatomic, copy) NSString *gitPushUrl;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSArray *forks;
@property (nonatomic, copy, readonly) NSArray *history;

- (id)initWithDictionary: (NSDictionary *)rawData;

@end
