//
//  CDBMainTableViewController.h
//  CDBestie
//
//  Created by laukevin on 14-10-9.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBMainTableViewController : UITableViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic) BOOL shouldReload;
@property (nonatomic) BOOL favorChange;
@property (nonatomic) BOOL isFavor;
@property (nonatomic) BOOL isBang;
@property (nonatomic,strong) NSMutableArray *Endorse_assignArray;

@property (nonatomic,strong) NSMutableArray* picDataS;
@property (nonatomic) NSInteger showCount;

@end
