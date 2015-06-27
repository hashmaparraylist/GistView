//
//  GitHubClient.m
//  GistView
//
//  Created by 瞿盛 on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "GitHubClient.h"

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

# pragma mark - Public

# pragma mark - Private

@end
