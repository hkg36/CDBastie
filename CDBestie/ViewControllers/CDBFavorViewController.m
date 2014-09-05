//
//  CDBFavorViewController.m
//  CDBestie
//
//  Created by laukevin on 14-8-29.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "CDBFavorViewController.h"
#import "CDBEndorseTableViewController.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "UIView+Additon.h"
#import "CDBestieDefines.h"
@interface CDBFavorViewController ()
{
    NSString* pushURLString;
}
@property (retain,nonatomic) UIViewController * childVC;
@end
CDBEndorseTableViewController *EndorseView;
DZWebBrowser *webBrowser;
@implementation CDBFavorViewController
@synthesize FavorSeg;
@synthesize FavorLayView;
@synthesize favor_EndorseassignArray;
@synthesize isFirst;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    FavorSeg.top = FavorSeg.top+5;
    FavorSeg.height =35;
    FavorLayView.frame = CGRectMake(0, FavorSeg.frame.origin.y+FavorSeg.frame.size.height, 320, [[UIScreen mainScreen]bounds].size.height-FavorSeg.height);
    // Do any additional setup after loading the view.
    [self EndorseShow];
}

-(void)viewWillAppear:(BOOL)animated
{
    isFirst=YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)FavorSegAction:(id)sender {
    
    switch (FavorSeg.selectedSegmentIndex) {
        case 0:
            
            [self EndorseShow];
            
            break;
        case 1:
            if(isFirst){
            pushURLString = [NSString stringWithFormat:@"%@collectarticle.do?sessionid=%@",CDBestieNet,[[NSUserDefaults standardUserDefaults] objectForKey:@"SESSION_ID"]];
            webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:pushURLString]];
            webBrowser.showProgress = YES;
            webBrowser.allowOrder = NO;
            webBrowser.allowtoolbar = YES;
            [self.FavorLayView addSubview:webBrowser.view];
                isFirst =NO;
            }
            EndorseView.view.hidden = YES;
            break;
    }
}

-(void)EndorseShow
{
    UIStoryboard *stroy = self.storyboard;
    EndorseView = [stroy instantiateViewControllerWithIdentifier:@"CDBEndorseTableViewController"];
    EndorseView.isFavor = 1;
    EndorseView.Endorse_assignArray = favor_EndorseassignArray;
    EndorseView.view.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen]bounds].size.height-100);
    [self.FavorLayView addSubview:EndorseView.view];
    [self addChildViewController:EndorseView];
    self.childVC = EndorseView;
    EndorseView.view.hidden = NO;
}


@end