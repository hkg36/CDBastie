//
//  DbBackground.h
//  BestSeller
//
//  Created by Mario Montoya  on 9/04/10.
//  Copyright 2009 El malabarista. All rights reserved.
//

#import "DbPool.h"

@interface DbBackground : NSOperation {

}

@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) Db *db;
@property (nonatomic, strong) id delegate;

-(id)initWithSQL:(NSString *)theSql name:(NSString *)name;

@end
