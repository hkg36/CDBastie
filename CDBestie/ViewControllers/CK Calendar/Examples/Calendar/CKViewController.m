#import "CKViewController.h"
#import "CKCalendarView.h"
#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"


@interface CKViewController ()

@end

@implementation CKViewController
@synthesize isChanged;
@synthesize pasMutableArray;
- (id)init {
    self = [super init];
    if (self) {
        CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
        calendar.frame = CGRectMake(0, 60, 320, 470);
        [self.view addSubview:calendar];

        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"  style:UIBarButtonItemStylePlain target:self action:@selector(commitCalendar)];
        
    }
    return self;
}

-(void)passCalendar:(NSNotification *) notify
{
    NSLog(@"%@",notify.object);
    if (notify.object) {
        
        NSMutableArray *commitArray = [[NSMutableArray alloc]initWithArray:[(NSMutableSet*)notify.object allObjects]];
        pasMutableArray = commitArray;
        isChanged =YES;
    }
    else{
        isChanged =NO;
    }
}

-(void)commitCalendar
{
    if (isChanged) {
        NSDictionary * parames = @{@"times":pasMutableArray};
        [[WebSocketManager instance]sendWithAction:@"endorsement.set_times" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
            SLog(@"%@",result);
            
        }];
    }
    
        
    }

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(passCalendar:)
                                                 name:@"NotifyCalendarCommit"
                                               object:nil];
    isChanged = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end