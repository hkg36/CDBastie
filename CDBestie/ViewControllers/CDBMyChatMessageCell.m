//
//  CDBMyChatMessageCell.m
//  CDBestie
//
//  Created by laukevin on 14-8-26.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBMyChatMessageCell.h"

@implementation CDBMyChatMessageCell
@synthesize bigImageUrl;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
