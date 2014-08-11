//
//  CDBMainLoginViewController.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CDBMainLoginViewController.h"
//#import "LXAPIController.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "CDBCompleteUserInfoViewController.h"
#import "SVProgressHUD.h"
#import "DataHelper.h"

#import "MYIntroductionView.h"

#define kNumbersPeriod  @"0123456789"
#define MaxLen 11

@interface CDBMainLoginViewController ()<UITextFieldDelegate>
{
    User *myUserInfo;
}
@end

@implementation CDBMainLoginViewController
@synthesize appName;
@synthesize phoneNumberText;
@synthesize identCodeText;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark  VIEW

- (void)viewDidLoad
{
    [super viewDidLoad];
    [phoneNumberText setDelegate:self];
    [identCodeText setDelegate:self];
    //[appName setText:@"川妹妹"];
    [appName sizeToFit];
    UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapges];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults * settings1 = [NSUserDefaults standardUserDefaults];
    NSString *key1 = [NSString stringWithFormat:@"is_first"];
    NSString *value = [settings1 objectForKey:key1];
    //if (!value)
    {
      
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds)*3, CGRectGetHeight(self.view.bounds));
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        for (int i=0; i<3; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)*i, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i+1]];
            if(2  == i){
                
                
                CGRect frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-90, [UIScreen mainScreen].bounds.size.height*11/12-50, 180, 50);
                UIButton *goToMVBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                goToMVBtn.backgroundColor = [UIColor clearColor];
                [goToMVBtn setBackgroundImage:[UIImage imageNamed:@"click_before.png"] forState:UIControlStateNormal];
                goToMVBtn.frame = frame;
                [goToMVBtn addTarget:self action:@selector(startLX) forControlEvents:UIControlEventTouchUpInside];
                imageView.userInteractionEnabled=YES;
                [imageView addSubview:goToMVBtn];
                
            }
            
            [scrollView addSubview:imageView];
        }
            [self.view addSubview:scrollView];
        NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
        NSString * key = [NSString stringWithFormat:@"is_first"];
        [setting setObject:[NSString stringWithFormat:@"false"] forKey:key];
        [setting synchronize];
    }
    
    
}


-(void)startLX
{
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFade;
    [scrollView.superview.layer addAnimation:animation forKey:@"animation"];
    [scrollView removeFromSuperview];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{
    if (aScrollView == scrollView) {
        CGPoint point = scrollView.contentOffset;
        point.y = point.y*4;
        smallScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x/2, scrollView.contentOffset.y);
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


#pragma mark - KEYBOARD
- (void)keyboardWillShow:(NSNotification *)notification
{
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
}


-(void)hideKeyboard
{
    
    if ([phoneNumberText isFirstResponder]) {
        [phoneNumberText resignFirstResponder];
    }
    if ([identCodeText isFirstResponder]) {
        [identCodeText resignFirstResponder];
    }
}



#pragma mark - TEXTFIEL DELEGATE

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField == phoneNumberText) {
        if (textField.text.length >= 1)
            _phoneNImg.image = [UIImage imageNamed:@"login_user_highlighted_os7"];
        else
            _phoneNImg.image = [UIImage imageNamed:@"login_user_os7"];
        
    }else if (textField == identCodeText)
    {
        if (textField.text.length >= 1)
            _codeImg.image = [UIImage imageNamed:@"login_key_highlighted_os7"];
        else
            _codeImg.image = [UIImage imageNamed:@"login_key_os7"];
    }
    
    NSCharacterSet *cs;
    if(textField == phoneNumberText)
    {
    cs = [[NSCharacterSet characterSetWithCharactersInString:kNumbersPeriod] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];

    if (textField.text.length>=11&&range.length==0) {
        return NO;
    }
        return basicTest;
    }
    
    return  YES;
}



-(void) loginwithPhonePwd:(NSString * ) phone pwd:(NSString * ) identCode
{
    [SVProgressHUD show];
    if (phone.length != 11) {
        [SVProgressHUD dismiss];
        UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString * requestString = [NSString stringWithFormat:@"%@PhoneLogin?phone=%@&code=%@&cryptsession=1",CDBestieURLString,phone,identCode];
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [request setTimeoutInterval:3.0];
    NSLog(@"%@\n",requestString);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data){
    NSDictionary *responeDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
    NSLog(@"%@",responeDic);
    NSString * sessionID = [DataHelper getStringValue:responeDic[@"sessionid"] defaultValue:@""];
    NSString * serverURL =[NSString stringWithFormat:@"%@",[DataHelper getStringValue:responeDic[@"wss"] defaultValue:@""]] ;
    NSLog(@"sessionID = %@",sessionID);
    NSLog(@"serverURL = %@",serverURL);
        if(sessionID&&![sessionID isEqual:@""]){
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:sessionID forKey:@"SESSION_ID"];
            [defaults setObject:phone forKey:@"PHONE_NUMBER"];
            [defaults setObject:serverURL forKey:@"SERVER_URL"];
            
            [[WebSocketManager instance] close];
            [[WebSocketManager instance] open:serverURL withsessionid:sessionID];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveLogin:)
                                                         name:NotifyUserLogin
                                                       object:nil];
            
            

        }else{
            [SVProgressHUD dismiss];
            UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    else{
            UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败,请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
     }
    [SVProgressHUD dismiss];
}

- (void) receiveLogin:(NSNotification *) notification
{
    //User* u=(User*)notification.object;
    myUserInfo = (User*)notification.object;;
    NSLog(@"uid=%lld",myUserInfo.uid);
    
    {
        NSLog(@"UserInfo=%@",myUserInfo);
        {
            [SVProgressHUD dismiss];
            
            if (myUserInfo.nick) {
                NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                [defaults setObject:myUserInfo.nick forKey:@"USERINFO_NICK"];
                if(myUserInfo.uid)
                {
                    
                    [defaults setInteger:(NSInteger)myUserInfo.uid forKey:@"USERINFO_UID"];
                }
                else
                {
                    [defaults setInteger:0 forKey:@"USERINFO_UID"];
                }
                if(myUserInfo.birthday)
                {
                    [defaults setInteger:myUserInfo.birthday forKey:@"USERINFO_BIRTH"];
                }
                else
                {
                    [defaults setInteger:0 forKey:@"USERINFO_BIRTH"];
                }
                if(myUserInfo.sex)
                {
                    [defaults setInteger:myUserInfo.sex forKey:@"USERINFO_SEX"];
                }
                else
                {
                    [defaults setInteger:0 forKey:@"USERINFO_SEX"];
                }
                if(myUserInfo.signature)
                    
                {
                    [defaults setObject:myUserInfo.signature forKey:@"USERINFO_SIGNATURE"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"USERINFO_SIGNATURE"];
                }
                if(myUserInfo.headpic)
                {
                    [defaults setObject:myUserInfo.headpic forKey:@"USERINFO_HEADPIC"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"USERINFO_HEADPIC"];
                }
                if(myUserInfo.job)
                {
                    [defaults setObject:myUserInfo.job forKey:@"USERINFO_JOB"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"USERINFO_JOB"];
                }
                [defaults synchronize];
                NSLog(@"%@",myUserInfo.nick);
                [SVProgressHUD dismiss];
                [self dismissViewControllerAnimated:NO completion:^{}];
            }
            else
            {
                [SVProgressHUD dismiss];
                [self completeUserInfoview:nil];
            }
        }
    }
    
    
}

-(BOOL)isVaildPhoneN:(NSString*)text
{
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:text];
    return isMatch;
}

#pragma mark CLICK FUCTION

- (IBAction)getCode:(id)sender {
    if (phoneNumberText.text.length != 11) {
        UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
    [self runSequncer:phoneNumberText.text];
    
    }
}

- (void)runSequncer :(NSString * )phone
{
    [SVProgressHUD show];
    NSString * requestString = [NSString stringWithFormat:@"%@/getcode?phone=%@",CDBestieURLString,phoneNumberText.text];

    
    
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [request setTimeoutInterval:3.0];
    NSLog(@"%@\n",requestString);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"returnString = %@", returnString);
    if(data){
        [SVProgressHUD dismiss];
    NSDictionary *messDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
        if(error){
            [SVProgressHUD dismiss];
            UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取验证码失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        
        }else{
            
            if ([messDic objectForKey:@"msg"]) {
                NSLog(@"identCode = %@",[messDic valueForKey:@"msg"]);
                UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[messDic valueForKey:@"msg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{
                
                if (![@"" isEqualToString: returnString]) {
                    UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码已发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else
                {
                    UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取验证码失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        
        }
        
    }
    else{
        [SVProgressHUD dismiss];
        UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取验证码失败,请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    
    }

}

- (IBAction)Login:(id)sender {
    [SVProgressHUD show];
    [self loginwithPhonePwd:phoneNumberText.text pwd:identCodeText.text];
    
}

-(IBAction)completeUserInfoview:(id)sender
{
    CDBCompleteUserInfoViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBCompleteUserInfoViewController"];
    [self.navigationController pushViewController:viewContr animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
