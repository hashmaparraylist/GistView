//
//  RawFileViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/11.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "RawFileViewController.h"

@interface RawFileViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation RawFileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
//    self.navigationItem.backBarButtonItem = backButton;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.rawFileUrl]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
