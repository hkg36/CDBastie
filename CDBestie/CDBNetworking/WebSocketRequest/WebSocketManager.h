//
//  WebSocketManager.h
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

NSString *NotifyNetConnected;
NSString *NotifyNetClosed;
NSString *NotifyNetBlocked;
NSString *NotifyNetError;
NSString *NotifyUserLogin;
NSString *NotifyPushPrifix; //监听服务器推送事件
//[[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(receiveNetOpenNotification:)
//                                             name:[NSString stringWithFormat:@"%@%@",NotifyPushPrifix,pushtype] //pushtype就是推送数据的type字段
//                                           object:nil];

@class WSRequest;
typedef void(^WSResult)(WSRequest *request, NSDictionary *result);

@interface WSRequest : NSObject
@property (nonatomic,strong) NSString *func;
@property (nonatomic,strong) NSDictionary *parm;
@property (nonatomic,strong) NSString *cdata;
@property (nonatomic,strong) NSMutableArray* callbacks;
@property (nonatomic) long buffer_timeout;

@property (nonatomic,strong) NSString* error;
@property (nonatomic) int error_code;
@end

@interface WebSocketManager : NSObject<SRWebSocketDelegate>
+(WebSocketManager*) instance;
-(void) open:(NSString*) url withsessionid:(NSString*) sessionid;
-(void) close;
-(bool) isConnected;
- (void)sendWithAction:(NSString*)function
            parameters:(NSDictionary *)parameters
               callback:(WSResult)callback;
- (void)sendWithAction:(NSString*)function
            parameters:(NSDictionary *)parameters
                 cdata:(NSString*)cdata
              callback:(WSResult)callback
               timeout:(NSTimeInterval)timeout;
@end
