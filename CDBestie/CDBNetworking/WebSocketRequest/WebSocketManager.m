//
//  WebSocketManager.m
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import "WebSocketManager.h"
#import "SRWebSocket.h"
#import "../ProtoType/DataTools.h"
#import "../ProtoType/User.h"
#import <zlib.h>
#import "LevelDB.h"

NSString *NotifyNetConnected=@"NotifyNetConnected";
NSString *NotifyNetClosed=@"NotifyNetClosed";
NSString *NotifyNetBlocked=@"NotifyNetBlocked";
NSString *NotifyNetError=@"NotifyNetError";
NSString *NotifyUserLogin=@"NotifyUserLogin";
NSString *NotifyPushPrifix=@"NotifyPush_";

@interface WebSocketManager()
@property (strong,nonatomic) SRWebSocket *websocket;
@property (nonatomic) bool is_open;
@property (strong,nonatomic) NSString* url;
@property (strong,nonatomic) NSString* sessionid;
@property (strong,nonatomic) NSMutableDictionary *requestbuffer;
@property (strong,nonatomic) LevelDB *cmdCacheDb;
@property (strong,nonatomic) NSTimer *timer;
@property (nonatomic) NSTimeInterval last_recvtime;
@property (nonatomic) NSTimeInterval last_pingtime;
@end

NSString *fix_session_start_cdata=@"WebSocketManager.sesssion.start2";
WebSocketManager *one_instance=nil;

@interface WSRequest()
@property (nonatomic) NSTimeInterval addtime;
@end
@implementation WSRequest
-(id)init{
    if(self==nil)
        return nil;
    self.callbacks=[NSMutableArray new];
    self.addtime=[[NSDate date] timeIntervalSince1970];
    return self;
}
-(NSData *)getCompressData
{
    NSMutableDictionary *reqdic=[NSMutableDictionary new];
    [reqdic setObject:self.func forKey:@"func"];
    [reqdic setObject:self.parm forKey:@"parm"];
    if(self.cdata)
        [reqdic setObject:self.cdata forKey:@"cdata"];
    NSError *error;
    NSData *reqdata=[NSJSONSerialization dataWithJSONObject:reqdic options:0 error:&error];
   
    NSMutableData *compressed = [NSMutableData data];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[reqdata bytes];
    strm.avail_in = (uInt)[reqdata length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (deflateInit(&strm,9) != Z_OK) return nil;
    
    Bytef tempdata[64];
    while (true) {
        strm.next_out = tempdata;
        strm.avail_out = sizeof(tempdata);
        strm.total_out=0;
        // Inflate another chunk.
        status = deflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_OK) {
            [compressed appendBytes:tempdata length:strm.total_out];
        }
        else
            return nil;
        if (strm.avail_in==0) {
            break;
        }
    }
    strm.next_out = tempdata;
    strm.avail_out = sizeof(tempdata);
    strm.total_out=0;
    // Inflate another chunk.
    status = deflate (&strm, Z_FINISH);
    if (status==Z_STREAM_END) {
        if(strm.total_out>0)
            [compressed appendBytes:tempdata length:strm.total_out];
        done=true;
    }
    else
        return nil;
    if (deflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        return compressed;
    } else {
        return nil;
    }
}
-(void)doCallBack:(NSDictionary*)result
{
    for(WSResult callback in self.callbacks){
        callback(self,result);
    }
}
@end

@implementation WebSocketManager
+(WebSocketManager*) instance
{
    if(one_instance==nil)
        one_instance=[WebSocketManager new];
    return one_instance;
}
-(id)init
{
    if(self==nil)
        return nil;
    self.websocket=nil;
    self.is_open=false;
    self.url=nil;
    self.sessionid=nil;
    self.requestbuffer=[NSMutableDictionary new];
    self.last_pingtime=0;
    self.last_recvtime=0;
    
    NSString *tmppath=NSTemporaryDirectory();
    self.cmdCacheDb=[[LevelDB alloc] initWithPath:[NSString stringWithFormat:@"%@networkCacheDb",tmppath]];
    
    self.timer=[NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:TRUE];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    return self;
}
-(void) open:(NSString*) url withsessionid:(NSString*) sessionid
{
    self.url=url;
    self.sessionid=sessionid;
    if(self.is_open)
        [self close];
    self.is_open=true;
    [self checkForStart];
}
-(bool) isConnected
{
    return self.is_open && self.websocket!=nil &&
    self.websocket.readyState == SR_OPEN;
}
-(void) close
{
    self.is_open=false;
    if(self.websocket)
    {
        [self.websocket close];
        self.websocket=nil;
    }
}
-(void) checkForStart
{
    if(self.is_open && self.websocket==nil)
    {
        NSString *fullurl=[NSString stringWithFormat:@"%@?sessionid=%@&cdata=%@&usezlib=1",self.url,self.sessionid,fix_session_start_cdata];
        self.websocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:fullurl]];
        self.websocket.delegate = self;
        [self.websocket open];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    self.last_recvtime=[[NSDate date] timeIntervalSince1970];
    
    if(![message isKindOfClass:[NSData class]])
        return;
    NSError *error;
    NSData *ucdata=[self uncompressZippedData:message];
    if(ucdata==nil)
    {
        NSLog(@"%@",message);
        return;
    }
    NSDictionary *resdic = [NSJSONSerialization JSONObjectWithData:ucdata options:NSJSONReadingMutableLeaves error:&error];
    if(resdic==nil)
    {
        NSLog(@"%@\n%@",message,error);
        return;
    }
    int ispush=IntFromJson([resdic valueForKey:@"push"]);
    if(ispush)
    {
        NSLog(@"recv push:%@",resdic);
        NSString* pushtype=[resdic valueForKey:@"type"];
        if(pushtype)
        {
            NSDictionary *pushdata=[resdic valueForKey:@"data"];
            if(pushdata)
            {
                NSString *notifykey=[NSString stringWithFormat:@"%@%@",NotifyPushPrifix,pushtype];
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:notifykey object:nil userInfo:pushdata];
            }
        }
    }
    else{
        NSString *cdata=StringFromJson([resdic valueForKey:@"cdata"]);
        if([cdata isEqual:fix_session_start_cdata])
        {
            [self processUserLogin:[resdic valueForKeyPath:@"result"]];
        }
        else{
            NSLog(@"%@",cdata);
            WSRequest *wsreq=[self.requestbuffer objectForKey:cdata];
            if(wsreq)
            {
                wsreq.error=StringFromJson([resdic valueForKey:@"error"]);
                wsreq.error_code=IntFromJson([resdic valueForKey:@"errno"]);
                NSDictionary *result=[resdic objectForKey:@"result"];
                [self SaveResult:wsreq result:result];
                [wsreq doCallBack:result];
                [self.requestbuffer removeObjectForKey:cdata];
            }
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    //NSLog(@"WebSocket did open");
    self.last_recvtime=[[NSDate date] timeIntervalSince1970];
    
    for(NSString *key in self.requestbuffer)
    {
        WSRequest *one = [self.requestbuffer valueForKey:key];
        NSData *tosend_data=[one getCompressData];
        if(tosend_data)
            [webSocket send:tosend_data];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NotifyNetConnected object:nil];
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError:%@",error);
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NotifyNetError object:error];
    self.websocket=nil;
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    //NSLog(@"didCloseWithCode:%@",reason);
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NotifyNetClosed object:reason];
    self.websocket=nil;
}
- (void)webSocketDidRecvPong:(SRWebSocket *)webSocket
{
    NSLog(@"on pong");
    self.last_recvtime=[[NSDate date] timeIntervalSince1970];
}
-(NSData *)uncompressZippedData:(NSData *)compressedData
{
    
    if ([compressedData length] == 0) return compressedData;
    
    unsigned full_length = (unsigned)[compressedData length];
    
    unsigned half_length = (unsigned)[compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = (uInt)[compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit(&strm) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
        
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

-(void)processUserLogin:(NSDictionary*)result
{
    NSDictionary *node_user=[result valueForKey:@"user"];
    User *user=[[User alloc] initWithJson:node_user];
    NSArray *node_invites=[result valueForKey:@"invite_list"];
    NSMutableArray *invites=nil;
    if(node_invites!=nil)
    {
        invites=[NSMutableArray new];
        for(NSDictionary *one in node_invites)
        {
            InviteInfo *info=[[InviteInfo alloc] initWithJson:one];
            [invites addObject:info];
        }
    }
    NSDictionary *client_data=[result valueForKey:@"client_data"];
    
    NSMutableDictionary *passdata=[NSMutableDictionary new];
    [passdata setValue:invites forKey:@"invites"];
    [passdata setValue:client_data forKey:@"client_data"];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NotifyUserLogin object:user userInfo:passdata];
}
- (void)sendWithAction:(NSString*)function
            parameters:(NSDictionary *)parameters
               callback:(WSResult)callback
{
    [self sendWithAction:function parameters:parameters cdata:GenCdata(12) callback:callback timeout:0];
}
- (void)sendWithAction:(NSString*)function
            parameters:(NSDictionary *)parameters
                 cdata:(NSString*)cdata
               callback:(WSResult)callback
               timeout:(NSTimeInterval)timeout
{
    if(timeout>0)
    {
        NSString *bufkey=[self CmdBufferKey:function parm:parameters];
        NSDictionary *result=[self.cmdCacheDb getObject:bufkey];
        if(result)
        {
            if([[NSDate date] timeIntervalSince1970]-[[result objectForKey:@"time"] doubleValue]<timeout)
            {
                WSRequest *req=[WSRequest new];
                req.func=function;
                req.parm=parameters;
                req.cdata=cdata;
                req.buffer_timeout=timeout;
                
                req.error_code=0;
                req.error=@"from cache";
                callback(req,[result objectForKey:@"result"]);
                return;
            }
        }
        
    }
    
    WSRequest *req=[self.requestbuffer valueForKey:cdata];
    bool gosend=false;
    if(req==nil)
    {
        gosend=true;
        req=[WSRequest new];
        req.func=function;
        req.parm=parameters;
        req.cdata=cdata;
        req.buffer_timeout=timeout;
        [self.requestbuffer setValue:req forKey:cdata];
    }
    [req.callbacks addObject:callback];
    
    if(gosend && [self isConnected])
    {
        NSData *tosend_data=[req getCompressData];
        if(tosend_data)
           [self.websocket send:tosend_data];
    }
}
-(NSString*) CmdBufferKey:(NSString*)func parm:(NSDictionary*)parm
{
    NSError *error;
    NSData *tmpdata=[NSJSONSerialization dataWithJSONObject:parm options:0 error:&error];
    NSString* tmpstr = [[NSString alloc] initWithData:tmpdata encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@:%@",func,tmpstr];
}
-(void)SaveResult:(WSRequest *)req result:(NSDictionary*)result
{
    if(req.buffer_timeout==0 || req.error_code!=0)
        return;
    NSDictionary *newdic=@{@"result":result,@"time":[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]};
    [self.cmdCacheDb putObject:newdic forKey:[self CmdBufferKey:req.func parm:req.parm]];
}
- (void) handleTimer: (NSTimer *) timer
{
    //NSLog(@"in timer call");
    if(self.is_open && self.websocket==nil)
        [self checkForStart];
    
    NSTimeInterval now=[[NSDate date] timeIntervalSince1970];
    
    if(self.websocket!=nil)
    {
        if(now-self.last_recvtime>30)
        {
            [self.websocket close];
            self.websocket=nil;
        }
        else if(now-self.last_recvtime>10 && now-self.last_pingtime>10)
        {
            self.last_pingtime=now;
            [self.websocket sendPing];
        }
    }
    
    
    NSMutableArray *go_delete=[NSMutableArray new];
    for(NSString *key in self.requestbuffer)
    {
        WSRequest *one = [self.requestbuffer valueForKey:key];
        if(now-one.addtime>15.0)
        {
            [go_delete addObject:key];
            one.error_code=-1;
            one.error=@"time out";
            [one doCallBack:nil];
        }
    }
    [self.requestbuffer removeObjectsForKeys:go_delete];
}
@end