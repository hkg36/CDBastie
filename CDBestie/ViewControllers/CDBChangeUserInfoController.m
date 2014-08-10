//
//  CDBChangeUserInfoController.h
//  CDBestie
//
//  Created by apple on 14-07-30.
//  Copyright (c) 2014年 lifestyle. All rights reserved.

#import <Foundation/Foundation.h>
#import "CDBChangeUserInfoController.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "tools.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
//#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import <Foundation/Foundation.h>
//#import <MobileCoreServices/MobileCoreServices.h>
//#import "LXAPIController.h"
//#import "LXRequestFacebookManager.h"
//#import "XCAlbumAdditions.h"

//#import "MLNetworkingManager.h"
//#import "XCJErWeiCodeViewController.h"
//#import "XCJChangeNickNaviController.h"
//#import "XCJChangeSignNaviController.h"
#import "UIImage+WebP.h"
#import "CDBChangeNickNaviController.h"
#import "CDBChangeNickViewController.h"
#import "CDBChangeSignNaviController.h"
#import "CDBChangeSignViewController.h"
#import "CDBChangeBirthNaviController.h"
#import "CDBChangeJobNaviController.h"


//
//
//#import "XCJSelfPrivatePhotoViewController.h"

#define  RESET_PASSWD_CID  1

@interface CDBChangeUserInfoController ()<UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    UIImage * ImageFile;
    NSMutableArray * dataSource;
}
@property (nonatomic) int sex;
@property (nonatomic) int birth;
@property (nonatomic,strong) NSString *job;
@property (nonatomic) int age;


@property (weak, nonatomic) IBOutlet UIImageView *Image_userIcon;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@property (weak, nonatomic) IBOutlet UILabel *label_sign;
@property (weak, nonatomic) IBOutlet UILabel *Label_address;
@property (weak, nonatomic) IBOutlet UILabel *Label_sex;
@property (weak, nonatomic) IBOutlet UILabel *Label_age;
@property (weak, nonatomic) IBOutlet UILabel *Label_job;
//@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) NSString *areaValue, *cityValue;
@property (weak, nonatomic) IBOutlet UIImageView *firPic;
@property (weak, nonatomic) IBOutlet UIImageView *secPic;
@property (weak, nonatomic) IBOutlet UIImageView *thrPic;
@property (weak, nonatomic) IBOutlet UILabel *picHint;
@property (strong,nonatomic)UserInfo2 *myUserInfo;
@end

@implementation CDBChangeUserInfoController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.Label_nick.text =    [USER_DEFAULT objectForKey:@"USERINFO_NICK"];
    self.label_sign.text =    [USER_DEFAULT objectForKey:@"USERINFO_SIGNATURE"];
     NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[NSString stringWithFormat:@"%@",[USER_DEFAULT objectForKey:@"USERINFO_HEADPIC"]],(int)self.Image_userIcon.frame.size.width,(int)self.Image_userIcon.frame.size.height];
   [self.Image_userIcon setImageWithURL:[NSURL URLWithString:imageString ]  placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
    [self.Image_userIcon.layer setCornerRadius:CGRectGetHeight([self.Image_userIcon bounds]) / 2];
    self.Image_userIcon.layer.masksToBounds = YES;
    _headLayerIcon.hidden =YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSlefHeadpic:) name:@"changeSlefHeadpic" object:nil];
    
    
}




-(void)initUserInfo
{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    self.sex = [defaults integerForKey:@"USERINFO_SEX"];
    self.birth = [defaults integerForKey:@"USERINFO_BIRTH"];
    self.age = [defaults integerForKey:@"USERINFO_AGE"];
    self.job = [defaults objectForKey:@"USERINFO_JOB"];
    

    self.Label_job.text = self.job;
    
    {

            
            if (self.sex == 1||self.sex == 2 ) {
                
                if (self.sex == 2)
                {
                    self.Label_sex.text = @"美女";
                    
                }
                if (self.sex == 1)
                {
                    self.Label_sex.text = @"帅哥";
                }
                
            }
            else
            {
                self.Label_sex.text = @"待定";
            }

            if (self.birth!=0)
            {
                if (self.age) {
                    self.Label_age.text = [NSString stringWithFormat:@"%d",self.age];
                }
                else
                {
                    int birth = self.birth;
                    NSLog(@"birth = %d",birth);
                    NSLog(@"self.birth = %d",self.birth);
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
                    NSLog(@"birth = %d",birth);
                    [USER_DEFAULT setInteger:age forKey:@"USERINFO_AGE"];
                    self.Label_age.text =[NSString stringWithFormat:@"%d",age];
                }
            }
            else
            {
                self.Label_age.text =@"你来问我呀";
                
            }
        
        if(self.job){
            self.Label_job.text =self.job;
        }
        else{
            self.Label_job.text =@"专职闺蜜";
            [defaults setObject:self.Label_job.text forKey:@"USERINFO_JOB"];
        }
        

    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [SVProgressHUD show];
    [self initUserInfo];
    [self showAlbm];
}




-(void)showAlbm
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [[WebSocketManager instance]sendWithAction:@"album.read" parameters:@{@"uid":[defaults objectForKey:@"USERINFO_UID"],@"count":@"4"} callback:^(WSRequest *request, NSDictionary *result) {
        NSLog(@"error_code = %d",request.error_code);
        NSLog(@"error = %@",request.error);
        if(request.error_code!=0)
        {
            [SVProgressHUD dismiss];
            _picHint.hidden = NO;
           _picHint.text = @"加载失败,请检查网络";
            return;
        }
        NSLog(@"%@",result);
        NSArray * medias = result[@"medias"];
        [self hiddenPic];
        if ([medias count]> 0) {
            _picHint.hidden = YES;
            dataSource = [NSMutableArray arrayWithArray:medias];
            
            NSLog(@"%@",dataSource);
            
            _firPic.hidden = NO;
            NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[dataSource[0] objectForKey:@"picture"],(int)_firPic.frame.size.width,(int)_firPic.frame.size.height];
            NSURL *imageURL = [NSURL URLWithString:imageString];

            [_firPic setImageWithURL:imageURL];

            
            if( [dataSource count] >1)
            {
                _secPic.hidden = NO;
                NSString *imageString1 = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[dataSource[1] objectForKey:@"picture"],(int)_firPic.frame.size.width,(int)_firPic.frame.size.height];
                NSURL *imageURL1 = [NSURL URLWithString:imageString1];
                NSLog(@"imageURL1 = %@",imageURL1);
                [_secPic setImageWithURL:imageURL1];
                
            }
            if( [dataSource count] > 2)
            {
                _thrPic.hidden = NO;
                NSString *imageString2 = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",[dataSource[2] objectForKey:@"picture"],(int)_firPic.frame.size.width,(int)_firPic.frame.size.height];
                NSURL *imageURL2 = [NSURL URLWithString:imageString2];
                [_thrPic setImageWithURL:imageURL2];
            }
            [SVProgressHUD dismiss];
        }else{
            _picHint.hidden = NO;
            _picHint.text = @"相册为空";
            [SVProgressHUD dismiss];
        }
    }];


}



-(void)hiddenPic
{
    _firPic.hidden = YES;
    _secPic.hidden = YES;
    _thrPic.hidden = YES;
}



-(void) changeSlefHeadpic:(NSNotification *) notify
{
    NSLog(@"%@",notify.object);
    if (notify.object) {
        [self.Image_userIcon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:notify.object Size:100]] placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
        
    }
}






-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.Label_nick.text =    [USER_DEFAULT objectForKey:@"USERINFO_NICK"];
    self.label_sign.text =    [USER_DEFAULT objectForKey:@"USERINFO_SIGNATURE"];


    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)SeePrivateGalleryClick
{
//    XCJSelfPrivatePhotoViewController * viewss = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelfPrivatePhotoViewController"];
//    viewss.privateUID = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
//    [self.navigationController pushViewController:viewss animated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self openGallery:nil];
                break;
            case 1:
            {
                CDBChangeNickNaviController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeNickNaviController"];
                [self presentViewController:conss animated:YES completion:^{
                    
                }];
            }
                break;
            case 2:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更改性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"美女" otherButtonTitles:@"帅哥",nil];
                    actionSheet.tag = 2;
                    [actionSheet showInView:self.view];
            }
                break;
            case 3:
            {
                CDBChangeBirthNaviController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeBirthNaviController"];
                [self presentViewController:conss animated:YES completion:^{
                    
                }];
            }
                break;
            case 4:
            {
                CDBChangeJobNaviController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeJobNaviController"];
                [self presentViewController:conss animated:YES completion:^{
                    
                }];
            }
                break;
                
            default:
                break;
        }
    }else{
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                {
                    CDBChangeSignNaviController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChangeSignNaviController"];
                    [self presentViewController:conss animated:YES completion:^{
                        
                    }];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        else{

            [self SeePrivateGalleryClick];

        }
    }
    
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 2)
    {
        
        if (buttonIndex == 0)
        {
            [SVProgressHUD show];
            NSDictionary * parames = @{@"sex":@2};
            [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
                [USER_DEFAULT setInteger:2 forKey:@"USERINFO_SEX"];
                [USER_DEFAULT synchronize];
                
                 self.Label_sex.text = @"美女";
                 [SVProgressHUD dismiss];
         }];
            
        }
        if (buttonIndex == 1)
        {
            [SVProgressHUD show];
            NSDictionary * parames = @{@"sex":@1};
            [[WebSocketManager instance]sendWithAction:@"user.update" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
                [USER_DEFAULT setInteger:1 forKey:@"USERINFO_SEX"];
                [USER_DEFAULT synchronize];
                self.Label_sex.text = @"帅哥";
                [SVProgressHUD dismiss];
            }];
            
        }

        }
        


        
    
}

-(IBAction)openGallery:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing  = YES;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self performSelectorInBackground:@selector(uploadContent:) withObject:theInfo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}




- (void)uploadContent:(NSDictionary *)theInfo {

    UIImage * image =  theInfo[UIImagePickerControllerEditedImage];
    [self uploadFile:image];
}


- (void)uploadFile:(UIImage *)filePath {
    
    [SVProgressHUD showWithStatus:@"正在上传头像..."];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString * requestString = [NSString stringWithFormat:@"%@upload/HeadImg?sessionid=%@",CDBestieURLString,[defaults objectForKey:@"SESSION_ID"]];
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [request setTimeoutInterval:3.0];
    NSLog(@"%@\n",requestString);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

        if (data) {
            NSDictionary *messDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSString * token = messDic[@"token"];
            if (token && token.length > 10) {
                TokenAPP = token;
                ImageFile = filePath;
                [self uploadImage:filePath token:token];
            }
        else{
            [SVProgressHUD dismiss];
            UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改失败,请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
}

}
-(void) uploadImage:(UIImage *)filePath  token:(NSString *)token
{
    [self.Image_userIcon setImage:filePath];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    NSData * formDataddd = [UIImage imageToWebP:filePath quality:75];
    operation  = [manager POST:@"http://up.qiniu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:formDataddd name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SLLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSString * stringURL =  [tools getStringValue:[responseObject objectForKey:@"url"] defaultValue:@""];
            
            [USER_DEFAULT setObject:stringURL forKey:@"USERINFO_HEADPIC"];
            [USER_DEFAULT synchronize];
            NSLog(@"USERINFO_HEADPIC = %@",[USER_DEFAULT objectForKey: @"USERINFO_HEADPIC"]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSlefHeadpic" object:stringURL];
            
            [UIView animateWithDuration:0.3 animations:^{
            }];
            [SVProgressHUD dismiss];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        [alert show];
    }];
}

-(void)birthChange{
    UIDatePicker *datePicker = [ [ UIDatePicker alloc] initWithFrame:CGRectMake(0.0,[[UIScreen mainScreen]bounds].size.height-50,[[UIScreen mainScreen]bounds].size.width,50)];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 5;

    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animatio
{
    if (buttonIndex == 1) {
        [SVProgressHUD showWithStatus:@"正在上传头像..."];
        [self uploadImage:ImageFile token:TokenAPP];
    }
}



@end
