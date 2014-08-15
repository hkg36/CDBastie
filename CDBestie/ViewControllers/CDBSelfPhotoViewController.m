//
//  XCJSelfPrivatePhotoViewController.m
//  laixin
//
//  Created by apple on 3/12/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "CDBSelfPhotoViewController.h"
#import "CDBAppDelegate.h"
#import "tools.h"
#import "CDBestieDefines.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+Bootstrap.h"
#import "IDMPhotoBrowser.h"
#import "SVProgressHUD.h"
#import "UIView+Additon.h"
#import "DZWebBrowser.h"
#import "UIImage+Resize.h"
#import "DataHelper.h"


#define DISTANCE_BETWEEN_ITEMS  8.0
#define LEFT_PADDING            8.0
#define ITEM_WIDTH              96.0

@interface CDBSelfPhotoViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSMutableArray * dataSource;
    
    NSMutableArray * dataSource_imageurls;
    
    UIActionSheet * sheetDel;
    
    int deleteIndex;
}
@property (nonatomic,assign) int oneCount;

@end

@implementation CDBSelfPhotoViewController

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
    _oneCount =1;
    // title消息 切换
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketdidFailWithError:) name:@"webSocketdidFailWithError" object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketDidOpen:) name:@"webSocketDidOpen" object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketdidreceingWithMsg:) name:@"webSocketdidreceingWithMsg" object:nil];
    
    
    [super viewDidLoad];
    {
        
        NSMutableArray * array = [[NSMutableArray alloc]init];
        dataSource =array;
    }
    
    {
        NSMutableArray * array = [[NSMutableArray alloc]init];
        dataSource_imageurls =array;
        
    }

    UIScrollView * scrollview = (UIScrollView *) [self.view subviewWithTag:1];
    if (IS_4_INCH) {
        [scrollview setTop:0];
    }
    UIView * viewadd =  [self.view subviewWithTag:2];
    if(self.privateUID == [USER_DEFAULT integerForKey:@"USERINFO_UID"])
    {
        [scrollview setHeight:(APP_SCREEN_HEIGHT - 50)];
        UIButton * button = (UIButton *) [viewadd subviewWithTag:3];
        [button sendMessageStyle];
        [button addTarget:self action:@selector(AddPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [viewadd setTop:(APP_SCREEN_HEIGHT - 50)];
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threadInfoButtonSelected"] style:UIBarButtonItemStyleDone target:self action:@selector(showinfoClick:)];
        
    }else{
        [scrollview setHeight:APP_SCREEN_HEIGHT ];
        [viewadd setTop:APP_SCREEN_HEIGHT];
        [self EchorightItem];
        
    }
    
     if(self.privateUID == [USER_DEFAULT integerForKey:@"USERINFO_UID"])
     {
         NSArray * arrayphoto = nil;//[[EGOCache globalCache] plistForKey:priKey];
         
         if (arrayphoto && arrayphoto.count > 0) {
             dataSource = [arrayphoto mutableCopy];
             [self initScrollview];
         }else{
             [[WebSocketManager instance]sendWithAction:@"album.read" parameters:@{@"uid":@(self.privateUID),@"count":@"10000"} callback:^(WSRequest *request, NSDictionary *result) {
                 NSArray * medias = result[@"medias"];
                 if (medias > 0) {
                     dataSource = [NSMutableArray arrayWithArray:medias];
                     [self initScrollview];
                 }else{
                    // [self showErrorText:@"没有照片"];
                 }
                // [self.view hideIndicatorViewBlueOrGary];
             }];
             
             
         }
     }else{
        // [self.view showIndicatorViewLargeBlue];
         
         [[WebSocketManager instance]sendWithAction:@"album.read" parameters:@{@"uid":@(self.privateUID),@"count":@"10000"} callback:^(WSRequest *request, NSDictionary *result) {
             NSArray * medias = result[@"medias"];
             if (medias > 0) {
                 dataSource = [NSMutableArray arrayWithArray:medias];
                 [self initScrollview];
             }else{
                // [self showErrorText:@"没有照片"];
             }
             //[self.view hideIndicatorViewBlueOrGary];
         }];
     }
//#endif
#if (0)
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults]
         [[WebSocketManager instance]sendWithAction:@"album.read" parameters:@{@"uid":@(self.privateUID),@"count":@"10000"} callback:^(WSRequest *request, NSDictionary *result) {
        NSArray * medias = result[@"medias"];
        NSLog(@"medias = %@",medias);
        if (medias > 0) {
            dataSource = [NSMutableArray arrayWithArray:medias];
            [self initScrollview];
        }else{
            //[self showErrorText:@"没有照片"];
        }
    }];
#endif
}





-(void)initAlbm
{

    {
        
        NSMutableArray * array = [[NSMutableArray alloc]init];
        dataSource =array;
    }
    
    {
        NSMutableArray * array = [[NSMutableArray alloc]init];
        dataSource_imageurls =array;
        
    }
    self.title = @"我的相册";
#if (0)
    UIScrollView * scrollview = (UIScrollView *) [self.view subviewWithTag:1];
    if (IS_4_INCH) {
        [scrollview setTop:0];
    }
    
    UIView * viewadd =  [self.view subviewWithTag:2];
    if([self.privateUID == [USER_DEFAULT integerForKey:@"USERINFO_UID"])
    {
        [scrollview setHeight:(APP_SCREEN_HEIGHT - 50)];
        UIButton * button = (UIButton *) [viewadd subviewWithTag:3];
        [button sendMessageStyle];
        [button addTarget:self action:@selector(AddPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [viewadd setTop:(APP_SCREEN_HEIGHT - 50)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threadInfoButtonSelected"] style:UIBarButtonItemStyleDone target:self action:@selector(showinfoClick:)];
        
    }else{
        [scrollview setHeight:APP_SCREEN_HEIGHT ];
        [viewadd setTop:APP_SCREEN_HEIGHT];
        [self EchorightItem];
        
    }
    
    if([self.privateUID == [USER_DEFAULT integerForKey:@"USERINFO_UID"])
    {
        NSString * priKey = [NSString stringWithFormat:@"PrivatePhotoList_%@",self.privateUID];
        NSArray * arrayphoto = nil;
        if (arrayphoto && arrayphoto.count > 0) {
            dataSource = [arrayphoto mutableCopy];
            [self initScrollview];
        }else{
            [self.view showIndicatorViewLargeBlue];
            
            [[MLNetworkingManager sharedManager] sendWithAction:@"album.read" parameters:@{@"uid":self.privateUID,@"count":@"10000"} success:^(MLRequest *request, id responseObject) {
                NSDictionary * result = responseObject[@"result"];
                NSArray * medias = result[@"medias"];
                if (medias > 0) {
                    [[EGOCache globalCache] setPlist:[medias mutableCopy] forKey:priKey withTimeoutInterval:60*5];
                    dataSource = [NSMutableArray arrayWithArray:medias];
                    [self initScrollview];
                }else{
                    [self showErrorText:@"没有私密照片"];
                }
                [self.view hideIndicatorViewBlueOrGary];
            } failure:^(MLRequest *request, NSError *error) {
                [self showErrorText:@"网络加载失败,请检查网络设置"];
                [self.view hideIndicatorViewBlueOrGary];
            }];
            
            
        }
    }else{
        [self.view showIndicatorViewLargeBlue];
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"album.read" parameters:@{@"uid":self.privateUID,@"count":@"10000"} success:^(MLRequest *request, id responseObject) {
            NSDictionary * result = responseObject[@"result"];
            NSArray * medias = result[@"medias"];
            if (medias > 0) {
                dataSource = [NSMutableArray arrayWithArray:medias];
                [self initScrollview];
            }else{
                [self showErrorText:@"没有私密照片"];
            }
            [self.view hideIndicatorViewBlueOrGary];
        } failure:^(MLRequest *request, NSError *error) {
            [self showErrorText:@"网络加载失败,请检查网络设置"];
            [self.view hideIndicatorViewBlueOrGary];
        }];
    }
#endif
}

-(IBAction)showinfoClick:(id)sender
{
    //
}

-(void) EchorightItem
{

}


-(IBAction)attentClick:(id)sender
{
}



-(IBAction)LikeClick:(id)sender
{
    [self attentClick:nil];
}

-(IBAction)unLikeClick:(id)sender
{
    [self attentClick:nil];
}



-(void) initScrollview
{
    if (dataSource.count  == 0) {
       // [self showErrorText:@"还没有照片"];
    }else{
        //[self showErrorText:@""];
    }
    
    [dataSource_imageurls removeAllObjects];
    UIScrollView * scrollview = (UIScrollView *) [self.view viewWithTag: 1];
    for (UIView * view in scrollview.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    [scrollview reloadInputViews];
    scrollview.contentSize = CGSizeMake(0, 0);
    [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        {
            [dataSource_imageurls addObject:[obj objectForKey:@"picture" ]];
            
            int row = idx/3;
            UIImageView* imageview = [[UIImageView alloc] init];
            [imageview setFrame:CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1),LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row, ITEM_WIDTH, ITEM_WIDTH)];
            imageview.contentMode = UIViewContentModeScaleAspectFill;
            
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
            [recognizer setNumberOfTapsRequired:1];
            [recognizer setNumberOfTouchesRequired:1];
            [imageview addGestureRecognizer:recognizer];
            
            if(self.privateUID == [USER_DEFAULT integerForKey:@"USERINFO_UID"])
            {
                UILongPressGestureRecognizer * longizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longnicger:)];
                longizer.numberOfTouchesRequired = 1;
                [imageview addGestureRecognizer:longizer];
            }
            imageview.tag = idx;
            [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[obj objectForKey:@"picture" ] Size:160]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
            [scrollview addSubview:imageview];
        }
    }];
    
    int row = dataSource.count/3 ;
    
    scrollview.contentSize = CGSizeMake(scrollview.width,LEFT_PADDING + (ITEM_WIDTH + DISTANCE_BETWEEN_ITEMS) * (row +1 ) );
    
}

-(IBAction)longnicger:(id)sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    deleteIndex = buttonSender.tag;    
    if (sheetDel == nil) {
        sheetDel = [[UIActionSheet alloc] initWithTitle:@"删除照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
        sheetDel.tag = 1;
        [sheetDel showInView:self.view];
    }
}

-(IBAction)tagSelected:(id)sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    if (dataSource_imageurls.count > 0) {
        NSArray * arrayPhotos  = [IDMPhoto photosWithURLs:dataSource_imageurls];
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arrayPhotos animatedFromView:buttonSender];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        browser.displayCounterLabel = YES;
        [browser setInitialPageIndex:buttonSender.tag];
        if (buttonSender.image) {
            browser.scaleImage = buttonSender.image;        // Show
        }
        
        [self presentViewController:browser animated:YES completion:nil];
    }
}

- (void)takePhotoClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
        camera.allowsEditing = YES;
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:camera animated:YES completion:nil];
    }
}

- (void)choseFromGalleryClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
        photoLibrary.delegate = self;
        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibrary animated:YES completion:nil];
    }
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *postImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(uploadImage:) withObject:postImage];
}

-(void) uploadImage:(UIImage * ) image
{
    [SVProgressHUD showWithStatus:@"正在上传..."];
        NSString * requestString = [NSString stringWithFormat:@"%@upload/UserExMedia?sessionid=%@&userid=%lld",CDBestieURLString,[USER_DEFAULT objectForKey:@"SESSION_ID"],self.privateUID];
        NSError *error;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        [request setTimeoutInterval:3.0];
        NSLog(@"requestString = %@\n",requestString);
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if(data){
            NSDictionary *responeDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            
            NSLog(@"responeDic = %@",responeDic);
            if (responeDic) {
                NSString * token =  responeDic[@"token"];
                NSLog(@"token = %@",token);
                if (token) {
                    [self uploadimagewithImage:image token:token];
                }else{
                    [self taskMethodDidFailed];
                }
            }
        }

}

-(void) uploadimagewithImage:(UIImage*) image token:(NSString*) token  {
    float quality;
    if (image.size.height > image.size.width) {
        quality = image.size.height/image.size.width;
    }else{
        quality = image.size.width/image.size.height;
    }
    quality = quality/2;
    if (quality > 1) {
        quality = .5;
    }
    UIImage * newimage = [image resizedImage:CGSizeMake(image.size.width * quality, image.size.height * quality) interpolationQuality:kCGInterpolationDefault];
    NSData * FileData = UIImageJPEGRepresentation(newimage, 0.5);
    if (!FileData) {
        FileData  = UIImageJPEGRepresentation(image, 0.5);
    }
    if (FileData) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
        [parameters setValue:token  forKey:@"token"];
        [parameters setValue:@(1) forKey:@"x:filetype"];
        [parameters setValue:@"" forKey:@"x:length"];
        [parameters setValue:@"" forKey:@"x:text"];
        AFHTTPRequestOperation * operation =  [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:FileData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SLog(@"responseObject :%@",responseObject);
            if ([responseObject[@"errno"] intValue] == 0) {
                [self taskMethodDidFinish:responseObject];
            }else{
                [self taskMethodDidFailed];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self taskMethodDidFailed];
        }];
        [operation start];
    }else{
        [self taskMethodDidFailed];
    }
}

-(void) taskMethodDidFinish:(id)responseObject
{
    [SVProgressHUD dismiss];
    if (responseObject) {
        NSDictionary * result =  responseObject[@"result"];
        NSString * did = [DataHelper getStringValue:result[@"did"] defaultValue:@""];
        NSString * url = [DataHelper getStringValue:result[@"url"] defaultValue:@""];
        NSDictionary * jsondict = @{@"picture":url,@"did":did,@"uid":@(self.privateUID),@"text":@"",@"height":@"",@"width":@"",@"time":@"1394591837.0",@"type":@"pic"};
        [dataSource insertObject:jsondict atIndex:0];
        [self initScrollview];
    }
}

-(void) taskMethodDidFailed
{
    [SVProgressHUD dismiss];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            NSDictionary * obj = [dataSource objectAtIndex:deleteIndex];
            if (obj) {
                
                int userDid = [[obj objectForKey:@"did"] integerValue];
                [SVProgressHUD showWithStatus:@"正在删除中..."];
                [[WebSocketManager instance]sendWithAction:@"album.delete" parameters:@{@"did":@(userDid)} callback:^(WSRequest *request, NSDictionary *result) {
                    [dataSource removeObjectAtIndex:deleteIndex];
                    [SVProgressHUD dismiss];
                    [self initScrollview];
                }];
            }else{
                //删除失败
            }
            
        }
        sheetDel = nil;
    }else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [self takePhotoClick];
        }else if(buttonIndex == 1)
        {
            [self choseFromGalleryClick];
        }
    }
}

-(IBAction)AddPhoto:(id)sender
{
    UIActionSheet *  sheet = [[UIActionSheet alloc] initWithTitle:@"添加照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选取", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
