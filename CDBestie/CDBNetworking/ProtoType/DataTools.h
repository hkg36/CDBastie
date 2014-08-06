//
//  Tools.h
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *StringFromJson(id data);
int IntFromJson(id data);
long long LongFromJson(id data);
float FloatFromJson(id data);
double DoubleFromJson(id data);

NSString *GenCdata(int len);
