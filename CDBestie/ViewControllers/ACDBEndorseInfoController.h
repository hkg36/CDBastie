//
//  ACDBEndorseInfoController.h
//  CDBestie
//
//  Created by apple on 14-8-7.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACDBEndorseInfoController : UITableViewController
@property (weak, nonatomic) IBOutlet UIImageView *Image_userIcon;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@property (weak, nonatomic) IBOutlet UILabel *label_info;
@property (weak, nonatomic) IBOutlet UIButton *levelBtn;
@property (weak, nonatomic) IBOutlet UILabel *Label_daiyanjifen;
@property (weak, nonatomic) IBOutlet UILabel *Label_xiaofeijifen;
@property (weak, nonatomic) IBOutlet UIImageView *firPic;
@property (weak, nonatomic) IBOutlet UIImageView *secPic;
@property (weak, nonatomic) IBOutlet UIImageView *thrPic;
@property (weak, nonatomic)  UIImageView *goodsIcon;
@property (weak, nonatomic) UILabel *goodsName;
@property (weak, nonatomic) UILabel *goodsInfo;
@property (nonatomic) long long userUid;
@property (nonatomic)BOOL haveFavor;
@end