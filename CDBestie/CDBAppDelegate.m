//
//  CDBAppDelegate.m
//  CDBestie
//
//  Created by apple on 14-7-28.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"
#import "CDBNetworking/WebSocketRequest/WebSocketManager.h"
#import "CDBNetworking/ProtoType/User.h"

@implementation CDBAppDelegate

@synthesize myUserInfo;
@synthesize picQuality;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (isRetina) {
        picQuality = 2;
    }
    else
    {
        picQuality = 1;
    }
    return YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLogin:)
                                                 name:NotifyUserLogin
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNetOpenNotification:)
                                                 name:NotifyNetConnected
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:NotifyNetError
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:NotifyNetClosed
                                               object:nil];
    return YES;
}
- (void) receiveLogin:(NSNotification *) notification
{
    //User* u=(User*)notification.object;
    myUserInfo = (User*)notification.object;;
    NSLog(@"uid=%lld",myUserInfo.uid);
}
- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications as well.
    
    NSLog(@"%@",notification);
}
- (void) receiveNetOpenNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications as well.
    
    //NSLog(@"net opend");
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[WebSocketManager instance] close];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[[WebSocketManager instance] open:@"wss://service.laixinle.com:8001/ws" withsessionid:@"SCK_700F745E0EFE96E698894F89941048EE6F6091FDB25C9FF46DCB834E"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([USER_DEFAULT objectForKey:@"SESSION_ID"]&&[USER_DEFAULT objectForKey:@"SERVER_URL"]) {
        [[WebSocketManager instance] open:[USER_DEFAULT objectForKey:@"SERVER_URL"] withsessionid:[USER_DEFAULT objectForKey:@"SESSION_ID"]];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
