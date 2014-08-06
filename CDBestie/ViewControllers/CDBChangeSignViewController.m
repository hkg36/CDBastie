//
//  CDBChangeSignViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "CDBChangeSignViewController.h"
#import "CDBestieDefines.h"
#import "CDBAppDelegate.h"
#import "SVProgressHUD.h"
@interface CDBChangeSignViewController ()<UITextViewDelegate>

@end

@implementation CDBChangeSignViewController

@synthesize nicktext;
@synthesize label_num;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    nicktext.delegate = self;
    nicktext.text = [USER_DEFAULT objectForKey:@"USERINFO_SIGNATURE"];

    label_num.text = [NSString stringWithFormat:@"%d",nicktext.text.length];
    [nicktext becomeFirstResponder];
}


-(IBAction)dismissThisNavi:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)saveAndUpload:(id)sender
{

    if (![nicktext.text isEqualToString:@""]) {
        if (nicktext.text.length > 100) {
            return;
        }
        [SVProgressHUD show];
        NSDictionary * parames = @{@"signature":nicktext.text};
        //nick, signature,sex, birthday, marriage, height
        [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            [SVProgressHUD dismiss];
            [USER_DEFAULT setObject:nicktext.text forKey:@"USERINFO_SIGNATURE"];
            [USER_DEFAULT synchronize];
            [self  dismissThisNavi:nil];
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    if (textView.text.length > 100) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        label_num.textColor = [UIColor redColor];
        label_num.text = [NSString stringWithFormat:@"-%d",textView.text.length - 100];
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        label_num.textColor = [UIColor lightGrayColor];
        label_num.text = [NSString stringWithFormat:@"%d",textView.text.length];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
