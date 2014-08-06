//
//  CDBChangeJobViewController.m
//  CDBestie
//
//  Created by apple on 14-8-4.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBChangeJobViewController.h"
#import "CDBestieDefines.h"
#import "CDBAppDelegate.h"
#import "SVProgressHUD.h"

@interface CDBChangeJobViewController ()<UITextFieldDelegate>

@end

@implementation CDBChangeJobViewController
@synthesize JobText;
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
    
    JobText.delegate = self;
    [JobText becomeFirstResponder];
    JobText.text = [USER_DEFAULT objectForKey:@"USERINFO_JOB"];
}


-(IBAction)dismissThisNavi:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)saveAndUpload:(id)sender
{
    
    if (![JobText.text isEqualToString:@""]) {
        [SVProgressHUD show];
        NSDictionary * parames = @{@"job":JobText.text};
        //nick, signature,sex, birthday, marriage, height
        [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            [USER_DEFAULT setObject:JobText.text forKey:@"USERINFO_JOB"];
            [USER_DEFAULT synchronize];
            [SVProgressHUD dismiss];
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

