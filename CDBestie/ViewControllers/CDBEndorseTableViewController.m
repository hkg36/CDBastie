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
#import "DataTools.h"
#import "ImageDownloader.h"
#import "CDBAppDelegate.h"
#import "UIViewController+Indicator.h"
#import "UIView+Additon.h"
#import "XCJErrorView.h"
#import <limits.h>
#define PIC_QUALITY (((CDBAppDelegate*)[[UIApplication sharedApplication]delegate]).picQuality)

#define GOODS_HOTEL_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/hotelNew.do?sessionid="


@interface CDBEndorseTableViewController ()
{
    UIView *myMenu;
    NSMutableArray *Friend_list;
    NSMutableArray *friendUidArray;
    NSMutableArray *Endorse_favorUidArray;
    NSMutableArray *Endorse_list;
    UILabel *levellbl;
    NSMutableArray *navNick_list;
    NSString *searchS;
    NSSet *FriendSet;
}
@property (readwrite)  BOOL show;
@property (nonatomic,weak) UIImageView *titleLabImage;
@property (nonatomic,weak) UILabel *titlelab;
@property (nonatomic,retain) UISearchBar* mysearchBar;
@property(nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property(nonatomic, copy) NSMutableArray *filteredPersons;
@property(nonatomic) BOOL isFiltered;
@property(nonatomic) BOOL isSearchBack;

@end

@implementation CDBEndorseTableViewController
@synthesize titlelab;
@synthesize titleLabImage;
@synthesize mysearchBar;
@synthesize mySearchDisplayController;
@synthesize isFavor;
@synthesize isBang;
@synthesize shouldReload,favorChange;
@synthesize Endorse_assignArray;


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

    if(!isFavor&&!isBang)
    {
        mysearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40)];
        mysearchBar.showsCancelButton = YES;
        mysearchBar.placeholder =@"搜索";
        mysearchBar.delegate = self;
        [mysearchBar sizeToFit];
        self.tableView.tableHeaderView =mysearchBar;
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(mysearchBar.bounds));
    }
    if (![self.title isEqual:@"排行榜"]) {
        CGSize navSize = CGSizeMake(15 , 12);
        UIImage *menuImage = [self scaleToSize:[UIImage imageNamed:@"daiyan_list"] size:navSize];
        ;
        UIBarButtonItem * menubar = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleDone target:self action:@selector(menubarClick)];
        self.navigationItem.rightBarButtonItems = @[menubar];
        [self addPic];
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        NSString *sessionid = [defaults objectForKey:@"SESSION_ID"];
        NSString *user_nick = [defaults objectForKey:@"USERINFO_NICK"];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!sessionid) {
                [self OpenLoginview:nil];
            }else{
                if(!user_nick||[user_nick isEqual:@""])
                {
                    [self completeUserInfoview:nil];
                }
            
            }
        });
        
    }
    
}



-(void)addPic

{
    UIImageView *tempLabImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"daiyan_logo"]];
    titleLabImage = tempLabImage;
    UILabel *templab = [[UILabel alloc]init];
    titlelab = templab;
    UINavigationBar *bar = [self.navigationController navigationBar];
    titleLabImage.frame = CGRectMake(6, (bar.frame.size.height-20)/2, 20, 20);
    NSLog(@"%@",NSStringFromCGRect(titleLabImage.frame));
    titlelab.frame = CGRectMake(6+25, (bar.frame.size.height-20)/2, 100, 20);
    [titlelab setText:@"代言人"];
    [titlelab setTextColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar addSubview:titleLabImage];
    [self.navigationController.navigationBar addSubview:titlelab];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.show = NO;
    self.tabBarController.tabBar.hidden=YES;
    [self.navigationController.toolbar removeFromSuperview];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 44);
    titleLabImage.hidden = NO;
    titlelab.hidden = NO;
    if (_isSearchBack) {
        if (searchS) {
            mysearchBar.text =searchS;
        }
        return;
    }
    [self getFriendList];
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

    if (isFavor) {
        Endorse_list = Endorse_assignArray;
        [self.tableView reloadData];
        return;
    }
    [self performSelector:@selector(showLoading) withObject:nil afterDelay:.3];
    NSDictionary * parames = @{};
    [[WebSocketManager instance]sendWithAction:@"endorsement.list_user" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        if(request.error_code!=0)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
            [SVProgressHUD dismiss];
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
        [SVProgressHUD dismiss];
        [self isChanged:result[@"users"]];
        if (shouldReload||favorChange) {
            Endorse_list = result[@"users"];
            [self.tableView reloadData];
        }
        
    }];
}


-(void)getFriendList
{
    
    NSDictionary * parames = @{@"uid":@([[USER_DEFAULT objectForKey:@"USERINFO_UID"] longLongValue]),@"pos":@(0),@"count":@LLONG_MAX};
    [[WebSocketManager instance]sendWithAction:@"user.friend_list" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        if(request.error_code!=0)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
            [SVProgressHUD dismiss];
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
        if ([self FavorChanged:result[@"friend_id"]]) {
            Friend_list = result[@"friend_id"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
            for (id obj in Friend_list) {
                if ([obj objectForKey:@"uid"]) {
                    [tempArray addObject:[obj objectForKey:@"uid"]];
                }
            }
            friendUidArray = tempArray;
            FriendSet =[NSSet setWithArray:tempArray];
            [self initHomeData];
        }
        
    }];
    
    
}


-(void)showLoading
{
    [SVProgressHUD show];
}

-(BOOL)FavorChanged:(NSMutableArray*)newlist
{
    if (Friend_list) {
        if ([newlist count]!=[Friend_list count]) {
            favorChange =YES;
            return YES;
        }
        else{
            for (int i = 0; i < [newlist count]; i ++)
            {
                if ([[[Friend_list objectAtIndex:i] objectForKey:@"uid"] longLongValue] != [[[newlist objectAtIndex:i] objectForKey:@"uid"] longLongValue])
                {
                    favorChange =YES;
                    return YES;
                }
            }
            favorChange =NO;
            return NO;
        }
    }
    else
    {
        favorChange =YES;
        return YES;
    }
    
}


-(BOOL)isChanged:(NSMutableArray*)newlist
{
    if (Endorse_list) {
        if ([newlist count]!=[Endorse_list count]) {
            shouldReload =YES;
            return YES;
        }
        else{
            for (int i = 0; i < [newlist count]; i ++)
            {
                SLog(@"%lld",[[[Endorse_list objectAtIndex:i] objectForKey:@"uid"] longLongValue]);
                SLog(@"%lld",[[[newlist objectAtIndex:i] objectForKey:@"uid"] longLongValue]);
                if ([[[Endorse_list objectAtIndex:i] objectForKey:@"uid"] longLongValue] != [[[newlist objectAtIndex:i] objectForKey:@"uid"] longLongValue])
                {
                    shouldReload =YES;
                    return YES;
                }
            }
            shouldReload =NO;
            return NO;
        }
    }
    else
    {
        shouldReload =YES;
        return YES;
    }
    
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
            //Set the customView properties
            myMenu = customView.view ;
            customView.view.alpha = 0.0;
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
            
            [clientview.FavorBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_soucang"] forState:UIControlStateNormal];
            [clientview.FavorBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_soucang"] forState:UIControlStateSelected];
            [clientview.FavorBtn addTarget:self action:@selector(FavorShow:) forControlEvents:UIControlEventTouchUpInside];
            
            [clientview.PushBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_tuosong"] forState:UIControlStateNormal];
            [clientview.PushBtn setBackgroundImage:[UIImage imageNamed:@"daiyan_top_list_tuosong"] forState:UIControlStateSelected];
            [clientview.PushBtn addTarget:self action:@selector(pushInfoShow:) forControlEvents:UIControlEventTouchUpInside];
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
    CDBChangeUserInfoController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeUserInfoController"];
    navi.title = @"个人资料";
    [self hiddenMenu];
    
}

- (IBAction)myInfoShow:(id)sender {
    
    CDBChangeUserInfoController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeUserInfoController"];
    navi.title = @"个人资料";
    [self hiddenMenu];
    [self.navigationController pushViewController:navi animated:YES];
}

- (IBAction)bangInfoShow:(id)sender {

    CDBEndorseTableViewController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBEndorseTableViewController"];
    conss.title = @"排行榜";
    //conss.friend_list = Endorse_list;
    conss.isBang = YES;
    [self hiddenMenu];
    [self.navigationController pushViewController:conss animated:YES];

}

- (IBAction)FavorShow:(id)sender {
     CDBEndorseTableViewController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBEndorseTableViewController"];
     navi.title = @"我的收藏";
     //navi.isFavor =YES;
     navi.titlelab.hidden = YES;
     navi.titleLabImage.hidden = YES;
     
     [self hiddenMenu];
     [self.navigationController pushViewController:navi animated:YES];
}

- (IBAction)pushInfoShow:(id)sender {

    [self hiddenMenu];

    NSString* pushURLString = [NSString stringWithFormat:@"%@article.do?sessionid=%@",CDBestieNet,[[NSUserDefaults standardUserDefaults] objectForKey:@"SESSION_ID"]];
    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:pushURLString]];
    webBrowser.showProgress = YES;
    webBrowser.allowOrder = NO;
    webBrowser.allowtoolbar = YES;
    UINavigationSample *webBrowserNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationSample"];
    [webBrowserNC pushViewController:webBrowser animated:NO];
    
    [self presentViewController:webBrowserNC animated:YES completion:NULL];
    

    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if (tableView == mySearchDisplayController.searchResultsTableView) {
        return [self.filteredPersons count];
    }
    else{
        if (Endorse_list) {
            return [Endorse_list count];
        }
    }
    return 0;
    
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isBang) {
        return 90;
    }
    if (tableView == mySearchDisplayController.searchResultsTableView) {
        return 44;
    }
    return 120.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:mySearchDisplayController.searchResultsTableView]){
        
    }else
    {
        mysearchBar.text=@"";
        [mysearchBar resignFirstResponder];
        ACDBEndorseInfoController  * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"ACDBEndorseInfoController"];
        if (isFavor) {
            navi.userUid =   [[Endorse_list objectAtIndex:indexPath.row] longLongValue];
        }
        else{
            navi.userUid = [[[Endorse_list objectAtIndex:indexPath.row] objectForKey:@"uid"] longLongValue];
        }
        if (myUid == navi.userUid) {
            [self myInfoShow:nil];
        }
        else{
        CDBEndorseCell *cell =(CDBEndorseCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        navi.title = cell.userNick.text;
        if ([self compare:cell.celluid]) {
            navi.haveFavor = YES;
        }
        [self.navigationController pushViewController:navi animated:YES];
        }
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [mysearchBar resignFirstResponder];

    return indexPath;
}


-(void)getFavorArray
{
    NSMutableArray *tempArray =[[NSMutableArray alloc]init];
    for (id obj in Endorse_list) {
        if([friendUidArray containsObject:@([[obj objectForKey:@"uid"] longLongValue])])
        {
            if ([tempArray containsObject:@([[obj objectForKey:@"uid"] longLongValue])]) {
                continue;
            }
            [tempArray addObject:@([[obj objectForKey:@"uid"] longLongValue])];
        }
        
    }
    Endorse_favorUidArray = tempArray;
}

-(BOOL)compare:(long long)endorserUid
{
    if([FriendSet containsObject:@(endorserUid)])
    {
        return YES;
    }
    return NO;
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
            cell.favorIcon.hidden =TRUE;
        }

        
        if (isFavor) {
            cell.celluid = [[Endorse_list objectAtIndex:indexPath.row] longLongValue] ;
        }
        else {
            cell.celluid = [[[Endorse_list objectAtIndex:indexPath.row] objectForKey:@"uid"] longLongValue];
        }
        [cell.favorIcon setImage:[UIImage imageNamed:@"daiyan_liebiao_yisoucang"]];
        if (!isFavor) {
            if ([self compare:cell.celluid]) {
                cell.favorIcon.hidden =NO;
            }
        }
        
        
        NSDictionary * parames = @{@"uid":@(cell.celluid)};
        
        [[WebSocketManager instance] sendWithAction:@"user.info2" parameters:parames cdata:GenCdata(12) callback:^(WSRequest *request, NSDictionary *result)
         {
             if(request.error_code!=0)
             {
                 return;
             }
             if ([[request.parm valueForKey:@"uid"] longLongValue]!=cell.celluid) {
                 return;
             }
             NSLog(@"result = %@",result);
             [cell.userIcon.layer setCornerRadius:CGRectGetHeight([cell.userIcon bounds]) / 2];
             cell.userIcon.layer.masksToBounds = YES;
             cell.iconLayer.hidden =YES;
             UserInfo2 *userInfo =[[UserInfo2 alloc]initWithJson:result];
             cell.userNick.text = userInfo.user.nick;
             if(userInfo.user.headpic){
                 NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",userInfo.user.headpic,(int)cell.userIcon.frame.size.width*PIC_QUALITY,(int)cell.userIcon.frame.size.height*PIC_QUALITY];
                 NSURL *imageURL = [NSURL URLWithString:imageString];
                 if (imageURL) {
                     [[ImageDownloader instanse] startDownload:cell.userIcon forUrl:imageURL callback:^(UIView *view, id image) {
                         if(image)
                         {
                             ((UIImageView*)view).image=image;
                         }
                     }];
                 }else
                 {
                     [cell.userIcon setImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
                 }
             }
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
                 infoString = [NSString stringWithFormat:@"%@ | %@ ",user_SEX,user_JOB];
             }
             else
             {
                 infoString = [NSString stringWithFormat:@"%@ | %@ ",user_SEX,user_JOB];
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
             NSArray *tagType = userInfo.endorsement.type;
             NSString *tagString = nil;
             for (id obj in tagType) {
                 if (tagString == nil) {
                     tagString = [NSString stringWithFormat:@"%@",obj];
                 }
                 else
                 {
                     tagString = [NSString stringWithFormat:@"%@|%@",tagString,obj];
                 }
             }
             cell.userGoods.text = tagString;
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
                        [cell.dai_logo  setImage:[UIImage imageNamed:@"daiyan_liebiao_daiyanicon"]];
             if (isBang) {
                 cell.userInfo.text = [NSString stringWithFormat:@"我的积分:%lld",userInfo.endorsement.endorsement_point];
                 [cell.userInfo sizeToFit];
                 cell.userGoods.hidden =YES;
                 cell.dai_logo.hidden = YES;
             }
             
             
         }timeout:UserInfo2_TimeOut];
        return cell;
        
        

}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hiddeErrorText];
    _isSearchBack =YES;
    NSString *searchTerm=[searchBar text];
    [self handleSearchForTerm:searchTerm];
    [searchBar resignFirstResponder];
    
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{//搜索条输入文字修改时触发
    [self hiddeErrorText];
    _isSearchBack =YES;
     if ([self isPureInt:searchText]&&[searchText length]<5) {
     return;
     }
    if([searchText length]==0)
    {
        [self initHomeData];
        [self.tableView reloadData];
        return;
    }
    NSLog(@"searchText = %@",searchText);
    [self handleSearchForTerm:searchText];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _isSearchBack =NO;
    [self initHomeData];
    searchBar.text=@"";
    [self hiddeErrorText];
    [self.tableView reloadData];
    [mysearchBar resignFirstResponder];
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
-(void)handleSearchForTerm:(NSString *)searchString
{
    [self hiddeErrorText];
    NSDictionary * parames = @{@"nick":searchString};
    [[WebSocketManager instance]sendWithAction:@"user.search" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        if(request.error_code!=0)
        {
            [SVProgressHUD dismiss];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
            return;
        }
        self.filteredPersons = result[@"users"];
        NSLog(@"self.filteredPersons = %@",self.filteredPersons);
        if ([self.filteredPersons count]==0) {
            [self showErrorText:[NSString stringWithFormat:@"没有找到\"%@\"相关的结果",searchString]];
        }
        Endorse_list =self.filteredPersons;
        searchS = searchString;
        [self.tableView reloadData];
    }];
}



@end
