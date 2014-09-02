//
//  FuncionesGlobales.m
//  JhonSell
//
//  Created by Mario Montoya on 6/01/09.
//  Copyright 2009 El malabarista. All rights reserved.
//

#import "FuncionesGlobales.h"


@implementation FuncionesGlobales

+ (NSString *) docPath {
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

	return docsPath;		
}

+(NSLocale *) NEUTRAL_LOCALE
{
    static NSLocale *US_LOCALE = nil;
    
    if (!US_LOCALE) {
        US_LOCALE = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    
    return US_LOCALE;
}

@end
