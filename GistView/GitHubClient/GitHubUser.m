//
//  GitHubUser.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/29.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "GitHubUser.h"

@interface GitHubUser()

@property (nonatomic, strong) NSDictionary *rawData;

@end

@implementation GitHubUser

#pragma mark - Lifecycle

- (instancetype)initWithDictionary:(NSDictionary *)githubUser {
    self = [super init];
    if (githubUser == nil) {
        return self;
    }
    self.login = githubUser[@"login"];
    self.id = githubUser[@"id"];
    self.avatarUrl = githubUser[@"avatar_url"];
    self.url = githubUser[@"url"];
    self.htmlUrl = githubUser[@"html_url"];
    self.gistsUrl = githubUser[@"gists_url"];
    self.type = githubUser[@"type"];
    self.name = githubUser[@"name"];
    self.company = githubUser[@"company"];
    self.blog = githubUser[@"blog"];
    self.location = githubUser[@"location"];
    self.email = githubUser[@"email"];
    self.bio = githubUser[@"bio"];
    self.publicRepos = [(NSNumber *)githubUser[@"public_repos"] integerValue];
    self.publicGits = [(NSNumber *)githubUser[@"public_gits"] integerValue];
    self.followers = [(NSNumber *)githubUser[@"followers"] integerValue];
    self.following = [(NSNumber *)githubUser[@"following"] integerValue];
    
    self.rawData = [[NSDictionary alloc] initWithDictionary:githubUser copyItems:YES];
    return self;
}

#pragma mark - NSCopy

- (id)copyWithZone:(NSZone *)zone {
    GitHubUser *copy = [[GitHubUser alloc] initWithDictionary:self.rawData];
    return copy;
}

@end
