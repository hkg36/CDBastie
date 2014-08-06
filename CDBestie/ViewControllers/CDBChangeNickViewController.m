//
//  CDBChangeNickViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "CDBChangeNickViewController.h"
#import "CDBestieDefines.h"
#import "CDBAppDelegate.h"
#import "SVProgressHUD.h"

@interface CDBChangeNickViewController ()<UITextFieldDelegate>

@end

@implementation CDBChangeNickViewController
@synthesize nicktext;
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
    [nicktext becomeFirstResponder];
    nicktext.text = [USER_DEFAULT objectForKey:@"USERINFO_NICK"];
}


-(IBAction)dismissThisNavi:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)saveAndUpload:(id)sender
{

    if (![nicktext.text isEqualToString:@""]) {
        [SVProgressHUD show];
        NSDictionary * parames = @{@"nick":nicktext.text};
        [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            [USER_DEFAULT setObject:nicktext.text forKey:@"USERINFO_NICK"];
            [USER_DEFAULT synchronize];
            [SVProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSlefNick" object:nicktext.text];
            [self  dismissThisNavi:nil];
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    if (textField.text.length > 15) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
