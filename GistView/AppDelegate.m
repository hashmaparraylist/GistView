//
//  AppDelegate.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/27.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "AppDelegate.h"
#import "GitHubClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    GitHubClient *_sharedClient;
    UIStoryboard *_main;
}

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

# pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"*** GitHub callback url: %@", url);
    
    if ([url.host isEqual:@"oauth"]) {
        [_sharedClient completeAuthorizeWithCallbackURL:url success:^(id responseObject) {
            UIViewController *rootView = [_main instantiateViewControllerWithIdentifier:@"main"];
            [self.window.rootViewController presentViewController:rootView animated:YES completion:nil];
        } failure:^(NSError *error) {
            UIViewController *rootView = [_main instantiateViewControllerWithIdentifier:@"failureAuthorize"];
            [self.window.rootViewController presentViewController:rootView animated:YES completion:nil];
        }];
    } else {
        UIViewController *rootView = [_main instantiateViewControllerWithIdentifier:@"failureAuthorize"];
        [self.window.rootViewController presentViewController:rootView animated:YES completion:nil];
    }
    return YES;
}


@end
