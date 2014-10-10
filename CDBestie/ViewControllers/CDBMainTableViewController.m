//
//  CDBMainTableViewController.m
//  CDBestie
//
//  Created by laukevin on 14-10-9.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBMainTableViewController.h"
#import "CDBEndorseTableViewController.h"
#import "CDBLoginNaviController.h"
#import "CDBCompleteUserInfoViewController.h"
#import "CDBplusMenuView.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "CDBChangeUserInfoController.h"
#import "CDBEndorseCell.h"
#import "CDBMainCell.h"
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
#import "CDBFavorNaviController.h"
#import "CDBFavorViewController.h"
#import "RWDropdownMenu.h"
#import "PrivacyViewController.h"

#define PIC_QUALITY (((CDBAppDelegate*)[[UIApplication sharedApplication]delegate]).picQuality)

#define GOODS_HOTEL_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/hotelNew.do?sessionid="


@interface CDBMainTableViewController ()
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
    
    CGSize Picsize;
    CGSize size;
}
@property (readwrite)  BOOL show;
@property (nonatomic,weak) UIImageView *titleLabImage;
@property (nonatomic,weak) UILabel *titlelab;
@property (nonatomic,retain) UISearchBar* mysearchBar;
@property(nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property(nonatomic, copy) NSMutableArray *filteredPersons;
@property(nonatomic) BOOL isFiltered;
@property(nonatomic) BOOL isSearchBack;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation CDBMainTableViewController
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
        //self.tableView.tableHeaderView =mysearchBar;
        //self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(mysearchBar.bounds));
        //占坑专用 过后恢复
        //[self addPic];
        /*
         CGSize navSize = CGSizeMake(15 , 12);
         UIImage *menuImage = [self scaleToSize:[UIImage imageNamed:@"daiyan_list"] size:navSize];
         ;
         UIBarButtonItem * menubar = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleDone target:self action:@selector(menubarClick)];
         self.navigationItem.rightBarButtonItems = @[menubar];
         */
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentMenuFromNav:)];
        [self.webView removeFromSuperview];
        //占坑专用 过后删除
        
        UIImage *myInfoImage = [UIImage imageNamed:@"daiyangeren"];
        UIBarButtonItem * myInfoBar = [[UIBarButtonItem alloc] initWithImage:myInfoImage style:UIBarButtonItemStyleDone target:self action:@selector(myInfoShow:)];
        self.navigationItem.rightBarButtonItems = @[myInfoBar];
        [titlelab removeFromSuperview];
        self.title = @"代言人";
        
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
    NSUserDefaults * settings1 = [NSUserDefaults standardUserDefaults];
    NSString *key1 = [NSString stringWithFormat:@"is_Agree"];
    NSString *value = [settings1 objectForKey:key1];
    if (!value)
    {
        PrivacyViewController * conss =  [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
        [self presentViewController:conss animated:NO completion:nil];
        
    }
    
    
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
    //[self getFriendList];
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
    
    if (isFavor) {
        Endorse_list = Endorse_assignArray;
        [self.tableView reloadData];
        return;
    }
    [self performSelector:@selector(showLoading) withObject:nil afterDelay:.3];
    //网络获取瀑布流图片信息（lewcok）
    ///*
    [[WebSocketManager instance]sendWithAction:@"album.endorsements" parameters:@{@"count":@"10000"} callback:^(WSRequest *request, NSDictionary *result) {
        NSLog(@"error_code = %d",request.error_code);
        NSLog(@"error = %@",request.error);
        if(request.error_code!=0)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
            [SVProgressHUD dismiss];
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
        [SVProgressHUD dismiss];
        NSArray * medias = result[@"media"];
        if (medias > 0) {
            Endorse_list = [NSMutableArray arrayWithArray:medias];
            [self.tableView reloadData];
        }else{
            // [self showErrorText:@"没有私密照片"];
        }
        //[self.view hideIndicatorViewBlueOrGary];
    }];
    //*/

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
    CDBFavorViewController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBFavorViewController"];
    conss.title = @"我的收藏";
    [self getFavorArray];
    conss.favor_EndorseassignArray = Endorse_favorUidArray;
    conss.hidesBottomBarWhenPushed = YES;
    [self hiddenMenu];
    [self.navigationController pushViewController:conss animated:YES];
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
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //return 3;
    ///*
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
    //*/
    
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //cell.Pic.frame.size.width
    SLog(@"%@",Endorse_list);
    if([Endorse_list count]!=0)
    {
    SLog(@"%@",[Endorse_list[indexPath.row] objectForKey:@"width"]);
    SLog(@"%@",[Endorse_list[indexPath.row] objectForKey:@"height"]);
    if (![[Endorse_list[indexPath.row] objectForKey:@"height"] isEqual:[NSNull null]]&&![[Endorse_list[indexPath.row] objectForKey:@"width"] isEqual:[NSNull null]]) {
        CGFloat aFloat = 0;
        aFloat = [UIScreen mainScreen].bounds.size.width/[[Endorse_list[indexPath.row] objectForKey:@"width"] integerValue];
        SLog(@"%f",aFloat);
        SLog(@"%f",[[Endorse_list[indexPath.row] objectForKey:@"height"] integerValue]*aFloat);
        
        Picsize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [[Endorse_list[indexPath.row] objectForKey:@"height"] integerValue]*aFloat);
        
    }
    else
    {
        Picsize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    }
    
    if (isBang) {
        return 90;
    }
    if (tableView == mySearchDisplayController.searchResultsTableView) {
        return 44;
    }
    size.width = Picsize.width;
    size.height = Picsize.height +56.0f;
    return size.height;
    }
    else
        return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
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
     */
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
    
    CDBMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CDBMainCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CDBMainCell alloc] init];
    }
    else{
        [cell.Pic setImage:[UIImage imageNamed:@"shouye_yulantupian"]];
        /*
        cell.userIcon.image=[UIImage imageNamed:@"left_view_avatar_avatar"];
        cell.userNick.text=nil;
        cell.userInfo.text=nil;
        cell.userGoods.text=nil;
        cell.userLevel.hidden=TRUE;
        cell.favorIcon.hidden =TRUE;
         */
    }
    
    
    ///*
    //cell.Pic.frame.size.width
    SLog(@"%@",[Endorse_list[indexPath.row] objectForKey:@"width"]);
    SLog(@"%@",[Endorse_list[indexPath.row] objectForKey:@"height"]);
    if (![[Endorse_list[indexPath.row] objectForKey:@"height"] isEqual:[NSNull null]]&&![[Endorse_list[indexPath.row] objectForKey:@"width"] isEqual:[NSNull null]]) {
        CGFloat aFloat = 0;
        aFloat = [UIScreen mainScreen].bounds.size.width/[[Endorse_list[indexPath.row] objectForKey:@"width"] integerValue];
        SLog(@"%f",aFloat);
        SLog(@"%f",[[Endorse_list[indexPath.row] objectForKey:@"height"] integerValue]*aFloat);
        
        Picsize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [[Endorse_list[indexPath.row] objectForKey:@"height"] integerValue]*aFloat);
        
    }
    else
    {
        Picsize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    }
    // */
    
    
    //通过url方式（lewcok）
    ///*
    NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[Endorse_list[indexPath.row] objectForKey:@"picture"],(int)Picsize.width*PIC_QUALITY,(int)Picsize.height*PIC_QUALITY];
    cell.Pic.frame  = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width,Picsize.height);
    NSURL *imageURL = [NSURL URLWithString:imageString];
    //NSURL *imageURL = [NSURL URLWithString:[Endorse_list[indexPath.row] objectForKey:@"picture"]];
    
    //[cell.firPic setImageWithURL:imageURL];
    [cell.Pic setImage:[UIImage imageNamed:@"shouye_yulantupian"]];
    [[ImageDownloader instanse] startDownload:cell.Pic forUrl:imageURL callback:^(UIView *view, UIImage *image) {
        if(image)
        {
            ((UIImageView*)view).image=image;
        }
    }];
    
    
    NSString *timelbl = [tools timeLabelTextOfTime:[[Endorse_list[indexPath.row] objectForKey:@"time"] longLongValue]];
    
    cell.contentlbl.text = [NSString stringWithFormat:@"发表于 %@",timelbl];
    //cell.contentlbl.text = [Endorse_list[indexPath.row] objectForKey:@"text"];
    //cell.arealbl.text = [Endorse_list[indexPath.row] objectForKey:@"text"];
    
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isFavor) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消收藏";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{   long long celluid = 0;
    if (isFavor) {
        celluid = [[Endorse_list objectAtIndex:indexPath.row] longLongValue] ;
    }
    else {
        celluid = [[[Endorse_list objectAtIndex:indexPath.row] objectForKey:@"uid"] longLongValue];
    }
    {
        NSDictionary * parames = @{@"uid":@(celluid)};
        [[WebSocketManager instance]sendWithAction:@"user.del_friend" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            [SVProgressHUD dismiss];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
            NSLog(@"error_code = %d",request.error_code);
            NSLog(@"error = %@",request.error);
            if(request.error_code!=0)
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
                [SVProgressHUD dismiss];
                return;
            }
            if (editingStyle == UITableViewCellEditingStyleDelete)
            {
                NSMutableArray *tempArray =[[NSMutableArray alloc]initWithArray:Endorse_list];
                [tempArray removeObjectAtIndex:[indexPath row]];
                Endorse_list = tempArray;
                [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }];
    }
    
    
}



#pragma mark dropmenu implementation

- (NSArray *)menuItems
{
    if (!_menuItems)
    {
        _menuItems =
        @[
          [RWDropdownMenuItem itemWithText:@"个人" image:[UIImage imageNamed:@"gerenicon"] action:^{
              [self myInfoShow:nil];
          }],
          [RWDropdownMenuItem itemWithText:@"排行榜" image:[UIImage imageNamed:@"paihangicon"] action:^{
              [self bangInfoShow:nil];
          }],
          [RWDropdownMenuItem itemWithText:@"收藏" image:[UIImage imageNamed:@"shoucangicon"] action:^{
              [self FavorShow:nil];
          }],
          [RWDropdownMenuItem itemWithText:@"每日推送" image:[UIImage imageNamed:@"tuisongicon"] action:^{
              [self pushInfoShow:nil];
          }]
          ];
    }
    return _menuItems;
}

- (void)presentMenuFromNav:(id)sender
{
    RWDropdownMenuCellAlignment alignment = RWDropdownMenuCellAlignmentCenter;
    if (sender == self.navigationItem.leftBarButtonItem)
    {
        alignment = RWDropdownMenuCellAlignmentLeft;
    }
    else
    {
        alignment = RWDropdownMenuCellAlignmentRight;
    }
    
    [RWDropdownMenu presentFromViewController:self withItems:self.menuItems align:alignment style:self.menuStyle navBarImage:[sender image] completion:nil];
}

- (void)presentMenuInPopover:(id)sender
{
    [RWDropdownMenu presentInPopoverFromBarButtonItem:sender withItems:self.menuItems completion:nil];
}

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Black Gradient" image:nil action:^{
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
      }],
      [RWDropdownMenuItem itemWithText:@"Translucent" image:nil action:^{
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      ];
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:self.menuStyle navBarImage:nil completion:nil];
}
@end
