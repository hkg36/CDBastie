//
//  PrivacyViewController.m
//  CDBestie
//
//  Created by laukevin on 14-9-17.
//  Copyright (c) 2014年 lifestyle. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

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
    }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)agreeclick:(id)sender {
    NSUserDefaults * settings1 = [NSUserDefaults standardUserDefaults];
    NSString *key1 = [NSString stringWithFormat:@"is_Agree"];
    [settings1 setObject:@"1" forKey:key1];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}
@end
