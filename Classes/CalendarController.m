#import "CalendarController.h"
#import "CalendarMath.h"

@implementation CalendarController

@synthesize scrollView=_scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    _calendar = [[Calendar alloc] init];
	_calendarDays = [[NSMutableDictionary alloc] init];
	
	[self setToday:[CalendarMath floorTimeToStartOfDay:[[NSDate date] timeIntervalSinceReferenceDate]]];
	
	CGSize totalSize = CGSizeMake(UI_DAY_WIDTH * 3, 480.0);
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
	frame.origin.x = ((int)startTime - (int)_yesterday) / SECONDS_PER_DAY * UI_DAY_WIDTH;
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
	
	[_scrollView setContentOffset:CGPointMake(UI_DAY_WIDTH, 0) animated:NO];
}

- (void)prepareToExit {
    [_calendar save];
}

- (void)jumpToTime:(NSTimeInterval)time {
    [self setToday:[CalendarMath floorTimeToStartOfDay:time]];
    [[_calendarDays objectForKey:[NSNumber numberWithInt:_today]] scrollToTime:time];
}

#pragma mark -
#pragma mark Notification Handling

- (UILocalNotification*)getNotificationForEvent:(Event*)event {
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSUInteger idx = [notifs indexOfObjectPassingTest:^BOOL(UILocalNotification* notif, NSUInteger idx, BOOL *stop) {
        return [[notif.userInfo objectForKey:@"eventIdentifier"] isEqualToString:event.identifier];
    }];
    if (idx < [notifs count]) {
        return [notifs objectAtIndex:idx];
    }
    return nil;
}

- (void)cancelLocalNotificationForEvent:(Event*)event {
    UILocalNotification *notif = [self getNotificationForEvent:event];
    if (notif) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
}

- (void)scheduleLocalNotificationForEvent:(Event*)event {
    if (!SHOW_NOTIFICATIONS ||
        event.startTime < [[NSDate date] timeIntervalSinceReferenceDate] + MIN_NOTIFICATION_FUTURE) {
        return;
    }
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate dateWithTimeIntervalSinceReferenceDate:event.startTime];
    notif.alertBody = event.title;
    notif.soundName = UILocalNotificationDefaultSoundName;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:event.identifier, @"eventIdentifier", [NSNumber numberWithFloat:event.startTime], @"eventStartTime", nil];
    notif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

#pragma mark -
#pragma mark CalendarDayDelegate Methods

- (void)showCategoryChooserWithDelegate:(id)delegate {
    CategoryChooserController *catController = [[CategoryChooserController alloc] initWithDelegate:delegate];
	[self.view addSubview:catController.view];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = catController.view.frame;
    CGRect newFrame = CGRectMake(frame.origin.x, 
                                screen.size.height,
                                frame.size.width, frame.size.height);
    [catController.view setFrame:newFrame];
    
    _catController = catController;
    [_catController animateIn];
}

- (void)dismissCategoryChooser {
    if (_catController != nil && [_catController.view superview] != nil) {
        [_catController animateOut];
    }
}

- (Event*)createEventWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    Event *newEvent = [_calendar createEventWithStartTime:startTime andEndTime:endTime];
    [self scheduleLocalNotificationForEvent:newEvent];
    return newEvent;
}

- (void)updateEvent:(NSString*)eventId title:(NSString*)title {
    [[_calendar eventWithId:eventId] setTitle:title];
}

- (void)updateEvent:(NSString*)eventId startTime:(NSTimeInterval)startTime {
    Event *e = [_calendar eventWithId:eventId];
    if (startTime != e.startTime) {
        [self cancelLocalNotificationForEvent:e];
        [self scheduleLocalNotificationForEvent:e];
    }
    [e setStartTime:startTime];
}

- (void)updateEvent:(NSString*)eventId endTime:(NSTimeInterval)endTime {
    [[_calendar eventWithId:eventId] setEndTime:endTime];
}

- (void)updateEvent:(NSString*)eventId category:(Category *)category {
    [[_calendar eventWithId:eventId] setCategoryIdentifier:category.identifier];
}

- (void)deleteEvent:(NSString*)eventId {
    Event *e = [_calendar eventWithId:eventId];
    if (e) {
        [self cancelLocalNotificationForEvent:e];
        [_calendar deleteEvent:eventId];
    }
}

- (BOOL)eventIsValid:(NSString*)eventId {
    Event *e = [_calendar eventWithId:eventId];
    return !(e.title == NULL || [e.title isEqualToString:DEFAULT_EVENT_TITLE] || [e.title isEqualToString:@""]);
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([scrollView contentOffset].x == 0) {
		_today -= SECONDS_PER_DAY;
	} else if ([scrollView contentOffset].x == UI_DAY_WIDTH * 2) {
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
