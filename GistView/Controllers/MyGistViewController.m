//
//  MyGistViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/3.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "Gist.h"
#import "GitHubClient.h"
#import "GitHubUser.h"
#import "GistCell.h"
#import "MyGistViewController.h"

static NSString * const NothingFouncdCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";
static NSString * const GistCellIdentifier = @"GistCell";

@interface MyGistViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segement;

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
    [self.tableView registerNib:[UINib nibWithNibName:GistCellIdentifier bundle:nil] forCellReuseIdentifier:GistCellIdentifier];
    
    if ([self.gists count] == 0) {
        _isLoading = true;
        [self searchMyGists];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

// UISegmentedController Action
- (void)segmentedControlHasChangedValue:(UISegmentedControl *)sender {
    
}

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
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

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
        if ([self.gists count] == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFouncdCellIdentifier forIndexPath:indexPath];
            return cell;
        }
    }
    
    GistCell *cell = [tableView dequeueReusableCellWithIdentifier:GistCellIdentifier forIndexPath:indexPath];
    Gist *gist = self.gists[indexPath.row];
    [cell configureForGist:gist];
    return cell;
}

@end
