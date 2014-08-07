//
//  Merchandise.m
//  CDBestie
//
//  Created by xinchen on 14-8-7.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "Merchandise.h"
#import "DataTools.h"

@implementation Merchandise
-(id)initWithJson:(NSDictionary*)data
{
    if(self==nil)
        return nil;
    self.icon_url=StringFromJson([data valueForKey:@"icon_url"]);
    self.show_post_url=StringFromJson([data valueForKey:@"show_post_url"]);
    self.mid=IntFromJson([data valueForKey:@"mid"]);
    self.productname=StringFromJson([data valueForKey:@"productname"]);
    self.amount=IntFromJson([data valueForKey:@"amount"]);
    self.time=IntFromJson([data valueForKey:@"time"]);
    return self;
}
@end
