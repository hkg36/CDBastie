//
//  XCJSuperViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "CDBSuperViewController.h"

@interface CDBSuperViewController ()

@end

@implementation CDBSuperViewController

/**
 *  MARK : this  a  super viewcontroller to pop that childs views
 */
- (void) popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)popCurrentViewControllerSender:(id)sender
{
    [self popCurrentViewController];
}

@end
