//
//  Gist.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/4.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "Gist.h"
#import "GitHubUser.h"

@interface Gist()
@property (nonatomic, copy, readwrite) NSArray *history;
@end

@implementation Gist

#pragma mark - Lifecycle

- (id)initWithDictionary: (NSDictionary *)rawData {
    self = [super init];
    if (rawData == nil) {
        return self;
    }
    
    self.id = rawData[@"id"];
    self.url = rawData[@"url"];
    self.forksUrl = rawData[@"forks_url"];
    self.commitsUrl = rawData[@"commits_url"];
    self.gistDescription = rawData[@"description"];
    if (rawData[@"owner"] != [NSNull null]) {
        self.owner = [[GitHubUser alloc] initWithDictionary:rawData[@"owner"]];
    }
    self.isPublic = (BOOL)rawData[@"public"];
    if (rawData[@"user"] != [NSNull null]) {
        self.user = [[GitHubUser alloc] initWithDictionary:rawData[@"user"]];
    }
    self.files = rawData[@"files"];
    NSNumber *comments = rawData[@"comments"];
    self.comments = [comments integerValue];
    self.commentsUrl = rawData[@"comments_url"];
    self.htmlUrl = rawData[@"html_url"];
    self.gitPullUrl = rawData[@"git_pull_url"];
    self.gitPushUrl = rawData[@"git_push_url"];
    self.createdAt = rawData[@"created_at"];
    self.updatedAt = rawData[@"upated_at"];
    self.forks = rawData[@"forks"];
    self.history = rawData[@"history"];
    
    return self;
}


@end
