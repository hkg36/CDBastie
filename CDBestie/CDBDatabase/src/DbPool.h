//
//  DbPool.h
//  BestSeller
//
//  Created by Mario Montoya  on 9/04/10.
//  Copyright 2009 El malabarista. All rights reserved.
//

#import "Db.h"

@interface DbPool : NSObject {
		
}

@property (strong) NSMutableDictionary *pool;
@property (strong) NSMutableDictionary *paths;

+ (DbPool *)sharedInstance;

- (Db *) getConn;
- (Db *) getConn:(NSString *)name;

- (BOOL) existConn:(NSString *)name;
- (Db *) addConn:(NSString *)name path:(NSString *)path;
- (Db *) cloneConn:(NSString *)oldName newName:(NSString *)newName;

- (void) closeDatabases;

- (void) clear;

@end
