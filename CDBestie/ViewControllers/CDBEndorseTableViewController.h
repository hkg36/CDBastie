//
//  CDBEndorseTableViewController.h
//  CDBestie
//
//  Created by apple on 14-8-1.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBEndorseTableViewController : UITableViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic) BOOL shouldReload;
@property (nonatomic) BOOL favorChange;
@property (nonatomic) BOOL isFavor;
@property (nonatomic) BOOL isBang;
@property (nonatomic,strong) NSMutableArray *Endorse_assignArray;
@end
