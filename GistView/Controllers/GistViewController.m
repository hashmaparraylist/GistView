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
#import "RawFileViewController.h"

@interface GistViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

@end

@implementation GistViewController

# pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.navigationItem.backBarButtonItem = backButton;
    self.usernameLabel.text = self.selectedGist.owner.login;
    self.fileNameLabel.text = self.selectedGist.files.allKeys[0];
    self.createdAtLabel.text = self.selectedGist.createdAt;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFile"]) {
        RawFileViewController *viewController = (RawFileViewController *)segue.destinationViewController;
        viewController.rawFileUrl = self.selectedGist.files[self.fileNameLabel.text][@"raw_url"];
    }
}

#pragma mark - UITableViewDataSource



#pragma mark - UITablewViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (section != 0) {
        return;
    }
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor blackColor]];
    Gist *gist = self.selectedGist;
    if (gist.gistDescription == (NSString*) [NSNull null] || gist.gistDescription.length == 0) {
        header.textLabel.text = @"(无题)";
    } else {
        header.textLabel.text = self.selectedGist.gistDescription;
    }
}

@end
