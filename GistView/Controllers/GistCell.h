//
//  GistCell.h
//  GistView
//
//  Created by Sebastian Qu on 15/7/5.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Gist;

@interface GistCell : UITableViewCell

- (void)configureForGist:(Gist *)gist;

@end
