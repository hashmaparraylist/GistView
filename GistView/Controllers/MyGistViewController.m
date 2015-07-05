//
//  MyGistViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/3.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "GitHubClient.h"
#import "GitHubUser.h"
#import "MyGistViewController.h"

static NSString * const NothingFouncdCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface MyGistViewController ()

@property (nonatomic, strong) GitHubUser *authenticatedUser;
@property (nonatomic, strong) NSMutableArray *gists;
@end

@implementation MyGistViewController {
    BOOL _isLoading;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gists = [[NSMutableArray alloc] initWithCapacity:10];
    self.authenticatedUser = [GitHubClient sharedInstance].authenticatedUser;
    self.navigationItem.title = [NSString stringWithFormat:@"%@的Gist", self.authenticatedUser.name];
    
    self.tableView.rowHeight = 65;
    
    // 注册TableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:LoadingCellIdentifier bundle:nil] forCellReuseIdentifier:LoadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NothingFouncdCellIdentifier bundle:nil] forCellReuseIdentifier:NothingFouncdCellIdentifier];
    
    if ([self.gists count] == 0) {
        _isLoading = true;
        [self searchMyGists];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.gists count] == 0) {
        return 1;
    } else {
        return [self.gists count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLoading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFouncdCellIdentifier forIndexPath:indexPath];
        return cell;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Private

-(void) searchMyGists {
    GitHubClient *sharedClient = [GitHubClient sharedInstance];
    [sharedClient listAuthenticatedUserAllGist:^(NSArray *gists) {
        _isLoading = false;
        self.gists = [NSMutableArray arrayWithArray:gists];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        _isLoading =false;
        self.gists = [[NSMutableArray alloc] initWithCapacity:10];
        [self.tableView reloadData];
    }];
}

@end
