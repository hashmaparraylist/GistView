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
#import <MJRefresh/MJRefresh.h>

static NSString * const NothingFouncdCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";
static NSString * const GistCellIdentifier = @"GistCell";

@interface MyGistViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segement;

@property (nonatomic, strong) GitHubUser *authenticatedUser;
@property (nonatomic, strong) NSMutableArray *allGists;
@property (nonatomic, strong) NSMutableArray *starredGists;
@end

@implementation MyGistViewController {
    BOOL _isLoading;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allGists = [[NSMutableArray alloc] initWithCapacity:10];
    self.starredGists = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableView.rowHeight = 65;
    
    // 注册TableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:LoadingCellIdentifier bundle:nil] forCellReuseIdentifier:LoadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NothingFouncdCellIdentifier bundle:nil] forCellReuseIdentifier:NothingFouncdCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:GistCellIdentifier bundle:nil] forCellReuseIdentifier:GistCellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    __weak UITableView *tableView = self.tableView;
    __weak UISegmentedControl *segment = self.segement;
    tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (segment.selectedSegmentIndex == 0) {
                [weakSelf searchAllGists:tableView];
            } else {
                [weakSelf searchStarredGists:tableView];
            }
            [tableView.header endRefreshing];
        });
    }];
    
    [tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

// UISegmentedController 选择Segment变更时
- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    [self.tableView reloadData];
    if ([[self targetArray] count] == 0) {
        [self.tableView.header beginRefreshing];
    }
}

#pragma mark - Private

- (void)searchAllGists:(UITableView *)tableView {
    GitHubClient *sharedClient = [GitHubClient sharedInstance];
    [sharedClient listAuthenticatedUserAllGist:^(NSArray *gists) {
        self.allGists = [NSMutableArray arrayWithArray:gists];
        [tableView reloadData];
    } failure:^(NSError *error) {
        self.allGists = [[NSMutableArray alloc] initWithCapacity:10];
        [tableView reloadData];
    }];
}

- (void)searchStarredGists:(UITableView *)tableView {
    GitHubClient *sharedClient = [GitHubClient sharedInstance];
    [sharedClient listAuthenticatedUserStarredGist:^(NSArray * gists) {
        self.starredGists = [NSMutableArray arrayWithArray:gists];
        [tableView reloadData];
    } failure:^(NSError *error) {
        self.starredGists = [[NSMutableArray alloc] initWithCapacity:10];
        [tableView reloadData];
    }];
}

- (NSMutableArray *)targetArray {
    if (self.segement.selectedSegmentIndex == 0) {
        return self.allGists;
    }
    return self.starredGists;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self targetArray] count] == 0) {
        return 1;
    }
    return [[self targetArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.tableView.header isRefreshing]) {
        if ([[self targetArray] count] == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFouncdCellIdentifier forIndexPath:indexPath];
            return cell;
        }
    } else {
        if ([[self targetArray] count] == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
            return cell;
        }
    }
    GistCell *cell = [tableView dequeueReusableCellWithIdentifier:GistCellIdentifier forIndexPath:indexPath];
    Gist *gist = [self targetArray][indexPath.row];
    [cell configureForGist:gist];
    return cell;
}

@end
