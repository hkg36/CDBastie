//
//  CircleInfo.h
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleInfo : NSObject
@property (nonatomic) int cid;
@property (nonatomic) int roleid;
@property (nonatomic) int level;
@property (nonatomic) int interact_poster;
@property (nonatomic,strong) NSString* poster_url;
@property (nonatomic,strong) NSString* name;
@property (nonatomic) long long by_uid;
@property (nonatomic,strong) NSString* board;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* icon_url;
@property (nonatomic) int store_group_id;
@property (nonatomic) int time;
@property (nonatomic,strong) NSArray* exlist;

-(id)initWithJson:(NSDictionary*)data;
@end

@interface CircleExternal : NSObject
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* icon_url;
@property (nonatomic,strong) NSString* url;
@property (nonatomic) int time;
-(id)initWithJson:(NSDictionary*)data;
@end