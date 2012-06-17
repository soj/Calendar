#import "CalendarController.h"

@implementation CalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_pixelsPerHour = PIXELS_PER_HOUR;
	
	// Get current day
	int currentDay = [[NSDate date] timeIntervalSinceReferenceDate] / SECONDS_PER_DAY;
	
	// Create this day and the two days around it
	[self createDateControllerForDay:(currentDay - 1)];
	[self createDateControllerForDay:currentDay];
	[self createDateControllerForDay:(currentDay + 1)];
}

#pragma mark -
#pragma mark CalendarController Methods

- (void)createDateControllerForDay:(int)day {
	CalendarDayController *newDateController = [[CalendarDayController alloc] initWithDelegate:self];
	[_calendarDays setObject:newDateController forKey:[NSNumber numberWithInt:day]];
	[self.view addSubview:newDateController.view];
}

#pragma mark -
#pragma mark CalendarDayDelegate Methods

- (NSTimeInterval)pixelToTimeOffset:(float)pixel {
	return pixel / _pixelsPerHour * SECONDS_PER_HOUR;
}

- (float)timeOffsetToPixel:(NSTimeInterval)time {
	return time / (float)SECONDS_PER_HOUR * _pixelsPerHour;
}

- (float)getPixelsPerHour {
	return _pixelsPerHour;
}

- (NSInteger)calendarHourFromReferenceHour:(int)refHour {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(refHour * SECONDS_PER_HOUR)];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:date];
	NSInteger calHour = [components hour];
	return calHour;
}

#pragma mark -
#pragma mark ViewController Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
