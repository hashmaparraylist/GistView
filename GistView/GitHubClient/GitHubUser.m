//
//  GitHubUser.m
//  GistView
//
//  Created by 瞿盛 on 15/6/29.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "GitHubUser.h"

@implementation GitHubUser

#pragma mark - Lifecycle

- (instancetype)initWithDictionary:(NSDictionary *)githubUser {
    self = [super init];
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
    return self;
}

@end
