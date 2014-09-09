//
//  CDBChatMessageCell.m
//  CDBestie
//
//  Created by laukevin on 14-8-25.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBChatMessageCell.h"

@implementation CDBChatMessageCell
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
