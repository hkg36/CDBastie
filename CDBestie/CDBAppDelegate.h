//
//  CDBAppDelegate.h
//  CDBestie
//
//  Created by apple on 14-7-28.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDBNetworking/WebSocketRequest/WebSocketManager.h"
#import "CDBNetworking/ProtoType/User.h"
#import "Message.h"
#import "Db.h"
#import "DbPool.h"

@interface CDBAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic,strong) UITabBarController   *tabBarController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *myUserInfo;
@property (nonatomic) int picQuality;
@property (nonatomic) sqlite3* database;
-(void) CDBestieStepupDB;
@end

