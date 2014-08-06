//
//  Message.h
//  base_test
//
//  Created by xinchen on 14-8-1.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
@property (nonatomic) long long msgid;
@property (nonatomic) long long fromid;
@property (nonatomic) long long toid;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSString *video;
@property (nonatomic,strong) NSString *voice;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int length;
@property (nonatomic) float lat;
@property (nonatomic) float lng;
@property (nonatomic) int time;
-(id)initWithJson:(NSDictionary*)data;
@end
