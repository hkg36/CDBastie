//
//  ChatViewController.h
//  ISClone
//
//  Created by Molon on 13-12-4.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Db.h"
#import "DbPool.h"
@class Conversation,FCUserDescription;
@interface ChatViewController : UIViewController

@property (readwrite, nonatomic, strong) Conversation *conversation;

@property (readwrite, nonatomic, strong) FCUserDescription *userinfo;

@property (nonatomic) long long messUid;
@property (strong,nonatomic) NSString* messHeadPic;

@end
