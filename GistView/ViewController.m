//
//  ViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/6/27.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "ViewController.h"
#import "GitHubClient.h"

@interface ViewController ()

@end

@implementation ViewController {
    GitHubClient *_sharedClient;
}

#pragma Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
