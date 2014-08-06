//
//  userInfoCell.h
//  CDBestie
//
//  Created by apple on 14-8-5.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userInfoCell : UITableViewCell
//@property (nonatomic,strong) UIImageView* userIcon;
//@property (nonatomic,strong) UIImageView* userLayerIcon;
//@property (nonatomic,strong) UILabel* userNick;
//@property (nonatomic,strong) UIButton* userLevel;
//@property (nonatomic,strong) UILabel* userInfo;
@property (weak, nonatomic) IBOutlet UILabel *userNickname;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIImageView *userLayerIcon;
@property (weak, nonatomic) IBOutlet UIButton *userLevel;
@property (weak, nonatomic) IBOutlet UILabel *userInfo;

@end
