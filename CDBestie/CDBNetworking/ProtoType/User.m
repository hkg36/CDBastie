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

@implementation Endorsement
-(id)initWithJson:(NSDictionary*) data
{
    if(self==nil)
        return nil;
    self.level=IntFromJson([data valueForKey:@"level"]);
    self.endorsement_point=LongFromJson([data valueForKey:@"endorsement_point"]);
    self.create_time=IntFromJson([data valueForKey:@"create_time"]);
    self.endorsement_type=IntFromJson([data valueForKey:@"endorsement_type"]);
    self.consumer_point=LongFromJson([data valueForKey:@"consumer_point"]);
    self.type=[data valueForKey:@"type"];
    return self;
}
@end

@implementation EndorsList
-(id)initWithJson:(NSDictionary*) data
{
    if(self==nil)
        return nil;
    
    self.create_time=IntFromJson([data valueForKey:@"create_time"]);
    self.slogan=StringFromJson([data valueForKey:@"slogan"]);
    self.merchandise=[[Merchandise alloc] initWithJson:[data valueForKeyPath:@"merchandise"]];
    
    return self;
}
@end

@implementation UserInfo2
-(id)initWithJson:(NSDictionary*) data
{
    if(self==nil)
        return nil;
    
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
    NSDictionary *node_endorsement=[data valueForKeyPath:@"endorsement"];
    if(node_endorsement)
        self.endorsement=[[Endorsement alloc] initWithJson:node_endorsement];
    
    NSArray *endors_list=[data valueForKey:@"endors_list"];
    if(endors_list)
    {
        NSMutableArray *elist=[NSMutableArray new];
        for(NSDictionary *one_line in endors_list)
        {
            [elist addObject:[[EndorsList alloc] initWithJson:one_line]];
        }
    }
    return self;
}
@end