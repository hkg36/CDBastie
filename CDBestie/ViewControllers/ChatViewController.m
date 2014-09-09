//
//  ChatViewController.m
//  ISClone
//
//  Created by Molon on 13-12-4.
//  Copyright (c) 2013年 Molon. All rights reserved.
//
#import <limits.h>
#import "ChatViewController.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "User.h"
#import "tools.h"
#import "UIView+Additon.h"
#import "ImageDownloader.h"
#import "CDBChatMessageCell.h"
#import "CDBMyChatMessageCell.h"
#import "UIImage+Resize.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"
#import "DataTools.h"
#import "MJRefresh.h"
#import "ImageDownloader.h"
#import "UIView+Convenience.h"
#import "NSString+FontAwesome.h"
#import "SVProgressHUD.h"

#define PIC_QUALITY (((CDBAppDelegate*)[[UIApplication sharedApplication]delegate]).picQuality)
#define MESSAGE_COUNT_PAGE  20
#define  audioLengthDefine  1050

#import <AudioToolbox/AudioToolbox.h>
#import "FacialView.h"
#import "NSString+Addition.h"
#import "CDBChatSendImgViewController.h"
#import "CDBChatSendInfoView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIButton+Bootstrap.h"

#define  keyboardHeight 216
#define  facialViewWidth 300
#define facialViewHeight 180
#define  audioLengthDefine  1050

@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,facialViewDelegate,CDBChatSendInfoViewDelegate,CDBChatSendImgViewControllerdelegate,UIScrollViewDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    UIImage * ImageFile;
    NSString * PasteboardStr;
    NSArray * userArray;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    UIView  * EmjView;
    CDBChatSendInfoView *SendInfoView;
    NSURL * playingURL;
    CDBChatMessageCell * playingCell;
    
    BOOL _loading;
    BOOL AllLoad;
    BOOL AllDBdatabaseLoad;
    NSInteger _currentPage;
    NSInteger mess_amout;
}
@property (weak, nonatomic) IBOutlet UIView      *inputContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView  *inputTextView;
@property (weak, nonatomic) UIView               *keyboardView;
@property (strong,nonatomic) NSMutableArray      *messageList;
- (IBAction)reportAction:(id)sender;



@property (weak, nonatomic) IBOutlet UILabel *label_titleToast;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityindret;


@end

@implementation ChatViewController
@synthesize messUid;

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
    
    int badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if(badge > 0)
    {
        badge--;
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    }

    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    self.tableView.headerRefreshingText = @"正在加载数据...";
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:panRecognizer];
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    self.messageList =array;
    
    [self initMessageData];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    [self scrollToBottonWithAnimation:NO];
    if (![self.messageList count]) {
        self.label_titleToast.text = @"开始和ta聊天吧～";
    }
       UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
    
    
    UIButton * buttonAudio8 = (UIButton *) [self.inputContainerView subviewWithTag:8];
    
    [buttonAudio8 addTarget:self action:@selector(ShowkeyboardButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    self.inputContainerView.top = self.view.height - self.inputContainerView.height;
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.inputContainerView.top = self.view.height - self.inputContainerView.height;
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    NSString *pushtype = @"newmsg";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketDidReceivePushMessage:)
                                                 name:[NSString stringWithFormat:@"%@%@",NotifyPushPrifix,pushtype]
                                               object:nil];
}

- (void)headerRereshing
{
    _currentPage++;
    Db *db = [Db currentDb];
	NSArray * message = [db loadAndFill:[NSString stringWithFormat: @"SELECT id, msgid,fromid,toid,content,picture,video,voice,width,height,length,time,lat,lng FROM (select * from Message where msgid<%lld  and ((fromid = %lld and toid=%ld) or (toid = %lld and fromid=%ld))   ORDER BY msgid desc limit %d) ORDER BY msgid asc;",LLONG_MAX,self.messUid,(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"],self.messUid,(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"],(_currentPage+1)*MESSAGE_COUNT_PAGE] theClass:[Message class]];
    SLog(@"message count = %lu",(unsigned long)[message count]);
    {
        self.messageList =(NSMutableArray*)message;
        NSLog(@"self.messageList = %@",self.messageList);
        
        
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (mess_amout > [self.messageList count]) {
            [self viewdidloadmore];
        }
        else {
            [self viewdidloadedComplete];
        }
        [self.tableView headerEndRefreshing];
    });
}




-(void)initMessageData
{
    Db *db = [Db currentDb];
	NSArray * message_Amount = [db loadAndFill:[NSString stringWithFormat: @"select * from Message where msgid<%lld  and ((fromid = %lld and toid=%ld) or (toid = %lld and fromid=%ld))",LLONG_MAX,self.messUid,(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"],self.messUid,(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"]] theClass:[Message class]];
    mess_amout = [message_Amount count];
	NSArray * message = [db loadAndFill:[NSString stringWithFormat: @"SELECT id, msgid,fromid,toid,content,picture,video,voice,width,height,length,time,lat,lng FROM (select * from Message where msgid<%lld  and ((fromid = %lld and toid=%ld) or (toid = %lld and fromid=%ld))   ORDER BY msgid desc limit %d) ORDER BY msgid asc;",LLONG_MAX,self.messUid,(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"],self.messUid,(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"],MESSAGE_COUNT_PAGE] theClass:[Message class]];
    SLog(@"message count = %lu",(unsigned long)[message count]);
    {
        self.messageList =(NSMutableArray*)message;
        SLog(@"self.messageList = %@",self.messageList);
        if (mess_amout > [self.messageList count]) {
            [self viewdidloadmore];
        }
        else {
        [self viewdidloadedComplete];
        }

    }
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollViewDat
{
}

- (void) viewdidloadedComplete
{
    self.activityindret.hidden = YES;
    self.label_titleToast.text = @"全部加载完成";
}

- (void) viewdidloading
{
    self.activityindret.hidden = NO;
    self.label_titleToast.text = @"加载中...";
}

- (void) viewdidloadmore
{
    self.activityindret.hidden = YES;
    self.label_titleToast.text = @"下拉加载更多";
}

-(IBAction)ShowkeyboardButtonClick:(id)sender
{
    ( (UIButton *) [self.inputContainerView subviewWithTag:8]).hidden = YES;
    ( (UIButton *) [self.inputContainerView subviewWithTag:7]).hidden = NO;
    ( (UIButton *) [self.inputContainerView subviewWithTag:9]).hidden = YES;
    [self.inputTextView becomeFirstResponder];
    
}

- (int) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    [scrollView setContentOffset:CGPointMake(320 * page, 0)];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollViewDat
{
    if ([scrollViewDat isKindOfClass:[UITableView class]]) {
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        if ([self.inputTextView isFirstResponder]) {
            [self.inputTextView resignFirstResponder];
            
        }

    }

}


- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{

    CGSize sizePre = self.tableView.size;
    int preHeight = sizePre.height;
    NSDictionary * MsgContent  = notification.userInfo;
    SLLog(@"MsgContent :%@",MsgContent);
    if ([[MsgContent [@"message"] objectForKey:@"fromid"] longLongValue] != self.messUid) {
        return;
    }
    
    [self.messageList addObject:[[Message alloc] initWithJson:[MsgContent objectForKey:@"message"]]];
    [self.tableView reloadData];
    
    CGSize sizeNew = self.tableView.contentSize;
    
    float contentTop =  sizeNew.height - preHeight;
    SLog(@"contentTop = %f",contentTop);
    [self.tableView setContentOffset:CGPointMake(0,  contentTop) animated:NO];
}

- (void)dealloc
{

    scrollView.delegate  = nil;
    [_tableView setDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)SendTextMsgClick:(id)sender {
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    button.userInteractionEnabled = NO;
        NSString * text = self.inputTextView.text;
        if ([text trimWhitespace].length > 0) {
            NSDictionary * parames = @{@"uid":@(self.messUid),@"content":text};
            [[WebSocketManager instance]sendWithAction:@"message.send" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
                SLog(@"%@",result);
                if(request.error_code!=0)
                {
                    return;
                }
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSTimeInterval dateDiff = [[NSDate date] timeIntervalSince1970];
                
                Message *msg = [[Message alloc] init];
                msg.content = text;
                msg.msgid = [[result objectForKey:@"msgid"] longLongValue];
                msg.time = dateDiff;
                msg.toid = self.messUid;
                msg.fromid = [[USER_DEFAULT objectForKey:@"USERINFO_UID"] longLongValue];
                self.inputTextView.text = @"";
                Db *db = [Db currentDb];
                [db save:msg];
                SLog(@"%d",msg.Id);
                [self.messageList addObject:msg];
                
                [self insertTableRow];
            }];
            }
    }



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
    }
}
- (IBAction)adjustKeyboardFrame:(id)sender {

}


- (IBAction)addImage:(id)sender {
    /*
       if (SendInfoView == nil) {
        SendInfoView = [[[NSBundle mainBundle] loadNibNamed:@"CDBChatSendInfoView" owner:self options:nil] lastObject];
        SendInfoView.delegate = self;
    }
    
    if(!self.inputTextView.isFirstResponder)
    {
        [self.inputTextView becomeFirstResponder];
    }
    self.inputTextView.inputView = nil;
    self.inputTextView.inputView = SendInfoView;
    [self.inputTextView reloadInputViews];
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = YES;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = NO;
    
*/
}
- (void)takePhotoClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
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


#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 3) {
        switch (buttonIndex) {
            case 0:{
                UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"举报成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
            case 1:{
                UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"举报成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
            default:
                break;
        }
    }
    if (actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                    camera.delegate = self;
                    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:camera animated:YES completion:nil];
                }
            }
                break;
            case 1:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
                    photoLibrary.delegate = self;
                    photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:photoLibrary animated:YES completion:nil];
                }
            }
                break;
            default:
                break;
        }
    }
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0:
            {
                if (PasteboardStr) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:PasteboardStr];
                }
            }
                break;
                
            default:
                break;
        }
    }

}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self performSelector:@selector(uploadContent:) withObject:theInfo];
    
}

- (void) SendImageURL:(UIImage * ) url  withKey:(NSString *) key
{
//    [SVProgressHUD showWithStatus:@"正在发送..."];
    [self uploadFile:url  key:key];
}

- (void)uploadContent:(NSDictionary *)theInfo {
    CDBChatSendImgViewController * chatImgView = [self.storyboard instantiateViewControllerWithIdentifier:@"CDBChatSendImgViewController"];
    UIImage *image = theInfo[UIImagePickerControllerOriginalImage];
     UIImage * newimage = [image resizedImage:CGSizeMake(image.size.width, image.size.height) interpolationQuality:kCGInterpolationDefault];
    if (!newimage) {
        chatImgView.imageviewSource = image;
    }else{
        chatImgView.imageviewSource = newimage;
    }
    
    chatImgView.delegate = self;
    [self presentViewController:chatImgView animated:YES completion:^{
    }];
    
}

- (void)uploadFile:(UIImage *)image  key:(NSString *)key {
       NSDictionary * parames = @{};
    SLog(@"start send....");
    [[WebSocketManager instance]sendWithAction:@"tools.qiniu_uploadtoken" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        [SVProgressHUD dismiss];
        SLog(@"request = %@",request);
        SLog(@"result = %@",result);
        if(request.error_code!=0)
        {

            SLog(@"request.error = %@",request.error);
            return;
        }
       
        {
            NSString * token =  result[@"token"];
            NSLog(@"token = %@",token);
            if (token) {

                [self uploadImage:image token:token];
            }else{

            }
        }
        
    }];
}

-(void) uploadImage:(UIImage *)image  token:(NSString *)token
{
    SLog(@"start uploading....");
    [SVProgressHUD show];
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
                NSDictionary *tempArray = [[NSDictionary alloc]init];
                tempArray = responseObject;
                NSString *picUrl = [tempArray objectForKey:@"url"];
                SLog(@"picUrl = %@",picUrl);
               
                [self sendPic:picUrl];
                
                
            }else{
                [SVProgressHUD dismiss];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD dismiss];
        }];
        [operation start];
    }else{
        [SVProgressHUD dismiss];
    }

    
    
    NSString *key = [NSString stringWithFormat:@"%@%@", [self getMD4HashWithObj], @".jpg"];
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSData *webData = UIImageJPEGRepresentation(image, 0.5f);
    [webData writeToFile:file atomically:YES];
}

-(NSString * ) getMD4HashWithObj
{
    NSTimeInterval doub = [[NSDate date] timeIntervalSinceNow];
    int x = arc4random() % 1000000;
    NSString * guid = [[NSString stringWithFormat:@"%f%d",doub, x] md5Hash];
    SLLog(@"gener guid: %@",guid);
    return guid;
}


-(void)sendPic:(NSString*)picUrl
{
    NSDictionary * parames = @{@"uid":@(self.messUid),@"picture":picUrl};
    SLog(@"start send....");
    [[WebSocketManager instance]sendWithAction:@"message.send" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        [SVProgressHUD dismiss];
        SLog(@"request = %@",request);
        SLog(@"result = %@",result);
        if(request.error_code!=0)
        {
            SLog(@"request.error = %@",request.error);
            return;
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSTimeInterval dateDiff = [[NSDate date] timeIntervalSince1970];
        Message *msg = [[Message alloc ]init];
        msg.time = dateDiff;
        msg.picture = picUrl;
        msg.msgid = [[result objectForKey:@"msgid"] longLongValue];
        msg.time = dateDiff;
        msg.toid = self.messUid;
        msg.fromid = [[USER_DEFAULT objectForKey:@"USERINFO_UID"] longLongValue];
        self.inputTextView.text = @"";
        Db *db = [Db currentDb];
        [db save:msg];
        SLog(@"%d",msg.Id);
        [self.messageList addObject:msg];
        
        [self insertTableRow];
    }];

}


- (void) insertTableRow
{
    
    [self.tableView reloadData];
    [self scrollToBottonWithAnimation:YES];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
      NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    BOOL isPrior = [((NSNumber *)[change objectForKey:NSKeyValueChangeNotificationIsPriorKey]) boolValue];
    if (isPrior&&[kind integerValue] != NSKeyValueChangeRemoval) {
        return;
    }
    NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
    if (indices == nil){
        return;
    }
    
    NSUInteger indexCount = [indices count];
    NSUInteger buffer[indexCount];
    [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indexCount; i++) {
        NSUInteger indexPathIndices[2];
        indexPathIndices[0] = 0;
        indexPathIndices[1] = buffer[i];
        NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
        [indexPathArray addObject:newPath];
    }
    if ([kind integerValue] == NSKeyValueChangeInsertion){
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        [self scrollToBottonWithAnimation:YES];
    }
    else if ([kind integerValue] == NSKeyValueChangeRemoval){
        if (isPrior) {
        }else{
            [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        }
    }
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SLog(@"%lu",(unsigned long)self.messageList.count);
    return self.messageList.count;
}


-(float) heightforsystem14:(NSString * ) text withWidth:(float) width
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.height + 15 );
}

-(float) widthforsystem14:(NSString * ) text withWidth:(float) width
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.width + 10 );
}

#pragma mark  cellfor
#pragma mark number 13

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDBChatMessageCell * msgcell =(CDBChatMessageCell*) cell;
    UILabel * labelContent = (UILabel *) [msgcell.contentView subviewWithTag:4];
    [labelContent sizeToFit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message * message =self.messageList[ indexPath.row];
    SLog(@"message ID :%lld",message.msgid);
        NSString *CellIdentifier;
#pragma mark  from

    if (message.fromid == self.messUid)
        CellIdentifier = @"CDBChatMessageCell";
    else
        CellIdentifier = @"CDBMyChatMessageCell";
    
        CDBChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UIImageView * imageview = (UIImageView *) [cell.contentView viewWithTag:1];
    UILabel * labelName = (UILabel *) [cell.contentView viewWithTag:2];
    UILabel * labelTime = (UILabel *) [cell.contentView viewWithTag:3];
    UILabel * labelContent = (UILabel *) [cell.contentView viewWithTag:4];
    labelContent.font = [UIFont systemFontOfSize:16.0f];
    UILabel * address = (UILabel *) [cell.contentView viewWithTag:8];
    UIActivityIndicatorView * indictorView = (UIActivityIndicatorView *) [cell.contentView viewWithTag:9];
    UIButton * retryButton = (UIButton *) [cell.contentView viewWithTag:10];
    UIButton * audioButton = (UIButton *) [cell.contentView viewWithTag:11];
    UIImageView * Image_playing = (UIImageView*)[cell.contentView viewWithTag:12];
    
    UIImageView * imageview_Img = (UIImageView *)[cell.contentView viewWithTag:5];
    UIImageView * imageview_BG = (UIImageView *)[cell.contentView viewWithTag:6];
    if (message.fromid == self.messUid){
    labelName.text = self.title;
    
    NSURL *imageURL = [NSURL URLWithString:self.messHeadPic];
            if (imageURL) {
        [[ImageDownloader instanse] startDownload:imageview forUrl:imageURL callback:^(UIView *view, UIImage *image) {
            SLog(@"%@",image);
            if([view isKindOfClass:[UIImageView class]])
            {
                ((UIImageView*)view).image=image;
            }
        }];
                }
            else
            {
        [imageview setImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
            }
    }
    else{
        labelName.text = [USER_DEFAULT objectForKey:@"USERINFO_NICK" ];
        labelContent.textColor = [UIColor whiteColor];
        NSURL *imageURL = [NSURL URLWithString:[USER_DEFAULT objectForKey:@"USERINFO_HEADPIC" ]];
        if (imageURL) {
            [[ImageDownloader instanse] startDownload:imageview forUrl:imageURL callback:^(UIView *view, UIImage *image) {
                NSLog(@"%@",image);
                if([view isKindOfClass:[UIImageView class]])
                {
                    ((UIImageView*)view).image=image;
                }
            }];
        }
        else
        {
            [imageview setImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
        }
    
    }
    
    
    
    int ssinde = indexPath.row%3;
    if (ssinde == 0) {
        labelTime.layer.cornerRadius = 4.0;
        labelTime.layer.masksToBounds = YES;
        labelTime.hidden = NO;
    }else{
        
        labelTime.hidden = YES;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.time];
    labelTime.text = [tools FormatStringForDate:date];
    audioButton.left = 400.0f;
    
    [indictorView stopAnimating];
    indictorView.hidden = YES;
    retryButton.hidden = YES;
    if (message.video){
        ;
    }else
    {
        if (message.voice)
        {
        
        }else
        {
            if (message.picture)
                {
                    {
                        labelContent.text  = @"";
                        
                        
                        NSString *imageString = [NSString stringWithFormat:@"%@\?imageView2/1/w/%i/h/%i",message.picture,(int)115*PIC_QUALITY,108*PIC_QUALITY];
                        NSURL *imageURL = [NSURL URLWithString:imageString];
                        if (imageURL) {
                            [[ImageDownloader instanse] startDownload:imageview_Img forUrl:imageURL callback:^(UIView *view, id image) {
                                if(image)
                                {
                                    ((UIImageView*)view).image=image;
                                }
                            }];
                        }else
                        {
                            [imageview_Img setImage:[UIImage imageNamed:@"aio_image_default"]];
                        }
                        imageview_Img.userInteractionEnabled = YES;
                        UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeBigImageviewClick:)];
                        cell.bigImageUrl = message.picture;
                        [imageview_Img addGestureRecognizer:ges];
                        
                        imageview_Img.hidden = NO;
                        
                        [imageview_BG setHeight:108.0f];
                        [imageview_BG setWidth:115.0f];

                            [imageview_BG setLeft:55.0f];
                            [imageview_Img setLeft:65.0f];
                            
                            
                        if (message.fromid==self.messUid)
                        {
                            [imageview_BG setLeft:55.0f];
                            [imageview_Img setLeft:65.0f];
                            
                            
                            indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
                            indictorView.top = imageview_BG.height/2  + 20;
                            
                            retryButton.left = imageview_BG.left + imageview_BG.width  ;
                            retryButton.top = imageview_BG.height/2  + 10;
                            
                        }
                        else
                        {
                            [imageview_BG setLeft:147 ];
                            [imageview_Img setLeft:152.0f];
                            
                            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
                            indictorView.top = imageview_BG.height/2  + 20;
                            
                            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 -10 ;
                            retryButton.top = imageview_BG.height/2  + 10;
                        }

                            
                        
                        [imageview_Img setHeight:100.0f];
                        [imageview_Img setWidth:100.0f];
                        
                        imageview_BG.hidden = NO;
                        
                        address.text = @"";
                        address.hidden = YES;
                        
                        
                    }

            }
            else
            {
                if ([message.content containString:@"sticker_"]) {
                    {
                        labelContent.text  = @"";
                        [imageview_Img setImage:[UIImage imageNamed:message.content]];
                        imageview_Img.hidden = NO;
                        imageview_Img.userInteractionEnabled = NO;
                        [imageview_BG setHeight:108.0f];
                        [imageview_BG setWidth:115.0f];
                        
                        
                        [imageview_Img setHeight:100.0f];
                        [imageview_Img setWidth:100.0f];
                        
                        
                        if (message.fromid==self.messUid)
                        {
                            [imageview_BG setLeft:55.0f];
                            [imageview_Img setLeft:65.0f];
                            
                            indictorView.left = imageview_Img.left + imageview_Img.width  + 5;
                            indictorView.top = imageview_Img.height/2  + 20;
                            
                            retryButton.left = imageview_Img.left + imageview_Img.width  ;
                            retryButton.top = imageview_Img.height/2  + 10;
                        }
                        else
                        {
                            [imageview_BG setLeft:147 ];
                            [imageview_Img setLeft:152.0f];
                            
                            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
                            indictorView.top = imageview_BG.height/2  + 20;
                            
                            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10  -10;
                            retryButton.top = imageview_BG.height/2  + 10;
                            
                        }
                        
                        imageview_BG.hidden = YES;
                        address.text = @"";
                        address.hidden = YES;
                        
                    }
                    
                }
                else{
                    
                    labelContent.text = message.content;
                    [labelContent sizeToFit];
                    imageview_Img.hidden = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    CGSize sizeToFit = [ message.content sizeWithFont:labelContent.font constrainedToSize:CGSizeMake(222.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
                    [labelContent setWidth:sizeToFit.width+2];
                    [labelContent setHeight:sizeToFit.height];
                    [imageview_BG setHeight:fmaxf(35.0f, sizeToFit.height + 18.0f )];
                    [imageview_BG setWidth:fmaxf(35.0f, sizeToFit.width + 23.0f )];
                    
                        [imageview_BG setLeft:55.0f];
                        [labelContent setLeft:68.0f];
                        
                        
                    if (message.fromid==self.messUid)
                    {
                        [imageview_BG setLeft:55.0f];
                        [labelContent setLeft:68.0f];
                        
                        
                        indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
                        indictorView.top = imageview_BG.height/2  + 20;
                        
                        retryButton.left = imageview_BG.left + imageview_BG.width  ;
                        retryButton.top = imageview_BG.height/2  + 10;
                    }
                    else
                    {
                        labelContent.textColor =[UIColor blackColor];
                        [imageview_BG setLeft: APP_SCREEN_WIDTH - (imageview_BG.width + 55)];
                        [labelContent setLeft: APP_SCREEN_WIDTH - (labelContent.width + 77 -10 )  ];
                        
                        
                        indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
                        indictorView.top = imageview_BG.height/2  + 20;
                        
                        retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 -10 ;
                        retryButton.top = imageview_BG.height/2  + 10;
                    }


                    imageview_BG.hidden = NO;
                    address.text = @"";
                    address.hidden = YES;
                    
                }
            
            }
        }
        
    }
#pragma mark  from end
    return cell;
    
}




-(void) SeeBigImageviewClick:(id) sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    UIView * uiview =  buttonSender.superview.superview;
    CDBChatMessageCell * cell = (CDBChatMessageCell* ) uiview.superview;
    if (cell.bigImageUrl) {
        IDMPhoto * photo = [IDMPhoto photoWithURL:[NSURL URLWithString:cell.bigImageUrl]];
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:buttonSender];
        if (buttonSender.image) {
            browser.scaleImage = buttonSender.image;        // Show
        }
        [self presentViewController:browser animated:YES completion:nil];
    }
}


-(void) removeImageAnimation:(id) cell
{
    UITableViewCell * cellself = cell;
    UIImageView * Image_playing = (UIImageView*)[cellself.contentView viewWithTag:12];
    [Image_playing stopAnimating];
    Image_playing.image = nil;
     [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}



- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(35.0f, sizeToFit.height + 35.0f );
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.inputTextView isFirstResponder]) {
        self.inputTextView.inputView = nil;
        [self.inputTextView resignFirstResponder];
        [self.inputTextView reloadInputViews];
    }else
    {
        Message *message = self.messageList[indexPath.row];
        if (message.content&&(![message.content containString:@"sticker_"])) {
            
            UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:message.content delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制", nil];
             action.tag = 1;
              PasteboardStr = message.content;
              [action showInView:self.view];
        }
    }
}

#pragma mark  heigth for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float celladdlenght = 10.0f;
    Message * message =self.messageList[indexPath.row];
    if (message.picture||[message.content containString:@"sticker_"]) {
        return 148.0f + celladdlenght;
    }
   if (message.lat&&message.lng) {
        return 206.0f + celladdlenght;
    }
    return [self heightForCellWithPost:message.content]+20.0f + celladdlenght;
}


#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    
    [self keyboardWillShowHide:notification];
    [self scrollToBottonWithAnimation:YES];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
    
    if(self.inputContainerView)
    {
        ( (UIButton*) [self.inputContainerView viewWithTag:4]).hidden = NO;
        ( (UIButton*) [self.inputContainerView viewWithTag:5]).hidden = YES;
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShowHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.inputContainerView.superview convertRect:keyboardFrame fromView:nil];
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newTextFieldFrame = self.inputContainerView.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    
    CGRect inputViewFrame = self.inputContainerView.frame;
    CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
    CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
    if (inputViewFrameY > messageViewFrameBottom)
        inputViewFrameY = messageViewFrameBottom;
    
    [self.inputContainerView setTop:inputViewFrameY];
    
    [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
     - self.inputContainerView.frame.origin.y - self.inputContainerView.height];
    
    [UIView commitAnimations];
    
}

#pragma mark - Dismissive text view delegate

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.tableView.contentInset = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    insets.bottom = bottom;
    
    return insets;
}


- (void)keyboardWillHide:(NSNotification *)notification
{
        
    
     [UIView animateWithDuration:0.3 animations:^{
         self.inputContainerView.top = self.view.height - self.inputContainerView.height;
         self.tableView.height  = self.view.height - self.inputContainerView.height;
     }];
    
    if(self.inputContainerView)
    {
        ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
        ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
        
    }
}

- (void)animateChangeWithConstant:(CGFloat)constant withDuration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve
{
    [self.view setNeedsUpdateConstraints];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)resetKeyboardView {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    if (!keyboardWindow||![[keyboardWindow description] hasPrefix:@"<UITextEffectsWindow"]) return;
    self.keyboardView = keyboardWindow.subviews[0];
}

#pragma mark  textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

{
    if([text isEqualToString:@"\n"])  {
        
        [self SendTextMsgClick:nil];
        return NO;
    }
    return YES;
}

#pragma mark UIPanGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self.inputTextView isFirstResponder];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
#define kKeyboardBaseDuration .25f
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        
        CGFloat keyboardOrigY = self.keyboardView.window.frameHeight - self.keyboardView.frameHeight;
        static BOOL shouldDisplayKeyWindow = NO;
        static CGFloat lastVelocityY = 1;
        static BOOL isTouchedInputView = NO;
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            shouldDisplayKeyWindow = NO;
            lastVelocityY = 1;
            isTouchedInputView = NO;
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGFloat newKeyFrameY  = self.keyboardView.frameY + [panRecognizer locationInView:self.inputContainerView].y;
            CGFloat keyboardWindowFrameHeight = self.keyboardView.window.frameHeight;
            if (newKeyFrameY < keyboardOrigY) {
                newKeyFrameY = keyboardOrigY;
            }else if (newKeyFrameY > keyboardWindowFrameHeight){
                newKeyFrameY = keyboardWindowFrameHeight;
            }
            if (newKeyFrameY == self.keyboardView.frameY) {
                return;
            }else if (!isTouchedInputView) {
                isTouchedInputView = YES;
                self.keyboardView.userInteractionEnabled = NO;
            }
            [self.view setNeedsUpdateConstraints];
            self.keyboardView.frameY = newKeyFrameY;
            CGPoint velocity = [recognizer velocityInView:self.inputContainerView];
            if (velocity.y<0) {
                shouldDisplayKeyWindow = YES;
            }else{
                shouldDisplayKeyWindow = NO;
            }
            lastVelocityY = velocity.y;
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (!isTouchedInputView) {
                return;
            }
            CGFloat adjustVelocity = fabs(lastVelocityY)/750;
            adjustVelocity = adjustVelocity<1?1:adjustVelocity;
            CGFloat duration = kKeyboardBaseDuration/adjustVelocity;
            
            if (shouldDisplayKeyWindow) {
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:duration animations:^{
                    [self.view layoutIfNeeded];
                    self.keyboardView.frameY = keyboardOrigY;
                } completion:^(BOOL finished) {
                    self.keyboardView.userInteractionEnabled = YES;
                }];
            }else{
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:duration animations:^{
                    [self.view layoutIfNeeded];
                    self.keyboardView.frameY = self.keyboardView.window.frameHeight;
                } completion:^(BOOL finished) {
                    self.keyboardView.userInteractionEnabled = YES;
                    [UIView animateWithDuration:0. animations:^{
                        [self.inputTextView resignFirstResponder];
                    }];
                }];
            }
            
        }
    }
}

#pragma mark other common
- (void)scrollToBottonWithAnimation:(BOOL)animation
{
    if (self.messageList.count<=0) {
        return;
    }
    
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        id lastOject = [self.messageList lastObject];
        int indexOfLastRow = [self.messageList indexOfObject:lastOject];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLastRow inSection:0]  atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animation];
    }

}
- (IBAction)EmjViewShow:(id)sender {
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = YES;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = NO;
    if(!self.inputTextView.isFirstResponder)
    {
        [self.inputTextView becomeFirstResponder];
    }
    self.inputTextView.inputView = nil;
    self.inputTextView.inputView = EmjView;
    EmjView.top = self.view.height - keyboardHeight;
    [self.inputTextView reloadInputViews];
    
}

- (IBAction)KeyBoradViewShow:(id)sender {
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
    self.inputTextView.inputView = nil;
    EmjView.top = self.view.height;
    [self.inputTextView becomeFirstResponder];
    [self.inputTextView reloadInputViews];
    
}


- (IBAction)reportAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"举报" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"该用户发言包含违法违规内容" otherButtonTitles:@"该用户发言有骚扰嫌疑",nil];
    actionSheet.tag = 3;
    [actionSheet showInView:self.view];
}
@end
