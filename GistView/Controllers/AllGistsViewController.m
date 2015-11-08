//
//  AllGistsViewController.m
//  GistView
//
//  Created by Sebastian Qu on 2015/7/11.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

@import GoogleMobileAds;

#import "AllGistsViewController.h"
#import "Gist.h"
#import "GitHubClient.h"
#import "GitHubUser.h"
#import "GistCell.h"
#import "GistViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <AdSupport/AdSupport.h>
#import "Keys.h"

static NSString * const NothingFouncdCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";
static NSString * const GistCellIdentifier = @"GistCell";

@interface AllGistsViewController ()

@property (nonatomic, strong) NSMutableArray *gists;

@end

@implementation AllGistsViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.gists = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableView.rowHeight = 65;
    
    // 注册TableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:LoadingCellIdentifier bundle:nil] forCellReuseIdentifier:LoadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NothingFouncdCellIdentifier bundle:nil] forCellReuseIdentifier:NothingFouncdCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:GistCellIdentifier bundle:nil] forCellReuseIdentifier:GistCellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    __weak UITableView *tableView = self.tableView;
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf searchAllGists:tableView];
        });
    }];
    
    [tableView.mj_header beginRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)searchAllGists:(UITableView *)tableView {
    GitHubClient *sharedClient = [GitHubClient sharedInstance];
    [sharedClient listAllGist:^(NSArray *gists) {
        self.gists = [NSMutableArray arrayWithArray:gists];
        [tableView reloadData];
        [tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        self.gists = [[NSMutableArray alloc] initWithCapacity:10];
        [tableView reloadData];
        [tableView.mj_header endRefreshing];
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detail"]) {
        GistViewController *gistViewController = (GistViewController *)segue.destinationViewController;
        if (gistViewController != nil) {
            NSIndexPath *selectedRow = (NSIndexPath *)sender;
            Gist *selectedGist = self.gists[selectedRow.row];
            gistViewController.selectedGist = selectedGist;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.gists count] == 0) {
        return 1;
    }
    return [self.gists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.tableView.mj_header isRefreshing]) {
        if ([self.gists count] == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFouncdCellIdentifier forIndexPath:indexPath];
            return cell;
        }
    } else {
        if ([self.gists count] == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
            return cell;
        }
    }
    GistCell *cell = [tableView dequeueReusableCellWithIdentifier:GistCellIdentifier forIndexPath:indexPath];
    Gist *gist = self.gists[indexPath.row];
    [cell configureForGist:gist];
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GADBannerView *_adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    _adBanner.adUnitID = AllAdMobUnitID;
    _adBanner.rootViewController = self;
    [_adBanner loadRequest:[GADRequest request]];
    return _adBanner;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"detail" sender:indexPath];
}

@end
