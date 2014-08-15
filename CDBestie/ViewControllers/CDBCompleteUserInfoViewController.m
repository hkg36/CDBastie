//
//  XCJCompleteUserInfoViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "CDBCompleteUserInfoViewController.h"
//#import "XCAlbumAdditions.h"
#import "CDBSuperViewController.h"
#import "CDBAppDelegate.h"
//#import "UIAlertViewAddition.h"
//#import "LXRequestFacebookManager.h"
#import "SVProgressHUD.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "CDBestieDefines.h"

@interface CDBCompleteUserInfoViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UITextField *NickText;
@property (weak, nonatomic) IBOutlet UIButton *ManBtn;
@property (weak, nonatomic) IBOutlet UIButton *LadyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *image_man;
@property (weak, nonatomic) IBOutlet UIImageView *image_lady;
@property (weak, nonatomic) IBOutlet UILabel *hintlbl;
@property (assign, nonatomic)  NSInteger inviteCid;
- (IBAction)protocolShow:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *proSwith;
- (IBAction)proSwitchChange:(id)sender;
@end

@implementation CDBCompleteUserInfoViewController

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
    _completeBtn.userInteractionEnabled = NO;
    _completeBtn.titleLabel.textColor = [UIColor grayColor];
    UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboary)];
    [self.view addGestureRecognizer:tapges];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        [[NSNotificationCenter defaultCenter]  removeObserver:self];
    }
}


/**
 *  选择男士
 *
 *  @param sender <#sender description#>
 */
- (IBAction)selectManClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.image_man.hidden = NO;
        self.image_lady.hidden = YES;
    }];
}

/**
 *  选择女士
 *
 *  @param sender <#sender description#>
 */
- (IBAction)selectLadyClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.image_man.hidden = YES;
        self.image_lady.hidden = NO;
    }];
}


#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    
    
}

-(void)hideKeyboary
{
    
    if([self.NickText isFirstResponder]){
        [self.NickText resignFirstResponder];
    }
}




-(IBAction)OpenGallery:(id)sender
{
    
    [SVProgressHUD show];
    
    {
        NSString *str = [self.NickText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.NickText.text = str;
        if ([str isEqualToString:@""]) {
            [SVProgressHUD dismiss];
            UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        int sex = 0;
        if (self.NickText.text.length > 1) {
            
            if (self.image_man.hidden) {
                sex  = 2;
            }
            else if (self.image_lady.hidden)
            {
                sex  = 1;
            }else{
                sex  = 0;
            }
        }
        NSDictionary * parames = @{@"nick":self.NickText.text,@"sex":@(sex)};
        [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            [SVProgressHUD dismiss];
            NSLog(@"%@",result);
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:self.NickText.text forKey:@"USERINFO_NICK"];
            [defaults setObject:@(sex) forKey:@"USER_SEX"];
            
            [self dismissViewControllerAnimated:NO completion:^{}];
            UINavigationController * CDBEndorseLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"CDBEndorseLoginNaviController"];
            [self presentViewController:CDBEndorseLoginNaviController animated:NO completion:nil];
            
            
            /*
             UITabBarController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBmainViewController"];
             //viewContr.selectedIndex = 2;
             [self.navigationController pushViewController:viewContr animated:YES];
             */
            
        } ];
        
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)protocolShow:(id)sender {
    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:protocolList]];
    webBrowser.showProgress = YES;
    webBrowser.allowOrder = YES;
    webBrowser.allowtoolbar = NO;
    
    UINavigationSample *webBrowserNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationSample"];
    [webBrowserNC pushViewController:webBrowser animated:NO];
    [self presentViewController:webBrowserNC animated:YES completion:NULL];
    
}
- (IBAction)proSwitchChange:(id)sender {
    if ([sender isOn]){
        _completeBtn.userInteractionEnabled = YES;
        _completeBtn.titleLabel.textColor = [UIColor whiteColor];
    }
    if (![sender isOn]){
        _completeBtn.userInteractionEnabled = NO;
        _completeBtn.titleLabel.textColor = [UIColor grayColor];
    }
}
@end
