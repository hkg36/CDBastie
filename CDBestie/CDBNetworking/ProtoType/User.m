//
//  User.m
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import "User.h"
#import "DataTools.h"
#import "CircleInfo.h"
@implementation User
-(id)initWithJson:(NSDictionary*) data
{
    self.create_time = IntFromJson([data valueForKey:@"create_time"]);
    self.uid = LongFromJson([data valueForKey:@"uid"]);
    self.nick = StringFromJson([data valueForKey:@"nick"]);
    self.sex = IntFromJson([data valueForKey:@"sex"]);
    self.headpic = StringFromJson([data valueForKey:@"headpic"]);
    self.birthday = IntFromJson([data valueForKey:@"birthday"]);
    self.height = IntFromJson([data valueForKey:@"height"]);
    self.background_image = StringFromJson([data valueForKey:@"background_image"]);
    self.marriage = IntFromJson([data valueForKey:@"marriage"]);
    self.signature = StringFromJson([data valueForKey:@"signature"]);
    self.position = StringFromJson([data valueForKey:@"position"]);
    self.job = StringFromJson([data valueForKey:@"job"]);

    return self;
}
@end

@implementation InviteInfo
-(id)initWithJson:(NSDictionary*) data
{
    self.joined_uid=LongFromJson([data valueForKey:@"joined_uid"]);
    self.uid=LongFromJson([data valueForKey:@"uid"]);
    self.join_roleid=IntFromJson([data valueForKey:@"join_roleid"]);
    self.headpic=StringFromJson([data valueForKey:@"headpic"]);
    self.height=IntFromJson([data valueForKey:@"height"]);
    self.phone=StringFromJson([data valueForKey:@"phone"]);
    self.birthday=IntFromJson([data valueForKey:@"birthday"]);
    self.sex=IntFromJson([data valueForKey:@"sex"]);
    self.invite_id=LongFromJson([data valueForKey:@"invite_id"]);
    self.sms_send_time=IntFromJson([data valueForKey:@"sms_send_time"]);
    self.nick=StringFromJson([data valueForKey:@"nick"]);
    self.create_time=IntFromJson([data valueForKey:@"create_time"]);
    self.marriage=IntFromJson([data valueForKey:@"marriage"]);
    self.join_cid=IntFromJson([data valueForKey:@"join_cid"]);
    self.position=StringFromJson([data valueForKey:@"position"]);
    return self;
}
@end

@implementation UserInfo2
-(id)initWithJson:(NSDictionary*) data
{
    NSDictionary *node_user=[data objectForKey:@"user"];
    if(node_user)
        self.user=[[User alloc] initWithJson:node_user];
    NSArray *node_circles=[data objectForKey:@"circles"];
    if(node_circles)
    {
        NSMutableArray *cs=[NSMutableArray new];
        for(NSDictionary *one in node_circles)
        {
            CircleInfo *info=[[CircleInfo alloc] initWithJson:one];
            [cs addObject:info];
        }
        self.circles=cs;
    }
    return self;
}
@end