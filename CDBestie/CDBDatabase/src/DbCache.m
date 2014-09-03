//
//  DbCache.m
//  JhonSell
//
//  Created by Mario Montoya on 30/03/09.
//  Copyright 2009 El malabarista. All rights reserved.
//

#import "DbCache.h"

@implementation DbCache

@synthesize propertyCache;

static DbCache *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        self.propertyCache = [NSMutableDictionary dictionary];
    }
	
	return self;
}


#pragma mark Utilities
- (void) clear {
	[self.propertyCache removeAllObjects];
}

-(id) value:(NSString *)key {
	return [self.propertyCache objectForKey:key];	
}

-(void) save:(NSString *)key value:(id)dict {
	[self.propertyCache setObject:dict forKey:key];
}

#pragma mark Global access
+(id)currentDbCache {
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[DbCache alloc] init];
    }
    return sharedInstance;	
}
+ (DbCache *)sharedInstance
{
    static DbCache *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DbCache alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

@end
