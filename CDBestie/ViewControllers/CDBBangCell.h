//
//  CDBBangCell.h
//  CDBestie
//
//  Created by apple on 14-8-5.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBBangCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIImageView *iconLayer;
@property (weak, nonatomic) IBOutlet UILabel *userNick;
@property (weak, nonatomic) IBOutlet UIButton *userLevel;
@property (weak, nonatomic) IBOutlet UILabel *userInfo;
@property (weak, nonatomic) IBOutlet UILabel *userGoods;

@property (nonatomic) long long celluid;
@end
