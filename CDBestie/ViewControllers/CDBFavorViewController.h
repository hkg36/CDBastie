//
//  CDBFavorViewController.h
//  CDBestie
//
//  Created by laukevin on 14-8-29.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBFavorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *FavorLayView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *FavorSeg;
- (IBAction)FavorSegAction:(id)sender;
@property (nonatomic) BOOL isWeb;
@property (nonatomic,strong) NSMutableArray *favor_EndorseassignArray;
@property (nonatomic) BOOL isFirst;
@end
