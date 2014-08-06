//
//  CircleInfo.m
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import "CircleInfo.h"
#import "DataTools.h"

@implementation CircleInfo
-(id)initWithJson:(NSDictionary*)data
{
    self.board = StringFromJson([data valueForKey:@"board"]);
    self.by_uid = LongFromJson([data valueForKey:@"by_uid"]);
    self.title = StringFromJson([data valueForKey:@"title"]);
    self.icon_url = StringFromJson([data valueForKey:@"icon_url"]);
    self.name = StringFromJson([data valueForKey:@"name"]);
    self.cid = IntFromJson([data valueForKey:@"cid"]);
    self.interact_poster = IntFromJson([data valueForKey:@"interact_poster"]);
    self.roleid = IntFromJson([data valueForKey:@"roleid"]);
    self.level = IntFromJson([data valueForKey:@"level"]);
    self.time = IntFromJson([data valueForKey:@"time"]);
    self.store_group_id = IntFromJson([data valueForKey:@"store_group_id"]);
    return self;
}
@end

@implementation CircleExternal
-(id)initWithJson:(NSDictionary*)data
{
    return self;
}
@end