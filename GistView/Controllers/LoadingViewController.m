//
//  LoadingViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/29.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "GitHubClient.h"
#import "GitHubUser.h"
#import "LoadingViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>

@interface LoadingViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *reLoginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarUrl;
@end

@implementation LoadingViewController {
    GitHubClient *_sharedClient;
}

# pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册NSNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedSuccess:) name:GitHubAuthenticatedNotifiactionSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedFailure:) name:GitHubAuthenticatedNotifiactionFailure object:nil];
    
    self.avatarUrl.layer.cornerRadius = self.avatarUrl.bounds.size.width / 2;
    self.avatarUrl.clipsToBounds = true;
    
    _sharedClient = [GitHubClient sharedInstance];
    if (!_sharedClient.isAuthenticated) {
//        [_sharedClient authorize];
        self.loginBtn.hidden = YES;
        self.reLoginBtn.titleLabel.text = @"登陆";
        
    } else {
//        [self authorizedSuccess:nil];
        self.loginBtn.hidden = NO;
        self.reLoginBtn.titleLabel.text = @"使用其他账户登陆";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *image = (NSString *)[defaults stringForKey:GitHubAuthorizeContentKeyAvatarURL];
        
        [self.avatarUrl setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
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
- (void)authorizedSuccess:(NSNotification *) notification {
    // 获取认证用户的用户信息
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"获取认证用户信息";
    [_sharedClient syncAuthenticatedUserInfo:^(GitHubUser *user) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIStoryboard *main = self.storyboard;
        UIViewController *mainViewController = [main instantiateViewControllerWithIdentifier:@"main"];
        [self presentViewController:mainViewController animated:NO completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *errorMessage = error.userInfo[@"message"];
        NSLog(@"syncAuthenticatedUserInfo-> %@", errorMessage);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                        message:errorMessage
                                                       delegate:self
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil];
        [alert setTag:100];
        [alert show];
    }];
}

// oauth认证失败
- (void)authorizedFailure:(NSNotification *) error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSError *errorInfo = [error object];
    NSString *errorMessage = errorInfo.userInfo[@"message"];
    NSLog(@"authorizedFailure-> %@", errorMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                    message:errorMessage
                                                   delegate:self
                                          cancelButtonTitle:@"确认"
                                          otherButtonTitles:nil];
    [alert setTag:100];
    [alert show];
}

#pragma mark - Actions

- (IBAction)authorize:(id)sender {
    if (_sharedClient.isAuthenticated) {
        [self authorizedSuccess:nil];
    } else {
        [_sharedClient authorize];
    }
}

- (IBAction)reAuthorize:(id)sender {
    if (_sharedClient.isAuthenticated) {
        // clear session
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"准备重新登陆...";

        [_sharedClient deleteAuthorization:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_sharedClient clearAllStoreFile];
            // call the authentize
            [_sharedClient authorize];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *errorMessage = error.userInfo[@"message"];
            NSLog(@"syncAuthenticatedUserInfo-> %@", errorMessage);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:errorMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
            [alert setTag:100];
            [alert show];
        }];
    } else {
        // call the authentize
        [_sharedClient authorize];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [_sharedClient authorize];
    } else {
        
    }
}

@end
