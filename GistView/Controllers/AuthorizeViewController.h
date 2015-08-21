//
//  AuthorizeViewController.h
//  GistView
//
//  Created by Sebastian Qu on 15/8/22.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AuthorizeViewController;

@protocol AuthorizeViewControllerDelegate <NSObject>

-(void)authorizeView:(AuthorizeViewController *)viewController authorizeSuccess:(NSNotification *)notification;
-(void)authorizeView:(AuthorizeViewController *)viewController authorizeFailure:(NSNotification *)notification;

@end

@interface AuthorizeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) id <AuthorizeViewControllerDelegate> delegate;

@end
