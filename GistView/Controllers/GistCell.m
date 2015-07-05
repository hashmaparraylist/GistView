//
//  GistCell.m
//  GistView
//
//  Created by 瞿盛 on 15/7/5.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Gist.h"
#import "GistCell.h"
#import "GitHubUser.h"

@interface GistCell()

@property (weak, nonatomic) IBOutlet UIImageView *ownerAvatar;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *createAtLabel;

@end

@implementation GistCell

# pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
}


#pragma mark - Public

- (void)configureForGist:(Gist *)gist {
    if ([gist.gistDescription isEqualToString:@""]) {
        self.descriptionLabel.text = @"(无题)";
    } else {
        self.descriptionLabel.text = gist.gistDescription;
    }
    self.createAtLabel.text = gist.createdAt;
    
    [self.ownerAvatar setImageWithURL:[NSURL URLWithString:gist.owner.avatarUrl] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

#pragma mark - UITableViewCell
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
