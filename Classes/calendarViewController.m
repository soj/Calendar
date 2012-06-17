//
//  calendarViewController.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "CalendarViewController.h"

@implementation CalendarViewController

#pragma mark -
#pragma mark ViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[(UIScrollView*)self.view setContentSize:CGSizeMake(0, [self getScreenHeight] + 400)];
	
	_entityManager = [[EntityManager alloc] initWithView:self.view andDelegate:self];
	_baseTime = _topTime = [[NSDate date] timeIntervalSinceReferenceDate];
	_visibleEntities = [[NSMutableSet alloc] init];
	_pixelsPerHour = PIXELS_PER_HOUR;
		
	[self createGestureRecognizers];
	
	int topTime = _topTime - TIME_INTERVAL_BUFFER;
	int calHourOffset = [self calendarHourFromReferenceHour:(topTime / SECONDS_PER_HOUR)];
	int topTimeOffset = topTime - calHourOffset * SECONDS_PER_HOUR - ((int)topTime % SECONDS_PER_HOUR);
	int bottomTime = topTime + [self getVisibleTimeInterval] + TIME_INTERVAL_BUFFER * 2 * 10;
	
	while (topTimeOffset < bottomTime) {
		NSNumber *day = [NSNumber numberWithInt:(topTimeOffset / SECONDS_PER_HOUR / HOURS_PER_DAY)];
		
		if (![_entityManager entityExistsWithClass:[CalendarDay class] andKey:day]) {
			CalendarDay *newDay = [_entityManager createCalendarDayWithStartTime:topTimeOffset];
			[_entityManager registerEntity:newDay withKey:day];
		}
		
		topTimeOffset += SECONDS_PER_HOUR * HOURS_PER_DAY;
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (int)getScreenHeight {
	return [self.view frame].size.height;
}

- (int)getScreenWidth {
	return [[UIScreen mainScreen] bounds].size.width;
}

#pragma mark -
#pragma mark CalendarViewDelegate Methods

- (NSTimeInterval)pixelToTime:(float)pixel {
	return _baseTime + pixel / _pixelsPerHour * SECONDS_PER_HOUR;
}

- (float)timeToPixel:(NSTimeInterval)time {
	return (time - _baseTime) / (float)SECONDS_PER_HOUR * _pixelsPerHour;
}

- (float)getPixelsPerHour {
	return _pixelsPerHour;
}

- (NSTimeInterval)getVisibleTimeInterval {
	return [self getScreenHeight] / _pixelsPerHour * SECONDS_PER_HOUR;
}

- (NSInteger)calendarHourFromReferenceHour:(int)refHour {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(refHour * SECONDS_PER_HOUR)];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:date];
	NSInteger calHour = [components hour];
	return calHour;
}

#pragma mark -
#pragma mark Entity Management

- (BOOL)visibilityChange {
	NSMutableSet *compSet = [[NSMutableSet alloc] init];	
	NSEnumerator *ents = [[_entityManager allEntities] objectEnumerator];
	CalendarEntity *ent;
	while (ent = [ents nextObject]) {
		if ([self getEntityVisibility:ent]) {
			[compSet addObject:ent];
		} else if ([ent removeWhenInvisible]) {
			[_entityManager removeEntity:ent];
		}
	}
	
	if (![compSet isEqualToSet:_visibleEntities]) {
		[_visibleEntities release];
		_visibleEntities = compSet;
		
		return YES;
	}
	
	return NO;
}

- (void)createCalendarDayIfNecessary {
	int topTime = _topTime - TIME_INTERVAL_BUFFER;
	int calHourOffset = [self calendarHourFromReferenceHour:(topTime / SECONDS_PER_HOUR)];
	int topTimeOffset = topTime - calHourOffset * SECONDS_PER_HOUR - ((int)topTime % SECONDS_PER_HOUR);
	int bottomTime = topTime + [self getVisibleTimeInterval] + TIME_INTERVAL_BUFFER * 2;
	
	while (topTimeOffset < bottomTime) {
		NSNumber *day = [NSNumber numberWithInt:(topTimeOffset / SECONDS_PER_HOUR / HOURS_PER_DAY)];
		
		if (![_entityManager entityExistsWithClass:[CalendarDay class] andKey:day]) {
			CalendarDay *newDay = [_entityManager createCalendarDayWithStartTime:topTimeOffset];
			[_entityManager registerEntity:newDay withKey:day];
		}
		
		topTimeOffset += SECONDS_PER_HOUR * HOURS_PER_DAY;
	}
	
	[self visibilityChange];
}

- (BOOL)getEntityVisibility:(CalendarEntity*)ent {
	float topPixel = [self timeToPixel:[ent startTime]];
	float bottomPixel = [self timeToPixel:[ent endTime]];
	int scrollOffset = [(UIScrollView*)self.view contentOffset].y;
	return
		(topPixel > scrollOffset && topPixel < [self getScreenHeight] + scrollOffset + SCROLL_BUFFER) ||
		(bottomPixel > scrollOffset - SCROLL_BUFFER && bottomPixel < [self getScreenHeight] + scrollOffset) ||
		(topPixel < scrollOffset && bottomPixel > [self getScreenHeight] + scrollOffset);
}

#pragma mark -
#pragma mark Gesture Recognizers

- (void)createGestureRecognizers {
    UITapGestureRecognizer *singleFingerDTap =
		[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
	
	UILongPressGestureRecognizer *longPress =
	[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    [longPress release];
	
    UIPinchGestureRecognizer *pinchGesture =
		[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGesture];
    [pinchGesture release];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {	
	float yLoc = [recognizer locationInView:self.view].y;
	
	if (_activeEventBlock == NULL) {
		_activeEventBlock = [_entityManager createEventBlockWithStartTime:[self pixelToTime:yLoc]];
	}
	
	_activeEventBlock.endTime = [self pixelToTime:yLoc];
	[self visibilityChange];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		[_activeEventBlock setFocus];
		
		[_activeEventBlock release];
		_activeEventBlock = NULL;
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer {
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)recognize {
	[recognize scale];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// Allow for infinite scrolling
	[scrollView setContentSize:CGSizeMake(0, [scrollView contentOffset].y + [self getScreenHeight] + 400)];
	
	_topTime = (NSTimeInterval)[scrollView contentOffset].y / _pixelsPerHour * SECONDS_PER_HOUR + _baseTime;
	
	[self createCalendarDayIfNecessary];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it ]doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
