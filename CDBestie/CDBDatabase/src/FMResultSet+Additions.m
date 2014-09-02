//
//  FMResultSet+Additions.m
//  JhonSell
//
//  Created by Mario Montoya on 30/05/09.
//  Copyright 2009 El malabarista. All rights reserved.
//

#import "FMResultSet+Additions.h"

@implementation FMResultSet (info)

- (NSArray *) columnsName {
	if (!_columnNamesSetup) {
        [self columnIndexForName:@"id"];
    }
    
	return [_columnNameToIndexMap allKeys];
}

@end
