//
// Copyright (c) 2012 Jason Kozemczak
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendarView.h"

#import "CDBAppDelegate.h"
#import "CDBestieDefines.h"

#define BUTTON_MARGIN 4
#define CALENDAR_MARGIN 5
#define TOP_HEIGHT 44
#define DAYS_HEADER_HEIGHT 22
#define DEFAULT_CELL_WIDTH 43
#define CELL_BORDER_WIDTH 1

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@class CALayer;
@class CAGradientLayer;

@interface GradientView : UIView

@property(nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
- (void)setColors:(NSArray *)colors;

@end

@implementation GradientView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colors {
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    self.gradientLayer.colors = cgColors;
}

@end


@interface DateButton : UIButton

@property (nonatomic, strong) NSDate *date;

@end

@implementation DateButton

@synthesize date = _date;

- (void)setDate:(NSDate *)aDate {
    _date = aDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"d";
    [self setTitle:[dateFormatter stringFromDate:_date] forState:UIControlStateNormal];
}

@end


@interface CKCalendarView ()

@property(nonatomic, strong) UIButton *commitButton;

@property(nonatomic, strong) UIView *highlight;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) GradientView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSMutableSet *selectButtons;

@property(nonatomic, strong) NSMutableSet *dateArray;
@property(nonatomic) BOOL isComparing;
@property (nonatomic) startDay calendarStartDay;
@property (nonatomic, strong) NSDate *monthShowing;
@property (nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, assign) CGFloat cellWidth;

@property(nonatomic)long long longsTime;
@property(nonatomic)long long longdTime;
@end

@implementation CKCalendarView

@synthesize commitButton = _commitButton;

@synthesize highlight = _highlight;
@synthesize titleLabel = _titleLabel;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize calendarContainer = _calendarContainer;
@synthesize daysHeader = _daysHeader;
@synthesize dayOfWeekLabels = _dayOfWeekLabels;
@synthesize dateButtons = _dateButtons;
@synthesize selectButtons = _selectButtons;
@synthesize dateArray = _dateArray;
@synthesize monthShowing = _monthShowing;
@synthesize calendar = _calendar;

@synthesize selectedDate = _selectedDate;
@synthesize delegate = _delegate;

@synthesize selectedDateTextColor = _selectedDateTextColor;
@synthesize selectedDateBackgroundColor = _selectedDateBackgroundColor;
@synthesize currentDateTextColor = _currentDateTextColor;
@synthesize currentDateBackgroundColor = _currentDateBackgroundColor;
@synthesize timeoutDateTextColor = _timeoutDateTextColor;
@synthesize timeoutDateBackgroundColor = _timeoutDateBackgroundColor;
@synthesize orderedDateTextColor = _orderedDateTextColor;
@synthesize orderedDateBackgroundColor = _orderedDateBackgroundColor;
@synthesize cellWidth = _cellWidth;

@synthesize calendarStartDay;


@synthesize longdTime;
@synthesize longsTime;
@synthesize isComparing;
- (id)init {
    return [self initWithStartDay:startSunday];
}

- (id)initWithStartDay:(startDay)firstDay {
    self.calendarStartDay = firstDay;
    return [self initWithFrame:CGRectMake(0, 0, 320, 320)];
}

- (id)initWithStartDay:(startDay)firstDay frame:(CGRect)frame {
    self.calendarStartDay = firstDay;
    return [self initWithFrame:frame];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [self.calendar setLocale:[NSLocale currentLocale]]; 
        [self.calendar setFirstWeekday:self.calendarStartDay];
        self.cellWidth = DEFAULT_CELL_WIDTH;
        
        self.layer.cornerRadius = 6.0f;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOpacity = 0.4f;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;

        UIView *highlight = [[UIView alloc] initWithFrame:CGRectZero];
        highlight.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        highlight.layer.cornerRadius = 6.0f;
        [self addSubview:highlight];
        self.highlight = highlight;

        // SET UP THE HEADER
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;

        UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [prevButton setImage:[UIImage imageNamed:@"left_arrow.png"] forState:UIControlStateNormal];
        prevButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [prevButton addTarget:self action:@selector(moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:prevButton];
        self.prevButton = prevButton;

        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setImage:[UIImage imageNamed:@"right_arrow.png"] forState:UIControlStateNormal];
        nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [nextButton addTarget:self action:@selector(moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextButton];
        self.nextButton = nextButton;

        
        UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitButton setImage:[UIImage imageNamed:@"right_arrow.png"] forState:UIControlStateNormal];
        commitButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [commitButton addTarget:self action:@selector(commitCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
        self.commitButton = commitButton;
        
        
        // THE CALENDAR ITSELF
        UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];
        calendarContainer.layer.borderWidth = 1.0f;
        calendarContainer.layer.borderColor = [UIColor blackColor].CGColor;
        calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        calendarContainer.layer.cornerRadius = 4.0f;
        calendarContainer.clipsToBounds = YES;
        [self addSubview:calendarContainer];
        self.calendarContainer = calendarContainer;

        GradientView *daysHeader = [[GradientView alloc] initWithFrame:CGRectZero];
        daysHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self.calendarContainer addSubview:daysHeader];
        self.daysHeader = daysHeader;

        NSMutableArray *labels = [NSMutableArray array];
        for (NSString *day in [self getDaysOfTheWeek]) {
            UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            dayOfWeekLabel.text = [day uppercaseString];
            dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
            dayOfWeekLabel.backgroundColor = [UIColor clearColor];
            dayOfWeekLabel.shadowColor = [UIColor whiteColor];
            dayOfWeekLabel.shadowOffset = CGSizeMake(0, 1);
            [labels addObject:dayOfWeekLabel];
            [self.calendarContainer addSubview:dayOfWeekLabel];
        }
        self.dayOfWeekLabels = labels;

        // at most we'll need 42 buttons, so let's just bite the bullet and make them now...
        NSMutableArray *dateButtons = [NSMutableArray array];
        dateButtons = [NSMutableArray array];
        for (int i = 0; i < 43; i++) {
            DateButton *dateButton = [DateButton buttonWithType:UIButtonTypeCustom];
            [dateButton setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
            [dateButton addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [dateButtons addObject:dateButton];
        }
        self.dateButtons = dateButtons;

        NSMutableSet *dateArray = [NSMutableSet set];
        self.dateArray = dateArray;
        
        
        NSMutableSet *selectButtons = [NSMutableSet set];
        self.selectButtons = selectButtons;
        // initialize the thing
        self.monthShowing = [NSDate date];
        [self setDefaultStyle];
    }
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNext:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeGesture];

    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePre:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeGesture];

    
    
    
    NSDictionary * parames = @{};
    [[WebSocketManager instance]sendWithAction:@"endorsement.get_times" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
        SLog(@"%@",result);
        NSMutableSet *temS = [[NSMutableSet alloc]initWithArray:[result objectForKey:@"times"]];
        self.dateArray = temS;
        self.selectButtons = [self SelectDateFromArray:[result objectForKey:@"times"]];
        [self setNeedsLayout];
    }];
    

    [self layoutSubviews]; // TODO: this is a hack to get the first month to show properly
    return self;
}


- (void)swipePre:(UISwipeGestureRecognizer*)gesture
{
    [self moveCalendarToPreviousMonth];
}

- (void)swipeNext:(UISwipeGestureRecognizer*)gesture
{
    [self moveCalendarToNextMonth];
}

-(void)commitCalendarToNextMonth
{
    NSMutableArray *commitArray = [[NSMutableArray alloc]initWithArray:[self.dateArray allObjects]];
    NSDictionary * parames = @{@"times":commitArray};
    [[WebSocketManager instance]sendWithAction:@"endorsement.set_times" parameters:parames callback:^(WSRequest *request, NSDictionary *result) {
        SLog(@"%@",result);
        
    }];

}


- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat containerWidth = self.bounds.size.width - (CALENDAR_MARGIN * 2);
    self.cellWidth = (containerWidth / 7.0) - CELL_BORDER_WIDTH;

    CGFloat containerHeight = ([self numberOfWeeksInMonthContainingDate:self.monthShowing] * (self.cellWidth + CELL_BORDER_WIDTH) + DAYS_HEADER_HEIGHT);


    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + CALENDAR_MARGIN + TOP_HEIGHT;
    self.frame = newFrame;

    self.highlight.frame = CGRectMake(1, 1, self.bounds.size.width - 2, 1);

    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, TOP_HEIGHT);
    self.prevButton.frame = CGRectMake(BUTTON_MARGIN*10, BUTTON_MARGIN, 78, 38);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - 78 - BUTTON_MARGIN*10, BUTTON_MARGIN, 78, 38);

    self.commitButton.frame = CGRectMake(self.bounds.size.width - 48 - BUTTON_MARGIN - 50, BUTTON_MARGIN, 48, 38);
    
    self.calendarContainer.frame = CGRectMake(CALENDAR_MARGIN, CGRectGetMaxY(self.titleLabel.frame), containerWidth, containerHeight);
    self.daysHeader.frame = CGRectMake(0, 0, self.calendarContainer.frame.size.width, DAYS_HEADER_HEIGHT);

    CGRect lastDayFrame = CGRectZero;
    for (UILabel *dayLabel in self.dayOfWeekLabels) {
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame) + CELL_BORDER_WIDTH, lastDayFrame.origin.y, self.cellWidth, self.daysHeader.frame.size.height);
        lastDayFrame = dayLabel.frame;
    }

    for (DateButton *dateButton in self.dateButtons) {
        [dateButton removeFromSuperview];
    }

    NSDate *date = [self firstDayOfMonthContainingDate:self.monthShowing];
    uint dateButtonPosition = 0;
    while ([self dateIsInMonthShowing:date]) {
        DateButton *dateButton = [self.dateButtons objectAtIndex:dateButtonPosition];

        dateButton.date = date;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *showtimeNew = [dateFormatter stringFromDate:dateButton.date];
        BOOL isSelected = [self compare:dateButton.date];
        
        
        if (isSelected&&![self dateIsBeforeToday:dateButton.date]){//^isSelected) {
            NSLog(@"dateButton.date = %@",showtimeNew);
            dateButton.backgroundColor = self.selectedDateBackgroundColor;
            [dateButton setTitleColor:self.selectedDateTextColor forState:UIControlStateNormal];
        } else if ([self dateIsToday:dateButton.date]) {
            [dateButton setTitleColor:self.currentDateTextColor forState:UIControlStateNormal];
            dateButton.backgroundColor = self.currentDateBackgroundColor;
        } else if([self dateIsBeforeToday:dateButton.date]){
            [dateButton setTitleColor:self.timeoutDateBackgroundColor forState:UIControlStateNormal];
            dateButton.backgroundColor = [self dateBackgroundColor];
        } else if([self dateIsBeforeToday:dateButton.date]){
            [dateButton setTitleColor:self.orderedDateTextColor forState:UIControlStateNormal];
            dateButton.backgroundColor = [self orderedDateBackgroundColor];
        } else {
            dateButton.backgroundColor = [self dateBackgroundColor];
            [dateButton setTitleColor:[self dateTextColor] forState:UIControlStateNormal];
        }

        dateButton.frame = [self calculateDayCellFrame:date];

        [self.calendarContainer addSubview:dateButton];

        date = [self nextDay:date];
        dateButtonPosition++;
    }
}


-(BOOL)compare:(NSDate*)date
{
    if([self.selectButtons containsObject:date])
    {
        return YES;
    }
    return NO;
}
- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = aMonthShowing;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM YYYY";
    self.titleLabel.text = [dateFormatter stringFromDate:aMonthShowing];
    [self setNeedsLayout];
}

- (void)setDefaultStyle {
    self.backgroundColor = UIColorFromRGB(0x393B40);

    [self setTitleColor:[UIColor whiteColor]];
    [self setTitleFont:[UIFont boldSystemFontOfSize:17.0]];

    [self setDayOfWeekFont:[UIFont boldSystemFontOfSize:12.0]];
    [self setDayOfWeekTextColor:UIColorFromRGB(0x999999)];
    [self setDayOfWeekBottomColor:UIColorFromRGB(0xCCCFD5) topColor:[UIColor whiteColor]];

    [self setDateFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self setDateTextColor:UIColorFromRGB(0x393B40)];
    [self setDateBackgroundColor:UIColorFromRGB(0xF2F2F2)];
    [self setDateBorderColor:UIColorFromRGB(0xDAE1E6)];

    [self setSelectedDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setSelectedDateBackgroundColor:UIColorFromRGB(0x46CF17)];
    
    [self setCurrentDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setCurrentDateBackgroundColor:[UIColor lightGrayColor]];

    [self setTimeoutDateTextColor:UIColorFromRGB(0xC8C8C8)];
    [self setTimeoutDateBackgroundColor:[UIColor lightGrayColor]];
    
    [self setOrderedDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setOrderedDateBackgroundColor:UIColorFromRGB(0xFB452C)];
    
    
}

- (CGRect)calculateDayCellFrame:(NSDate *)date {
    int row = [self weekNumberInMonthForDate:date] - 1;
    int placeInWeek = (([self dayOfWeekForDate:date] - 1) - self.calendar.firstWeekday + 8) % 7;

    return CGRectMake(placeInWeek * (self.cellWidth + CELL_BORDER_WIDTH), (row * (self.cellWidth + CELL_BORDER_WIDTH)) + CGRectGetMaxY(self.daysHeader.frame) + CELL_BORDER_WIDTH, self.cellWidth, self.cellWidth);
}

- (void)moveCalendarToNextMonth {
    NSDateComponents* comps = [[NSDateComponents alloc]init];
    [comps setMonth:1];
    self.monthShowing = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
}

- (void)moveCalendarToPreviousMonth {
    if([self isPrevMonth])
    {
        return;
    }
    self.monthShowing = [[self firstDayOfMonthContainingDate:self.monthShowing] dateByAddingTimeInterval:-100000];
}

-(BOOL)isPrevMonth
{

NSDateComponents *otherDay = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.monthShowing];
NSDateComponents *today = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    return ([today year] >[otherDay year])||(([today year] ==[otherDay year])&&[today month] >= [otherDay month]);
 
}

-(NSMutableSet*)SelectDateFromArray:(NSMutableArray*)Array
{
    NSLog(@"%@",Array);
    NSMutableSet *tempMutableArray =[[NSMutableSet alloc]init];
    for (NSArray *ss in Array) {
        long long startTime = [[ss firstObject]longLongValue];
        long long endTime = [[ss lastObject]longLongValue];
        while (startTime<endTime) {
            {
                NSDate *sDate = [NSDate dateWithTimeIntervalSince1970:startTime];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *showtimeNew = [dateFormatter stringFromDate:sDate];
                NSLog(@"%@",showtimeNew);
                [tempMutableArray addObject:sDate];
                startTime = startTime+3600*24;
            }
        }
        
    }
    NSLog(@"%@",tempMutableArray);
    return tempMutableArray;
}


- (void)dateButtonPressed:(id)sender {
    DateButton *dateButton = sender;
    self.selectedDate = dateButton.date;
    if([self dateIsBeforeToday:dateButton.date]){
        SLog(@"Invaild date!");
    }
    else{
    if([self.selectButtons containsObject:dateButton.date])
    {
        [self.selectButtons removeObject:dateButton.date];
        NSTimeInterval timestart = [dateButton.date timeIntervalSince1970];
        longsTime = [[NSNumber numberWithDouble:timestart] longLongValue];
        NSTimeInterval timeend = [dateButton.date timeIntervalSince1970]+3600*24;
        longdTime = [[NSNumber numberWithDouble:timeend] longLongValue];
        NSLog(@"%lld---%lld",longsTime,longdTime);
        NSArray *tempArray = [[NSArray alloc] initWithObjects:@(longsTime), @(longdTime), nil];
        NSSet *tempSet = [[NSSet alloc] initWithArray:tempArray];
        [self.dateArray removeObject:tempSet];
        NSLog(@"%@",self.dateArray);
        [self splite];

    }
    else
    {
        [self.selectButtons addObject:dateButton.date];
    NSTimeInterval timestart = [dateButton.date timeIntervalSince1970];
        longsTime = [[NSNumber numberWithDouble:timestart] longLongValue];
    NSTimeInterval timeend = [dateButton.date timeIntervalSince1970]+3600*24;
        longdTime = [[NSNumber numberWithDouble:timeend] longLongValue];
        NSLog(@"%lld---%lld",longsTime,longdTime);
        [self combine];
        
        
    }
    NSLog(@"self.dateArray = %@",self.dateArray);
    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[self.dateArray allObjects]];
    [self SelectDateFromArray:arr];
    [self.delegate calendar:self didSelectDate:self.selectedDate];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyCalendarCommit" object:self.dateArray];
    [self setNeedsLayout];
}




-(void)combine
{
        if ([self.dateArray count]!=0) {
            while ([self cycle]) {
                continue;
            };
            
        }
        else{
            
            NSArray *tempArray = [[NSArray alloc] initWithObjects:@(longsTime), @(longdTime), nil];
            [self.dateArray addObject:tempArray];
            NSLog(@"%@",self.dateArray);
        }

}

-(BOOL)cycle
{
    long long tempTime = longdTime;
    if (longsTime>longdTime) {
        longdTime = longsTime;
        longsTime = tempTime;
    }

    
    
    for (NSArray *s in self.dateArray) {
        if ((longsTime ==[[s firstObject] longLongValue])&&(longdTime ==[[s lastObject] longLongValue])) {
            NSLog(@"self.dateArray = %@",self.dateArray);
            return NO;
        }
        
        if (longdTime ==[[s firstObject] longLongValue]) {
            longdTime = [[s lastObject] longLongValue];
            [self.dateArray removeObject:s];
            NSLog(@"self.dateArray = %@",self.dateArray);
            return YES;
        }
        if (longsTime ==[[s lastObject] longLongValue]) {
            longsTime = [[s firstObject] longLongValue];
            [self.dateArray removeObject:s];
            NSLog(@"self.dateArray = %@",self.dateArray);
            return YES;
        }

    }

    NSArray *tempArray = [[NSArray alloc] initWithObjects:@(longsTime), @(longdTime), nil];
    NSMutableSet *tempSet =[[NSMutableSet alloc]initWithSet:self.dateArray];
    [tempSet addObject:tempArray];
    self.dateArray = tempSet;
    NSLog(@"tempSet = %@",tempSet);
    NSLog(@"self.dateArray = %@",self.dateArray);
    return YES;
}




-(void)splite
{
    if ([self.dateArray count]!=0) {
        [self splitecycle];
        
    }
    else{
        
        NSArray *tempArray = [[NSArray alloc] initWithObjects:@(longsTime), @(longdTime), nil];
        [self.dateArray addObject:tempArray];
        NSLog(@"%@",self.dateArray);
    }

}


-(void)splitecycle
{

    NSArray *midArray = [[NSArray alloc] init];
    
    for (NSArray *s in self.dateArray) {

        if ((longsTime >[[s firstObject] longLongValue])&&(longdTime <[[s lastObject] longLongValue])) {
            midArray = [NSArray arrayWithObjects:@(longdTime),@([[s lastObject] longLongValue]), nil];
            longdTime = longsTime;
            longsTime = [[s firstObject] longLongValue];
            [self.dateArray removeObject:s];
            NSLog(@"self.dateArray = %@",self.dateArray);
            break;
        }
            if ([self.dateArray count] == 0) {
                break;
            }
            else
            {
                if ((longsTime ==[[s firstObject] longLongValue])&&(longdTime ==[[s lastObject] longLongValue])) {
                    
                    [self.dateArray removeObject:s];
                    NSLog(@"self.dateArray = %@",self.dateArray);
                    return;
                }
                if (longsTime ==[[s firstObject] longLongValue]) {
                    longsTime = longsTime+3600*24;
                    longdTime = [[s lastObject] longLongValue];
                    //[self.dateArray removeObject:s];
                    [self.dateArray removeObject:s];
                    NSLog(@"self.dateArray = %@",self.dateArray);
                    break;
                }
                if (longdTime ==[[s lastObject] longLongValue]) {
                    longdTime = longdTime-3600*24;
                    longsTime = [[s firstObject] longLongValue];
                    [self.dateArray removeObject:s];
                    break;
                    NSLog(@"self.dateArray = %@",self.dateArray);
                }
            }
        NSLog(@"hello");
        }
   NSArray *tempArray = [[NSArray alloc] initWithObjects:@(longsTime), @(longdTime), nil];
    NSMutableSet *tempSet =[[NSMutableSet alloc]initWithSet:self.dateArray];
    [tempSet addObject:tempArray];
     if ([midArray count]!=0) {
         [tempSet addObject:midArray];
         
     }
    self.dateArray = tempSet;
    NSLog(@"self.dateArray = %@",self.dateArray);

}

#pragma mark - Theming getters/setters

- (void)setTitleFont:(UIFont *)font {
    self.titleLabel.font = font;
}
- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color {
    self.titleLabel.textColor = color;
}
- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setButtonColor:(UIColor *)color {
    [self.prevButton setImage:[CKCalendarView imageNamed:@"left_arrow.png" withColor:color] forState:UIControlStateNormal];
    [self.nextButton setImage:[CKCalendarView imageNamed:@"right_arrow.png" withColor:color] forState:UIControlStateNormal];
}

- (void)setInnerBorderColor:(UIColor *)color {
    self.calendarContainer.layer.borderColor = color.CGColor;
}

- (void)setDayOfWeekFont:(UIFont *)font {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (UIFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (UIColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor {
    [self.daysHeader setColors:[NSArray arrayWithObjects:topColor, bottomColor, nil]];
}

- (void)setDateFont:(UIFont *)font {
    for (DateButton *dateButton in self.dateButtons) {
        dateButton.titleLabel.font = font;
    }
}
- (UIFont *)dateFont {
    return (self.dateButtons.count > 0) ? ((DateButton *)[self.dateButtons lastObject]).titleLabel.font : nil;
}

- (void)setDateTextColor:(UIColor *)color {
    for (DateButton *dateButton in self.dateButtons) {
        [dateButton setTitleColor:color forState:UIControlStateNormal];
    }
}
- (UIColor *)dateTextColor {
    return (self.dateButtons.count > 0) ? [((DateButton *)[self.dateButtons lastObject]) titleColorForState:UIControlStateNormal] : nil;
}

- (void)setDateBackgroundColor:(UIColor *)color {
    for (DateButton *dateButton in self.dateButtons) {
        dateButton.backgroundColor = color;
    }
}
- (UIColor *)dateBackgroundColor {
    return (self.dateButtons.count > 0) ? ((DateButton *)[self.dateButtons lastObject]).backgroundColor : nil;
}

- (void)setDateBorderColor:(UIColor *)color {
    self.calendarContainer.backgroundColor = color;
}
- (UIColor *)dateBorderColor {
    return self.calendarContainer.backgroundColor;
}

#pragma mark - Calendar helpers

- (NSDate *)firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    [comps setDay:1];
    return [self.calendar dateFromComponents:comps];
}

- (NSArray *)getDaysOfTheWeek {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // adjust array depending on which weekday should be first
    NSArray *weekdays = [dateFormatter shortWeekdaySymbols];
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] -1;
    if (firstWeekdayIndex > 0)
    {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7-firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0,firstWeekdayIndex)]];
    }
    return weekdays;
}

- (int)dayOfWeekForDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    return comps.weekday;
}

- (BOOL)dateIsToday:(NSDate *)date {
    NSDateComponents *otherDay = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *today = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    return (([today day] == [otherDay day] &&
             [today month] == [otherDay month] &&
             [today year] >= [otherDay year] )&&
            [today era] >= [otherDay era]);
}

- (BOOL)dateIsBeforeToday:(NSDate *)date {
    NSTimeInterval diff = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];
    return (diff>0);
}

- (int)weekNumberInMonthForDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSWeekOfMonthCalendarUnit) fromDate:date];
    return comps.weekOfMonth;
}

- (int)numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (BOOL)dateIsInMonthShowing:(NSDate *)date {
    NSDateComponents *comps1 = [self.calendar components:(NSMonthCalendarUnit) fromDate:self.monthShowing];
    NSDateComponents *comps2 = [self.calendar components:(NSMonthCalendarUnit) fromDate:date];
    return comps1.month == comps2.month;
}

- (NSDate *)nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    UIImage *img = [UIImage imageNamed:name];

    UIGraphicsBeginImageContext(img.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];

    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);

    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);

    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return coloredImg;
}

@end