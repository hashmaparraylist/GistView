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
- (void)viewDidLoad {
    [super viewDidLoad];
    _sharedClient = [GitHubClient sharedInstance];
    if (!_sharedClient.isAuthenticated) {
        [_sharedClient authorize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
