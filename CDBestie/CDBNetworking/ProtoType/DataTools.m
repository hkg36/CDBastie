//
//  Tools.m
//  base_test
//
//  Created by xinchen on 14-7-30.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import "DataTools.h"

NSString *StringFromJson(id data)
{
    if(data==nil || data==[NSNull null])
        return nil;
    return data;
}
int IntFromJson(id data)
{
    if(data==nil || data==[NSNull null])
        return 0;
    return [data intValue];
}
long long LongFromJson(id data)
{
    if(data==nil || data==[NSNull null])
        return 0;
    return [data longLongValue];
}
float FloatFromJson(id data)
{
    if(data==nil || data==[NSNull null])
        return 0.0;
    return [data floatValue];
}
double DoubleFromJson(id data)
{
    if(data==nil || data==[NSNull null])
        return 0.0;
    return [data doubleValue];
}

NSString *GenCdata(int len)
{
    char data[len];
    for (int x=0;x<len;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:len encoding:NSUTF8StringEncoding];
}