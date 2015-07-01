//
//  LoadingViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/29.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "LoadingViewController.h"
#import "GitHubClient.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController {
    GitHubClient *_sharedClient;
}

# pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _sharedClient = [GitHubClient sharedInstance];
        // 注册NSNotification
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedSuccess:) name:GithubAuthenticatedNotifiactionSuccess object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedFailure:) name:GithubAuthenticatedNotifiactionFailure object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_sharedClient.isAuthenticated) {
        [_sharedClient authorize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Private

// oauth认证成功
- (void)authorizedSuccess:(NSDictionary *) params {
}

// oauth认证失败
- (void)authorizedFailure:(NSError *) error {
}


@end