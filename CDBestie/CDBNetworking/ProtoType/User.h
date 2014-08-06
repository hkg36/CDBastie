//
//  User.h
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic) long long uid;
@property (strong,nonatomic) NSString *nick;
@property (strong,nonatomic) NSString *background_image;
@property (nonatomic) int birthday;
@property (strong,nonatomic) NSString *headpic;
@property (nonatomic) int height;
@property (nonatomic) int marriage;
@property (strong,nonatomic) NSString *position;
@property (nonatomic) int sex;
@property (strong,nonatomic) NSString *signature;
@property (nonatomic) int create_time;
@property (strong,nonatomic) NSString *job;
-(id)initWithJson:(NSDictionary*) data;
@end

@interface  InviteInfo : NSObject
@property (nonatomic) long long joined_uid;
@property (nonatomic) long long uid;
@property (nonatomic)  int join_roleid;
@property (strong,nonatomic) NSString *headpic;
@property (nonatomic) int height;
@property (strong,nonatomic) NSString *phone;
@property (nonatomic) int birthday;
@property (nonatomic) int sex;
@property (nonatomic) long long invite_id;
@property (nonatomic) int sms_send_time;
@property (strong,nonatomic) NSString *nick;
@property (nonatomic) int create_time;
@property (nonatomic) int marriage;
@property (nonatomic) int join_cid;
@property (strong,nonatomic) NSString *position;
-(id)initWithJson:(NSDictionary*) data;
@end

@interface UserInfo2:NSObject
@property (nonatomic,strong) User *user;
@property (nonatomic,strong) NSArray *circles;
-(id)initWithJson:(NSDictionary*) data;
@end