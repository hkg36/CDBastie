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



@interface CDBAppDelegate()<UITabBarControllerDelegate>

@end

@implementation CDBAppDelegate
{
    sqlite3 *database;
}

@synthesize myUserInfo;
@synthesize picQuality;
@synthesize database;
static NSString * const kCDBestieStoreName = @"CDBestie";

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    if (isRetina) {
        picQuality = 2;
    }
    else
    {
        picQuality = 1;
    }
    
    
    
    return YES;
}

-(void) CDBestieStepupDB
{
    [self CDBestieSetupDB_ORM];
    [self CDBestieCreatTable];
    
}


-(NSString *) dataFilePath{
    
    NSString * strDBName = [NSString stringWithFormat:@"%@_%@.db",kCDBestieStoreName,[NSString stringWithFormat:@"%ld",(long)[USER_DEFAULT integerForKey:@"USERINFO_UID"]]];
    
    NSArray *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *document = [path objectAtIndex:0];
    
    return [document stringByAppendingPathComponent:strDBName];//'persion.sqlite'
    
}


-(void)CDBestieSetupDB_ORM
{
    {
        NSString * strDBName = [NSString stringWithFormat:@"%@.db",kCDBestieStoreName];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:strDBName];
        [[DbPool sharedInstance] addConn:@"default" path:path];
        if ([[Db currentDb] existDb])
        {
            [[Db currentDb] openDb];
            return;
        }
        
        [[Db currentDb] createDb];
    }
}
-(void)CDBestieCreatTable
{
    Db *db = [Db currentDb];
	
	[db execute:@"CREATE TABLE IF NOT EXISTS Message"
	 @"(id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL,MSGID biginteger unique,FROMID biginteger,TOID biginteger,CONTENT text,PICTURE text,VIDEO text,VOICE text,WIDTH integer,HEIGHT integer,LENGTH integer,TIME integer,LAT float,LNG float)"];
    
}
-(void)CDBestieSelectTable:(NSString*)tableName
{
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self initAllControlos];
    [self CDBestieStepupDB];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    
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
    NSString *pushtype = @"newmsg";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketInsertPushMessage:)
                                                 name:[NSString stringWithFormat:@"%@%@",NotifyPushPrifix,pushtype]
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketInsertSendMessage:)
                                                 name:[NSString stringWithFormat:@"%@sendmsg",NotifyPushPrifix]
                                               object:nil];
    
    return YES;
}

-(void)webSocketInsertPushMessage:(NSNotification *)notification
{
    NSDictionary * MsgContent  = notification.userInfo;
    SLLog(@"MsgContent :%@",MsgContent);
    [[Db currentDb]save:[[Message alloc] initWithJson:[MsgContent objectForKey:@"message"]]];
}

-(void)webSocketInsertSendMessage:(NSNotification *)notification
{
    NSDictionary * MsgContent  = notification.object;
    SLLog(@"MsgContent :%@",MsgContent);
    [[Db currentDb]save:[[Message alloc]initWithJson:MsgContent]];
    
}


- (void) receiveLogin:(NSNotification *) notification
{
    myUserInfo = (User*)notification.object;;
    [self ReceiveAllMessage];
}

-(void) ReceiveAllMessage
{
    if(!([USER_DEFAULT objectForKey:@"SESSION_ID"]&&[USER_DEFAULT objectForKey:@"SERVER_URL"]))
        return;
    NSDictionary * parames = @{@"afterid":@0};
    [[WebSocketManager instance]sendWithAction:@"message.read" parameters:parames callback:^(WSRequest *request, NSDictionary *result){
        if(request.error_code!=0)
        {
            return;
        }
        NSDictionary * resultDict = result;
        NSArray * array = resultDict[@"message"];
        for (int i = 0; i<[array count]; i++) {
            NSDictionary* line=array[i];
            [[Db currentDb]save:[[Message alloc] initWithJson:line]];
        }
    }];
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


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* devtokenstring=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@" " withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //devtokenstring:  d8009e6c8e074d1bbcb592f321367feaef5674a82fc4cf3b78b066b7c8ad59bd
    SLLog(@"devtokenstring : %@",devtokenstring);
    
    [USER_DEFAULT setValue:devtokenstring forKey:KeyChain_Laixin_account_devtokenstring];
    [USER_DEFAULT synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    SLLog(@"error : %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    if (application.applicationState == UIApplicationStateActive) {

    }

}


- (void) initAllControlos
{
    if (!self.tabBarController) {
        self.tabBarController = (UITabBarController *)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
        self.tabBarController.delegate = self;
    }
    
    if ([UITabBar instancesRespondToSelector:@selector(setSelectedImageTintColor:)]) {
        [self.tabBarController.tabBar setSelectedImageTintColor:iosLXSystemColor];
    }
}

@end
