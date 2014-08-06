//
//  Message.m
//  base_test
//
//  Created by xinchen on 14-8-1.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import "Message.h"
#import "DataTools.h"

@implementation Message
-(id)initWithJson:(NSDictionary*)data
{
    if(self==nil)
        return nil;
    
    self.msgid=LongFromJson([data valueForKey:@"msgid"]);
    self.fromid=LongFromJson([data valueForKey:@"fromid"]);
    self.toid=LongFromJson([data valueForKey:@"toid"]);
    self.content=StringFromJson([data valueForKey:@"content"]);
    self.picture=StringFromJson([data valueForKey:@"picture"]);
    self.video=StringFromJson([data valueForKey:@"video"]);
    self.voice=StringFromJson([data valueForKey:@"voice"]);
    self.width=IntFromJson([data valueForKey:@"width"]);
    self.height=IntFromJson([data valueForKey:@"height"]);
    self.length=IntFromJson([data valueForKey:@"length"]);
    self.lat=FloatFromJson([data valueForKey:@"lat"]);
    self.lng=FloatFromJson([data valueForKey:@"long"]);
    self.time=IntFromJson([data valueForKey:@"time"]);
    
    return self;
}
@end
