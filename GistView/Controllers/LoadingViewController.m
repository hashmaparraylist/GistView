//
//  LoadingViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/29.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "GitHubClient.h"
#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController {
    GitHubClient *_sharedClient;
//    MBProgressHUD *_hud;
}

# pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // 注册NSNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedSuccess:) name:GithubAuthenticatedNotifiactionSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedFailure:) name:GithubAuthenticatedNotifiactionFailure object:nil];
    _sharedClient = [GitHubClient sharedInstance];
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
- (void)authorizedSuccess:(NSNotification *) userInfo {
    
}

// oauth认证失败
- (void)authorizedFailure:(NSNotification *) error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *errorInfo = [error object];
    NSString *errorMessage = errorInfo[@"message"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                    message:errorMessage
                                                   delegate:self
                                          cancelButtonTitle:@"确认"
                                          otherButtonTitles:nil];
    
    [alert show];
}


@end