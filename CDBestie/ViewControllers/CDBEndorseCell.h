//
//  CDBEndorseCell.h
//  CDBestie
//
//  Created by apple on 14-8-4.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBEndorseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIImageView *iconLayer;
@property (weak, nonatomic) IBOutlet UILabel *userNick;

@property (weak, nonatomic) IBOutlet UILabel *userInfo;
@property (weak, nonatomic) IBOutlet UILabel *userGoods;
@property (weak, nonatomic) IBOutlet UIButton *userLevel;
@property (nonatomic) long long celluid;
@end
