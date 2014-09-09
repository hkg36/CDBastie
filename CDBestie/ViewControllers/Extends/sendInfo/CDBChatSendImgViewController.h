//
//  CDBChatSendImgViewController.h
//  CDBestie
//
//  Created by apple on 14-9-1.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol   CDBChatSendImgViewControllerdelegate <NSObject>
- (void) SendImageURL:(UIImage * ) url  withKey:(NSString *) key;
@end

@class CDBChatSendImgViewControllerdelegate;
@interface CDBChatSendImgViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) UIImage *imageviewSource;
@property (strong, nonatomic) NSString *imageviewURL;
@property (strong, nonatomic) NSString *key;
@property (weak, nonatomic) id<CDBChatSendImgViewControllerdelegate>  delegate;
@end
