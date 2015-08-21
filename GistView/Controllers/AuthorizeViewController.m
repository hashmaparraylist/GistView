//
//  AuthorizeViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/8/22.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "GitHubClient.h"
#import "AuthorizeViewController.h"

@interface AuthorizeViewController ()

@end

@implementation AuthorizeViewController

# pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set URL
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    
    NSCharacterSet *slashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSString *baseURLString = [GitHubURLBaseWeb stringByTrimmingCharactersInSet:slashSet];
    NSString *urlString = [[NSString alloc] initWithFormat: GitHubApiAuthorize, baseURLString, GitHubClientID, @"gist", uuidString];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    // register NSNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedSuccess:) name:GitHubAuthenticatedNotifiactionSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizedFailure:) name:GitHubAuthenticatedNotifiactionFailure object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)authorizedSuccess:(NSNotification *) notification {
    [self.delegate authorizeView:self authorizeSuccess:notification];
}

- (void)authorizedFailure:(NSNotification *) error {
    [self.delegate authorizeView:self authorizeFailure:error];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
