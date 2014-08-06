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

@interface CDBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *myUserInfo;
@end
