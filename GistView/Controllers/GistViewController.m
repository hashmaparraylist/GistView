//
//  GistViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/7.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "Gist.h"
#import "GitHubUser.h"
#import "GistViewController.h"

@interface GistViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

@end

@implementation GistViewController

# pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = self.selectedGist.owner.name;
    self.fileNameLabel.text = self.selectedGist.file[@"name"];
    self.createdAtLabel.text = self.selectedGist.createdAt;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - UITableViewDataSource



#pragma mark - UITablewViewDelegate


@end
