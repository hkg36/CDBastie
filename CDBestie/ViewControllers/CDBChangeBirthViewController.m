//
//  CDBChangeBirthViewController.m
//  CDBestie
//
//  Created by apple on 14-8-4.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBChangeBirthViewController.h"
#import "CDBestieDefines.h"
#import "CDBAppDelegate.h"
#import "SVProgressHUD.h"

@interface CDBChangeBirthViewController ()<UITextFieldDelegate>
{
    UIDatePicker *datePicker;
    UITextField *dateTextField;
    NSLocale *datelocale;
    NSString *myBirthdate;

}
@property(nonatomic) int birth;
@end

@implementation CDBChangeBirthViewController
@synthesize birthText;
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
    
    birthText.delegate = self;
    [birthText becomeFirstResponder];
    NSLog(@"%@",[USER_DEFAULT objectForKey:@"USERINFO_BIRTH"]);
    [self initDataPicker];
}


-(IBAction)dismissThisNavi:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)saveAndUpload:(id)sender
{
    
    if (![birthText.text isEqualToString:@""]) {
        [SVProgressHUD show];
        NSDictionary * parames = @{@"birthday":myBirthdate};
        //nick, signature,sex, birthday, marriage, height
        [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            [USER_DEFAULT synchronize];
            [SVProgressHUD dismiss];
            [self  dismissThisNavi:nil];
        }];
        [self  dismissThisNavi:nil];
        }
}

-(void)initDataPicker

{
    {
        birthText.delegate = self;
        datePicker = [[UIDatePicker alloc]init];
        datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
        datePicker.locale = datelocale;
        datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        datePicker.datePickerMode = UIDatePickerModeDate;
        birthText.inputView = datePicker ;
        UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                              action:@selector(birthPick)];
        toolBar.items = [NSArray arrayWithObject:right];
        birthText.inputAccessoryView = toolBar;
        
    }
}
-(void) birthPick {
    if ([self.view endEditing:NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:datelocale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:datelocale];
        birthText.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
        NSTimeInterval dateDiff = [datePicker.date timeIntervalSinceNow];
        NSTimeInterval interval =  [datePicker.date timeIntervalSince1970];
        NSInteger birth = interval;
        myBirthdate = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
        int age=trunc(dateDiff/(60*60*24))/365;
        if (age<0) {
            age = abs(age);
        }
        NSLog(@"age = %d",age);
        NSLog(@"birth = %ld",(long)birth);
        self.birth = birth;
        [USER_DEFAULT setInteger:age forKey:@"USERINFO_AGE"];
        [USER_DEFAULT setInteger:birth forKey:@"USERINFO_BIRTH"];
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
