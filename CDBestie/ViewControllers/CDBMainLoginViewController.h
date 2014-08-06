//
//  CDBMainLoginViewController.h
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBMainLoginViewController : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIScrollView *smallScrollView;
}
@property (weak, nonatomic) IBOutlet UIImageView *phoneNImg;
@property (weak, nonatomic) IBOutlet UIImageView *codeImg;

@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberText;
@property (weak, nonatomic) IBOutlet UITextField *identCodeText;
@property (weak, nonatomic) IBOutlet UIButton *getCodebtn;
@property (weak, nonatomic) IBOutlet UIButton *mainLoginbtn;


- (IBAction)getCode:(id)sender;
- (IBAction)Login:(id)sender;


@end
