//
//  userInfoCell.m
//  CDBestie
//
//  Created by apple on 14-8-5.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "userInfoCell.h"

@implementation userInfoCell
@synthesize  userIcon;
@synthesize  userLayerIcon;
@synthesize  userNickname;
@synthesize  userLevel;
@synthesize  userInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        userIcon = (UIImageView*)[self.contentView viewWithTag:1001];
//        userLayerIcon = (UIImageView*)[self.contentView viewWithTag:1002];
//        userNick = (UILabel*)[self.contentView viewWithTag:1003];
//        userLevel = (UIButton*)[self.contentView viewWithTag:1004];
//        userInfo = (UILabel*)[self.contentView viewWithTag:1005];
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
