//
//  GistViewController.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/7.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "Gist.h"
#import "GitHubClient.h"
#import "GitHubUser.h"
#import "GistViewController.h"
#import "Util.h"
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
    
    if (self.selectedGist.owner && self.selectedGist.owner.login) {
        self.usernameLabel.text = self.selectedGist.owner.login;
    } else {
        self.usernameLabel.text = @"(匿名)";
    }
    self.fileNameLabel.text = self.selectedGist.files.allKeys[0];
    self.createdAtLabel.text = [Util formaterDateTime:self.selectedGist.createdAt formatterString:GitHubRawDataDateTimeFormatter];
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
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    if (section != 0) {
//        return;
//    }
//    
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    [header.textLabel setTextColor:[UIColor blackColor]];
//    Gist *gist = self.selectedGist;
//    if (gist.gistDescription == (NSString*) [NSNull null] || gist.gistDescription.length == 0) {
//        header.textLabel.text = @"(无题)";
//    } else {
//        header.textLabel.text = self.selectedGist.gistDescription;
//    }
////    header.backgroundView.bounds.size.height = header.textLabel.bounds.size.height;
//    CGRect newRect = CGRectMake(header.bounds.origin.x, header.bounds.origin.y, header.bounds.size.width, header.textLabel.bounds.size.height);
//    [header setBounds:newRect];
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section !=0) {
        return [super tableView:tableView viewForHeaderInSection:section];
    }
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    Gist *gist = self.selectedGist;
    NSString *text;
    if (gist.gistDescription == (NSString*) [NSNull null] || gist.gistDescription.length == 0) {
        text = @"(无题)";
    } else {
        text = [NSString stringWithString:self.selectedGist.gistDescription];
    }
    CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [text boundingRectWithSize:maximumLabelSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:nil].size;

    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    label.text = text;
    label.tag = 1002;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, expectedLabelSize.height + 10)];
    [view addSubview:label];
    [view sizeToFit];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    
    Gist *gist = self.selectedGist;
    NSString *text;
    if (gist.gistDescription == (NSString*) [NSNull null] || gist.gistDescription.length == 0) {
        text = @"(无题)";
    } else {
        text = [NSString stringWithString:self.selectedGist.gistDescription];
    }
    CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [text boundingRectWithSize:maximumLabelSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
                                                  context:nil].size;

    CGFloat defaultHeight = [super tableView:tableView heightForHeaderInSection:section];
    CGFloat expectHeght = expectedLabelSize.height + 10 + 10;
    return (defaultHeight > expectHeght) ? defaultHeight : expectHeght;
}

@end
