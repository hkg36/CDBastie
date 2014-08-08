//
//  CDBBangTableViewController.m
//  CDBestie
//
//  Created by apple on 14-8-5.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBBangTableViewController.h"
#import "CDBLoginNaviController.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "CDBBangCell.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "tools.h"
//#import "UIImageView+AFNetworking.h"
//#import "SVProgressHUD.h"


@interface CDBBangTableViewController ()
{
    UIView *myMenu;
    NSMutableArray *friend_list;
    
}
@property (readwrite)  BOOL show;
@property (nonatomic,weak) UIImageView *titleLabImage;
@property (nonatomic,weak) UILabel *titlelab;
@property (nonatomic,weak) UILabel *levellbl;
@end

@implementation CDBBangTableViewController
@synthesize titlelab;
@synthesize titleLabImage;
@synthesize levellbl;

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

    [self initHomeData];
    
    
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
}

-(void)initHomeData
{
    [SVProgressHUD show];
    NSDictionary * parames = @{@"uid":[USER_DEFAULT objectForKey:@"USERINFO_UID"],@"pos":@0,@"count":@1000};
    [[WebSocketManager instance]sendWithAction:@"user.friend_list" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        if(request.error_code!=0)
        {
            [SVProgressHUD dismiss];
            return;
        }
        friend_list = result[@"friend_id"];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }];
}


-(IBAction)OpenLoginview:(id)sender
{
    UINavigationController * CDBLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"CDBLoginNaviController"];
    [self presentViewController:CDBLoginNaviController animated:NO completion:nil];
}


- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize{
    UIGraphicsBeginImageContext(newsize);
    [img drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
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
        if ([friend_list count]<10) {
            return [friend_list count];
        }
        else
            return 10;
    }
    return 0;
    
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 80.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDBBangCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CDBBangCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CDBBangCell alloc] init];
    }
    
    cell.celluid = [[[friend_list objectAtIndex:indexPath.row] objectForKey:@"uid"] longLongValue];
    
    // Configure the cell...
    NSString* cell_uid = [[friend_list objectAtIndex:indexPath.row] objectForKey:@"uid"];
    NSLog(@"cell_uid = %@",cell_uid);
    NSDictionary * parames = @{@"uid":cell_uid};
    
    [[WebSocketManager instance]sendWithAction:@"user.info2" parameters:parames callback:^(WSRequest *request, NSDictionary *result)
     {
         if ([[request.parm valueForKey:@"uid"] longLongValue]!=cell.celluid) {
             return;
         }
         [cell.userIcon.layer setCornerRadius:CGRectGetHeight([cell.userIcon bounds]) / 2];
         cell.userIcon.layer.masksToBounds = YES;
         cell.iconLayer.hidden =YES;
         UserInfo2 *userInfo =[[UserInfo2 alloc]initWithJson:result];
         cell.userNick.text = userInfo.user.nick;
         NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",userInfo.user.headpic,(int)cell.userIcon.frame.size.width,(int)cell.userIcon.frame.size.height];
         NSURL *imageURL = [NSURL URLWithString:imageString];
         [cell.userIcon setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
         
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
         
         NSTimeInterval birth = userInfo.user.birthday;
         NSLog(@"birth = %f",birth);
         
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:@"yyyy-MM-dd"];
         NSDate *date = [NSDate dateWithTimeIntervalSince1970:birth];
         
         NSTimeInterval dateDiff = [date timeIntervalSinceNow];
         
         int age=trunc(dateDiff/(60*60*24))/365;
         if (age<0) {
             age = abs(age);
         }
         NSLog(@"age = %d",age);
         NSLog(@"birth = %ld",(long)birth);
         NSString *infoString = [NSString stringWithFormat:@"%@ | %@ | %d岁",user_SEX,user_JOB,age];
         //cell.userInfo.text = infoString;
         
         
         CGSize StringSize = [infoString
                              sizeWithFont:[UIFont systemFontOfSize:18.0f]
                              constrainedToSize:cell.userNick.frame.size
                              lineBreakMode:cell.userNick.lineBreakMode];
         
         
         
         
         //Adjust the size of the UILable
         
         
         cell.userNick.frame = CGRectMake(cell.userNick.frame.origin.x,
                                          cell.userNick.frame.origin.y,
                                          StringSize.width,
                                          StringSize.height);
         cell.userInfo.text = infoString;
         [cell.userNick sizeToFit];
         [cell.userInfo sizeToFit];
         
         cell.userLevel.userInteractionEnabled = NO;
         int value = arc4random()%99;
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
     }];
    return cell;
}


@end
