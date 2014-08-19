//
//  CDBEndorseInfoController.m
//  CDBestie
//
//  Created by apple on 14-8-5.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "ACDBEndorseInfoController.h"
#import "GoodsCell.h"
#import "userInfoCell.h"
#import "DbonusCell.h"
#import "XbonusCell.h"
#import "ablmCell.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "tools.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "DataTools.h"
#import "CDBSelfPhotoViewController.h"
#import "ImageDownloader.h"
#define PIC_QUALITY (((CDBAppDelegate*)[[UIApplication sharedApplication]delegate]).picQuality)
//#import "AFHTTPRequestOperationManager.h"
#define GOODS_HOTEL_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/hotelNew.do?sessionid="
#define GOODS_WINE_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/wineNew.do?sessionid="
#define GOODS_TRAVEL_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/travelNew.do?sessionid="
#define GOODS_CAVALRY_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/cavalryNew.do?sessionid="
#define GOODS_LEBAIHUI_NEW @"http://202.85.215.157:8888/LifeStyleCenter/uidIntercept/lebaihui.do?sessionid="

@interface ACDBEndorseInfoController ()
{
    UserInfo2 *userInfo;
    NSMutableArray * AblmdataSource;
    NSArray * UrlArray;
    UISearchBar *mySearchBar;
}
@end

@implementation ACDBEndorseInfoController
@synthesize  Image_userIcon;
@synthesize  Label_nick;
@synthesize  label_info;
@synthesize  levelBtn;
@synthesize  Label_daiyanjifen;
@synthesize  Label_xiaofeijifen;
@synthesize  firPic;
@synthesize  secPic;
@synthesize  thrPic;
@synthesize  goodsIcon;
@synthesize  goodsName;
@synthesize  goodsInfo;
@synthesize userUid;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{   [SVProgressHUD show];
    [super viewDidLoad];
    UrlArray = @[GOODS_LEBAIHUI_NEW,GOODS_HOTEL_NEW,GOODS_WINE_NEW,GOODS_TRAVEL_NEW,GOODS_CAVALRY_NEW];
    
    NSDictionary * parames = @{@"uid":@(self.userUid)};
    //[[WebSocketManager instance]sendWithAction:@"user.info2" parameters:parames callback:^(WSRequest *request, NSDictionary *result)
     [[WebSocketManager instance] sendWithAction:@"user.info2" parameters:parames cdata:GenCdata(12) callback:^(WSRequest *request, NSDictionary *result)
     {
         
         if(request.error_code!=0)
         {
             return;
         }
         [self initAlbm];
         NSLog(@"result = %@",result);
         userInfo = [[UserInfo2 alloc]initWithJson:result];
         [self.tableView reloadData];
     }timeout:UserInfo2_TimeOut];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%ld",(long)section);
    if (section == 0) {
        return 4;
    }
    else
    {
        return [userInfo.endors_list count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 37.5f;
    }
    else{
        return 27.5f;
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return @"个人资料";
    }
    else{
        return @"代言产品";
    }
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return 75.0f;
                break;
            case 1:
                return 39.0f;
                break;
            case 2:
                return 39.0f;
                break;
            default:
                return 58.5f;
                break;
        }
        
    }
    return 94.5f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsCell *cell;
    if (indexPath.section == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[GoodsCell alloc] init];
        }
        NSArray *cs=[userInfo.endors_list[indexPath.row] valueForKey:@"merchandise"];
        
        
        cell.name.text = [cs valueForKey:@"productname"];
        cell.Introduction.text =[userInfo.endors_list[indexPath.row] valueForKey:@"slogan"];
        
        NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[cs valueForKey:@"icon_url"],(int)cell.Icon.frame.size.width*PIC_QUALITY,(int)cell.Icon.frame.size.height*PIC_QUALITY];
        NSURL *imageURL = [NSURL URLWithString:imageString];
        if (imageURL) {
            [[ImageDownloader instanse] startDownload:cell.Icon forUrl:imageURL callback:^(UIView *view, UIImage *image) {
                if(image)
                {
                    ((UIImageView*)view).image=image;
                }
            }];
        }
        else
        {
            [cell.Icon setImage:[UIImage imageNamed:@"shangping_morentu"]];
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
            {
                
                userInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[userInfoCell alloc] init];
                }
                [cell.userIcon.layer setCornerRadius:CGRectGetHeight([cell.userIcon bounds]) / 2];
                cell.userIcon.layer.masksToBounds = YES;
                cell.userLayerIcon.hidden =YES;
                
                cell.userNickname.text = userInfo.user.nick;
                NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",userInfo.user.headpic,(int)cell.userIcon.frame.size.width*PIC_QUALITY,(int)cell.userIcon.frame.size.height*PIC_QUALITY];
                NSURL *imageURL = [NSURL URLWithString:imageString];
                if (imageURL) {
                    [[ImageDownloader instanse] startDownload:cell.userIcon forUrl:imageURL callback:^(UIView *view, id image) {
                        if(image)
                        {
                            ((UIImageView*)view).image=image;
                        }
                    }];
                }
                else
                {
                    [cell.userIcon setImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
                }
                cell.userIconUrl = [NSString stringWithFormat:@"%@?imageView2/1",userInfo.user.headpic];
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
                                     constrainedToSize:cell.userNickname.frame.size
                                     lineBreakMode:cell.userNickname.lineBreakMode];
                cell.userNickname.frame = CGRectMake(cell.userNickname.frame.origin.x,
                                                     cell.userNickname.frame.origin.y,
                                                     StringSize.width,
                                                     StringSize.height);
                cell.userInfo.text = infoString;
                [cell.userNickname sizeToFit];
                [cell.userInfo sizeToFit];
                int value = userInfo.endorsement.level;
                [cell.userLevel setTitle:[NSString stringWithFormat:@"LV%d",value] forState:UIControlStateNormal];
                if (value == 0) {
                    [cell.userLevel setBackgroundImage:[UIImage imageNamed:@"daiyan_liebiao_lingjiicon"] forState:UIControlStateNormal];
                    [cell.userLevel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                else
                {
                    [cell.userLevel setBackgroundImage:[UIImage imageNamed:@"daiyan_liebiao_dengjiicon"] forState:UIControlStateNormal];
                    [cell.userLevel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                [cell.userNickname sizeToFit];
                CGRect frame = cell.userNickname.frame;
                cell.userLevel.frame =CGRectMake(frame.origin.x+frame.size.width+5, cell.userLevel.frame.origin.y, cell.userLevel.frame.size.width, cell.userLevel.frame.size.height);
                [cell.userLevel.titleLabel sizeToFit];
                cell.userLevel.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                
                
                return cell;
            }
                break;
            case 1:
            {
                DbonusCell *cell;
                cell = [tableView dequeueReusableCellWithIdentifier:@"DbonusCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[DbonusCell alloc] init];
                }
                cell.Dbonus.text = [NSString stringWithFormat:@"%lld",userInfo.endorsement.endorsement_point];;
                return cell;
            }
                break;
            case 2:
            {
                XbonusCell *cell;
                cell = [tableView dequeueReusableCellWithIdentifier:@"XbonusCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[XbonusCell alloc] init];
                }
                cell.Xbonus.text = [NSString stringWithFormat:@"%lld",userInfo.endorsement.consumer_point];
                return cell;
            }
                break;
            case 3:
            {
                ablmCell *cell;
                cell = [tableView dequeueReusableCellWithIdentifier:@"ablmCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[ablmCell alloc] init];
                }
                
                
                if ([AblmdataSource count]> 0) {
                    NSLog(@"%@",AblmdataSource);
                    NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[AblmdataSource[0] objectForKey:@"picture"],(int)cell.firPic.frame.size.width*PIC_QUALITY,(int)cell.firPic.frame.size.height*PIC_QUALITY];
                    NSURL *imageURL = [NSURL URLWithString:imageString];
                        [[ImageDownloader instanse] startDownload:cell.firPic forUrl:imageURL callback:^(UIView *view, id image) {
                            if(image)
                            {
                                ((UIImageView*)view).image=image;
                            }
                        }];

                    
                    if( [AblmdataSource count] >1)
                    {
                        NSString *imageString1 = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[AblmdataSource[1] objectForKey:@"picture"],(int)cell.secPic.frame.size.width*PIC_QUALITY,(int)cell.secPic.frame.size.height*PIC_QUALITY];
                        NSURL *imageURL1 = [NSURL URLWithString:imageString1];
                        NSLog(@"imageURL1 = %@",imageURL1);
                            [[ImageDownloader instanse] startDownload:cell.secPic forUrl:imageURL1 callback:^(UIView *view, id image) {
                                if(image)
                                {
                                    ((UIImageView*)view).image=image;
                                }
                            }];
                        
                    }
                    if( [AblmdataSource count] > 2)
                    {
                        cell.thirPic.hidden = NO;
                        NSString *imageString2 = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[AblmdataSource[2] objectForKey:@"picture"],(int)cell.thirPic.frame.size.width*PIC_QUALITY,(int)cell.thirPic.frame.size.height*PIC_QUALITY];
                        NSURL *imageURL2 = [NSURL URLWithString:imageString2];
                            [[ImageDownloader instanse] startDownload:cell.thirPic forUrl:imageURL2 callback:^(UIView *view, id image) {
                                if(image)
                                {
                                    ((UIImageView*)view).image=image;
                                }
                            }];
                    }
                    
                }else{
                }
                
                
                
                return cell;
            }
                break;
        }
        
    }
    
    return cell;
}

-(void)initAlbm
{
    NSDictionary * parames = @{@"uid":@(self.userUid),@"count":@"4"};
    [[WebSocketManager instance]sendWithAction:@"album.read" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
        [SVProgressHUD dismiss];
        NSLog(@"error_code = %d",request.error_code);
        NSLog(@"error = %@",request.error);
        if(request.error_code!=0)
        {
            [SVProgressHUD dismiss];
            return;
        }
        
        NSLog(@"%@",result);
        NSArray * medias = result[@"medias"];
        //[self hiddenPic];
        if ([medias count]> 0) {
            AblmdataSource = [NSMutableArray arrayWithArray:medias];
            
            NSLog(@"%@",AblmdataSource);
            [self.tableView reloadData];
            
        }
    }];
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            NSString *myTitle = self.title;
            CDBSelfPhotoViewController * viewss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBSelfPhotoViewController"];
            viewss.title =[NSString stringWithFormat:@"%@的相册",myTitle];
            viewss.privateUID = self.userUid;
            [self.navigationController pushViewController:viewss animated:YES];
        }
        
    }
    if (indexPath.section == 1) {
        {
            NSArray *cs=[userInfo.endors_list[indexPath.row] valueForKey:@"merchandise"];
            DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?sessionid=%@&sid=%lld",[cs valueForKey:@"show_post_url"],[[NSUserDefaults standardUserDefaults] objectForKey:@"SESSION_ID"],self.userUid]]];
            //webBrowser.showProgress = YES;
            webBrowser.allowOrder = YES;
            webBrowser.allowtoolbar = NO;
            UINavigationSample *webBrowserNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationSample"];
            [webBrowserNC pushViewController:webBrowser animated:NO];
            [self presentViewController:webBrowserNC animated:YES completion:NULL];
            
        }
    }
}

#if (0)

- (IBAction)seeUserIconClick:(id)sender {
    if (self.Image_user.image) {
        if ([[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id] isEqualToString:self.UserInfo.uid]) {
            [SJAvatarBrowser showImage:self.Image_user withURL:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]];
        }else{
            [SJAvatarBrowser showImage:self.Image_user withURL:self.UserInfo.headpic];
        }
    }
    
}
#endif



@end
