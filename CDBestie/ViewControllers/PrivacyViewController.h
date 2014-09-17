//
//  PrivacyViewController.h
//  CDBestie
//
//  Created by laukevin on 14-9-17.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *agreeAction;

- (IBAction)agreeclick:(id)sender;

@end
