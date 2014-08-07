//
//  Merchandise.h
//  CDBestie
//
//  Created by xinchen on 14-8-7.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchandise : NSObject
@property (nonatomic,strong) NSString* icon_url;
@property (nonatomic,strong) NSString* show_post_url;
@property (nonatomic) int mid;
@property (nonatomic,strong) NSString* productname;
@property (nonatomic) int amount;
@property (nonatomic) int time;
-(id)initWithJson:(NSDictionary*)data;
@end
