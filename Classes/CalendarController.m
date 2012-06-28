#import "CalendarController.h"
#import "CalendarMath.h"

@implementation CalendarController

@synthesize scrollView=_scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_calendar = [[Calendar alloc] init];
	_calendarDays = [[NSMutableDictionary alloc] init];
	
	[self setToday:[CalendarMath floorTimeToStartOfDay:[[NSDate date] timeIntervalSinceReferenceDate]]];
	
	CGSize totalSize = CGSizeMake(PIXELS_PER_DAY * 3, 480.0);
	[_scrollView setContentSize:totalSize];
}

#pragma mark -
#pragma mark CalendarController Methods

- (void)createDayControllerForStartTime:(NSTimeInterval)startTime {
	CalendarDayController *dayController;
    NSTimeInterval endTime = startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
    
	if ([_calendarDays objectForKey:[NSNumber numberWithInt:startTime]] != nil) {
		dayController = [_calendarDays objectForKey:[NSNumber numberWithInt:startTime]];
	} else {
		dayController = [[CalendarDayController alloc] initWithStartTime:startTime andDelegate:self];
		[_calendarDays setObject:dayController forKey:[NSNumber numberWithInt:startTime]];
        NSArray *events = [_calendar getEventsBetweenStartTime:[dayController startTime] andEndTime:endTime];
        [dayController setEvents:events];
	}

	if (![dayController.view superview]) {
		[_scrollView addSubview:dayController.view];
	}
	
	CGRect frame = dayController.view.frame;
	frame.origin.x = ((int)startTime - (int)_yesterday) / SECONDS_PER_DAY * PIXELS_PER_DAY;
	[dayController.view setFrame:frame];
}

- (void)setToday:(NSTimeInterval)today {
	_today = today;
	_yesterday = [CalendarMath floorTimeToStartOfDay:(_today - SECONDS_PER_DAY)];
	_tomorrow = [CalendarMath floorTimeToStartOfDay:(_today + SECONDS_PER_DAY)];
	
	NSEnumerator *e = [_calendarDays objectEnumerator];
	CalendarDayController *calDay;
	while (calDay = [e nextObject]) {
		if ([calDay startTime] != _today) {
			[calDay.view removeFromSuperview];
		}
    }
	
	[self createDayControllerForStartTime:_today];
	[self createDayControllerForStartTime:_yesterday];
	[self createDayControllerForStartTime:_tomorrow];
	
	[_scrollView setContentOffset:CGPointMake(PIXELS_PER_DAY, 0) animated:NO];
}

- (void)prepareToExit {
    [_calendar save];
}

- (void)showCategoryChooserWithDelegate:(id)delegate {
    CategoryChooserController *catController = [[CategoryChooserController alloc] initWithCalendar:_calendar andDelegate:delegate];
	[self.view addSubview:catController.view];
    _catController = catController;
}

- (void)createEventWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    [_calendar createEventWithStartTime:startTime andEndTime:endTime];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([scrollView contentOffset].x == 0) {
		_today -= SECONDS_PER_DAY;
	} else if ([scrollView contentOffset].x == PIXELS_PER_DAY * 2) {
		_today += SECONDS_PER_DAY;
	}
	
	[self setToday:_today];
}

#pragma mark -
#pragma mark ViewController Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
