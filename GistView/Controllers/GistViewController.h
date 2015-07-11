//
//  GistViewController.h
//  GistView
//
//  Created by Sebastian Qu on 15/7/7.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Gist;
@interface GistViewController : UITableViewController

@property (nonatomic, strong) Gist *selectedGist;
@property (nonatomic, assign) BOOL isStarred;

@end
