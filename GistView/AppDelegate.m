//
//  AppDelegate.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/27.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "GitHubClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

# pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"*** GitHub callback url: %@", url);
    if ([url.host isEqual:@"oauth"]) {
        MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
        _hud.labelText = @"认证中...";
        [[GitHubClient sharedInstance] completeAuthorizeWithCallbackURL:url];
        return YES;
    }
    return NO;
}


@end
