//
//  CDBEndorseTableViewController.m
//  CDBestie
//
//  Created by apple on 14-8-1.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBEndorseTableViewController.h"
#import "CDBLoginNaviController.h"
#import "CDBCompleteUserInfoViewController.h"
#import "CDBplusMenuView.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "CDBChangeUserInfoController.h"
#import "CDBEndorseCell.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "tools.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "CDBBangNaviController.h"
#import "CDBBangTableViewController.h"
#import "ACDBEndorseInfoController.h"
#import "ImageDownloader.h"
#import "DataTools.h"
#define GOODS_HOTEL_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/hotelNew.do?sessionid="


@interface CDBEndorseTableViewController ()
{
    UIView *myMenu;
    NSMutableArray *friend_list;
    UILabel *levellbl;
    
}
@property (readwrite)  BOOL show;
@property (nonatomic,weak) UIImageView *titleLabImage;
@property (nonatomic,weak) UILabel *titlelab;
@end

@implementation CDBEndorseTableViewController
@synthesize titlelab;
@synthesize titleLabImage;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if (![self.title isEqual:@"排行榜"]) {
        CGSize navSize = CGSizeMake(20 , 20);
        UIImage *menuImage = [self scaleToSize:[UIImage imageNamed:@"daiyan_list"] size:navSize];
        ;
        UIImage *searchImage = [self scaleToSize:[UIImage imageNamed:@"composeIcon"] size:navSize];
        ;
        UIBarButtonItem * menubar = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleDone target:self action:@selector(menubarClick)];
        UIBarButtonItem * mySearchbar = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStyleDone target:self action:@selector(mySearchbarClick)];
        UIBarButtonItem * loginoutBar = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStyleDone target:self action:@selector(loginOut)];
        self.navigationItem.rightBarButtonItems = @[menubar];
        UIImageView *tempLabImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"daiyan_logo"]];
        titleLabImage = tempLabImage;
        UILabel *templab = [[UILabel alloc]init];
        titlelab = templab;
        UINavigationBar *bar = [self.navigationController navigationBar];
        titleLabImage.frame = CGRectMake(20, bar.frame.size.height-15, 25, 25);
        NSLog(@"%@",NSStringFromCGRect(titleLabImage.frame));
        titlelab.frame = CGRectMake(20+30, bar.frame.size.height-15, 100, 30);
        [titlelab setText:@"代言人"];
        [titlelab setTextColor:[UIColor whiteColor]];
        [self.navigationController.view addSubview:titleLabImage];
        [self.navigationController.view addSubview:titlelab];
        [super viewDidLoad];
        
        
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        NSString *sessionid = [defaults objectForKey:@"SESSION_ID"];
        
        
        NSString *user_nick = [defaults objectForKey:@"USERINFO_NICK"];
        
        
        
        NSLog(@"sessionid = %@",sessionid);
        NSLog(@"nick = %@",user_nick);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!sessionid||[sessionid isEqualToString:@""]) {
                [self OpenLoginview:nil];
            }else{
                if(!user_nick||[user_nick isEqual:@""])
                {
                    [self completeUserInfoview:nil];
                }
                
                [self initHomeData];
                
            }
        });
    }
    if([self.title isEqual:@"排行榜"])
    {
    [self initHomeData];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.show = NO;
    self.tabBarController.tabBar.hidden=YES;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 44);
    titleLabImage.hidden = NO;
    titlelab.hidden = NO;
        [self initHomeData];
}

-(void)viewDidDisappear:(BOOL)animated
{
}
-(void)viewWillDisappear:(BOOL)animated
{
    titleLabImage.hidden = YES;
    titlelab.hidden =YES;
    
}

-(void)initHomeData
{
    [SVProgressHUD show];
    NSDictionary * parames = @{};
    [[WebSocketManager instance]sendWithAction:@"endorsement.list_user" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        if(request.error_code!=0)
        {
            [SVProgressHUD dismiss];
            //_picHint.hidden = NO;
            //_picHint.text = @"加载失败,请检查网络";
            return;
        }
        NSLog(@"%@",result);
        friend_list = result[@"users"];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }];
}


-(IBAction)OpenLoginview:(id)sender
{
    UINavigationController * CDBLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"CDBLoginNaviController"];
    [self presentViewController:CDBLoginNaviController animated:NO completion:nil];
}

-(IBAction)completeUserInfoview:(id)sender
{
    CDBCompleteUserInfoViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBCompleteUserInfoViewController"];
    viewContr.navigationItem.leftBarButtonItem.title =@"";
    [self presentViewController:viewContr animated:YES completion:^{
        
    }];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize{
    UIGraphicsBeginImageContext(newsize);
    [img drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


- (void)menubarClick
{
    if (self.show == NO) {

        if (!myMenu) {
        UIViewController *customView = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBplusMenuViewController"];
        
        CDBplusMenuView *clientview=(CDBplusMenuView*)customView.view;
            NSLog(@"%f",self.navigationController.navigationBar.frame.size.height);
        customView.view.frame = CGRectMake(0,self.navigationController.navigationBar.frame.size.height+20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-44);
            myMenu = customView.view ;
        customView.view.alpha = 0.0;
        customView.view.layer.borderWidth = 0.5f;
        customView.view.layer.masksToBounds = YES;
        customView.view.tag = 99;
        [[[UIApplication sharedApplication].delegate window] addSubview:myMenu];
        [UIView animateWithDuration:0.4 animations:^{
            [customView.view setAlpha:1.0];
        } completion:^(BOOL finished) {}];
        self.show =YES;
             [clientview.btn1 addTarget:self action:@selector(hiddenMenu) forControlEvents:UIControlEventTouchDown];
            [clientview.btn2 addTarget:self action:@selector(hiddenMenu) forControlEvents:UIControlEventTouchDown];
            [clientview.btn3 addTarget:self action:@selector(hiddenMenu) forControlEvents:UIControlEventTouchDown];
        [clientview.myBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_geren"] forState:UIControlStateNormal];
        [clientview.myBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_geren"] forState:UIControlStateSelected];
        [clientview.myBtn addTarget:self action:@selector(myInfoShow:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [clientview.bangBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_paihang"] forState:UIControlStateNormal];
        [clientview.bangBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_paihang"] forState:UIControlStateSelected];
        [clientview.bangBtn addTarget:self action:@selector(bangInfoShow:) forControlEvents:UIControlEventTouchUpInside];
        
    }else
    {
        self.show = YES;
    }
        
    }
    else
    {
        

        if (myMenu) {
            [myMenu removeFromSuperview];
            myMenu = nil;
            self.show = NO;
        }
        
    }
    
}
-(void)mySearchbarClick
{
    /*
    CDBChangeUserInfoController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeUserInfoController"];
    navi.title = @"个人资料";
    [self hiddenMenu];
     */

    [USER_DEFAULT setObject:@"" forKey:@"USERINFO_NICK"];
    UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"清除昵称成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)loginOut
{
    /*
     CDBChangeUserInfoController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeUserInfoController"];
     navi.title = @"个人资料";
     [self hiddenMenu];
     */

    [USER_DEFAULT setObject:@"" forKey:@"SESSION_ID"];
    UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出成功(未清除昵称)" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)myInfoShow:(id)sender {
    
    CDBChangeUserInfoController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeUserInfoController"];
    navi.title = @"个人资料";
    [self hiddenMenu];
    [self.navigationController pushViewController:navi animated:YES];
}

- (IBAction)bangInfoShow:(id)sender {
    
    CDBBangTableViewController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBBangTableViewController"];
    conss.title = @"排行榜";
    [self hiddenMenu];
    [self.navigationController pushViewController:conss animated:YES];
}


- (void)hiddenMenu
{
    if (myMenu) {
        [myMenu removeFromSuperview];
        myMenu = nil;
        self.show = NO;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if (friend_list) {
        return [friend_list count];
    }
    return 0;
    
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ACDBEndorseInfoController  * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"ACDBEndorseInfoController"];
    navi.userUid = [[[friend_list objectAtIndex:indexPath.row] objectForKey:@"uid"] longLongValue];
    CDBEndorseCell *cell =(CDBEndorseCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    navi.title = cell.userNick.text;
    [self.navigationController pushViewController:navi animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    CDBEndorseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CDBEndorseCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CDBEndorseCell alloc] init];
    }
    else{
        cell.userIcon.image=[UIImage imageNamed:@"left_view_avatar_avatar"];
        cell.userNick.text=nil;
        cell.userInfo.text=nil;
        cell.userGoods.text=nil;
        cell.userLevel.hidden=TRUE;
    }
    cell.celluid = [[[friend_list objectAtIndex:indexPath.row] objectForKey:@"uid"] longLongValue];
    // Configure the cell...
    NSString* cell_uid = [[friend_list objectAtIndex:indexPath.row] objectForKey:@"uid"];
    NSLog(@"cell_uid = %@",cell_uid);
    NSDictionary * parames = @{@"uid":cell_uid};
    
    [[WebSocketManager instance] sendWithAction:@"user.info2" parameters:parames cdata:GenCdata(12) callback:^(WSRequest *request, NSDictionary *result)
     {
         if(0!=request.error_code)
             return;
         if ([[request.parm valueForKey:@"uid"] longLongValue]!=cell.celluid) {
             return;
         }
         NSLog(@"user.info2 error = %@",request.error);
         
         [cell.userIcon.layer setCornerRadius:CGRectGetHeight([cell.userIcon bounds]) / 2];
         cell.userIcon.layer.masksToBounds = YES;
         cell.iconLayer.hidden =YES;
         UserInfo2 *userInfo =[[UserInfo2 alloc]initWithJson:result];
         cell.userNick.text = userInfo.user.nick;
         //NSString *imageString = [NSString stringWithFormat:@"http://laixinle.qiniudn.com/FjJHS3LxIfYSlN2XSfnvdVv4qbNR\?imageView2/1/w/%i/h/%i",(int)cell.userIcon.frame.size.width,(int)cell.userIcon.frame.size.height];
         if(userInfo.user.headpic)
         {
          NSString *imageString = [NSString stringWithFormat:@"%@?imageView2/1/w/%i/h/%i",userInfo.user.headpic,(int)cell.userIcon.frame.size.width,(int)cell.userIcon.frame.size.height];
         NSURL *imageURL = [NSURL URLWithString:imageString];
         NSLog(@"%@",imageURL);
         [[ImageDownloader instanse] startDownload:cell.userIcon forUrl:imageURL callback:^(UIView *view, id image) {
             if(image)
             {
                 ((UIImageView*)view).image=image;
             }
         }];
         }
         //[cell.userIcon setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
         
         NSString *user_SEX;
         NSString *user_JOB;
         if (userInfo.user.sex == 1) {
             user_SEX = @"男";
         }
         else
         {
             user_SEX =@"女";
         }
         
         user_JOB = userInfo.user.job;
         if (!user_JOB) {
             user_JOB = @"保密";
         }
         

         NSString *infoString = nil;
         if(userInfo.user.birthday)
         {
             NSTimeInterval birth = userInfo.user.birthday;
             NSLog(@"birth = %f",birth);

             NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
             NSDate *now;
             NSDateComponents *comps = [[NSDateComponents alloc] init];
             NSInteger unitFlags =  NSYearCalendarUnit |
             NSMonthCalendarUnit |
             NSDayCalendarUnit |
             NSWeekdayCalendarUnit |
             NSHourCalendarUnit |
             NSMinuteCalendarUnit |
             NSSecondCalendarUnit;
             now=[NSDate date];
             comps = [calendar components:unitFlags fromDate:now];
             
             NSInteger year = [comps year];
             
             int age=year - birth;
             
             if (age<0) {
                 age = abs(age);
             }
             NSLog(@"age = %d",age);
             NSLog(@"birth = %ld",(long)birth);
             infoString = [NSString stringWithFormat:@"%@ | %@ | %d岁",user_SEX,user_JOB,age];
         }
         else
         {
             infoString = [NSString stringWithFormat:@"%@ | %@ | 保密",user_SEX,user_JOB];
         }

         CGSize StringSize = [infoString
                     sizeWithFont:[UIFont systemFontOfSize:15.0f]
                          constrainedToSize:cell.userNick.frame.size
                          lineBreakMode:cell.userNick.lineBreakMode];
         cell.userNick.frame = CGRectMake(cell.userNick.frame.origin.x,
                      cell.userNick.frame.origin.y,
                      StringSize.width,
                      StringSize.height);
         cell.userInfo.text = infoString;
         [cell.userNick sizeToFit];
         [cell.userInfo sizeToFit];
         cell.userLevel.userInteractionEnabled = NO;
         int value = userInfo.endorsement.level;
         if (value == 0) {
             [cell.userLevel setBackgroundImage:[UIImage imageNamed:@"daiyan_liebiao_lingjiicon"] forState:UIControlStateNormal];
          [cell.userLevel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         }
         else
         {
             [cell.userLevel setBackgroundImage:[UIImage imageNamed:@"daiyan_liebiao_dengjiicon"] forState:UIControlStateNormal];
             [cell.userLevel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         }
         
         CGRect frame = cell.userNick.frame;
         cell.userLevel.frame =CGRectMake(frame.origin.x+frame.size.width+5, cell.userLevel.frame.origin.y, cell.userLevel.frame.size.width, cell.userLevel.frame.size.height);
         [cell.userLevel setTitle:[NSString stringWithFormat:@"LV%d",value] forState:UIControlStateNormal];
         NSLog(@"levelText = %@",[NSString stringWithFormat:@"LV%d",value]);
         [cell.userLevel.titleLabel sizeToFit];
         cell.userLevel.titleLabel.textAlignment = NSTextAlignmentCenter;
         cell.userLevel.hidden=FALSE;
         
         if(userInfo.endors_list){
             
             NSString *cs=[[userInfo.endors_list[0] valueForKey:@"merchandise"]valueForKey:@"productname"];
             int i;
             for(i=1;i < [userInfo.endors_list count];i++)
             {
                 NSDictionary *temp = userInfo.endors_list[i];
                 
                 cs =[NSString stringWithFormat:@"%@ | %@",cs,[[temp valueForKey:@"merchandise"]valueForKey:@"productname"]];
             }
             cell.userGoods.text = cs;
         }

     }timeout:UserInfo2_TimeOut];
    return cell;
}


@end
