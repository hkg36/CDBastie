//
//  FavorCell.m
//  CDBestie
//
//  Created by laukevin on 14-8-29.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "FavorCell.h"

@implementation FavorCell

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
