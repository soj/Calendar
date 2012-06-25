#import "CalendarDayController.h"

@implementation CalendarDayController

@synthesize startTime=_startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id<CalendarDayDelegate>)delegate {
	self = [super initWithNibName:@"CalendarDayController" bundle:nil];

	if (self) {
		_delegate = delegate;
		_startTime = startTime;		// TODO: Assert that this is midnight of some day
		_eventBlocks = [[NSMutableSet alloc] init];
		
		NSAssert((int)_startTime == (int)[_delegate floorTimeToStartOfDay:_startTime],
				 @"The start time provided must be the first second of a given day");
		
		[self createGestureRecognizers];
		[self createCalendarDay];
	}
	
	return self;
}

- (void)setEvents:(NSArray*)events {
    NSEnumerator *e = [events objectEnumerator];
    Event *event;
    while (event = [e nextObject]) {
        CalendarEvent *newEvent = [self createEventBlockWithStartTime:[event startTime]];
        [newEvent setEndTime:[event endTime]];

        [newEvent setTitle:[[event ekEvent] title]];
    }
}

- (void)createCalendarDay {
	NSTimeInterval endTime = _startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	_calendarDay = [[CalendarDay alloc] initWithBaseTime:_startTime startTime:_startTime endTime:endTime andDelegate:_delegate];
	
	[_calendarDay setCurrentTime:[NSDate timeIntervalSinceReferenceDate]];
	NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(updateCurrentTime)];
	NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
	[invoc setSelector:@selector(updateCurrentTime)];
	[invoc setTarget:self];
	[NSTimer scheduledTimerWithTimeInterval:SECONDS_PER_MINUTE invocation:invoc repeats:YES];
	
	[(UIScrollView*)self.view setContentSize:_calendarDay.frame.size];
	[self.view addSubview:_calendarDay];
}

- (void)updateCurrentTime {
	[_calendarDay setCurrentTime:[NSDate timeIntervalSinceReferenceDate]];
	[_calendarDay setNeedsDisplay];
}

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)time {
	CalendarEvent *newBlock = [[CalendarEvent alloc] initWithBaseTime:_startTime startTime:time endTime:time andDelegate:_delegate];
	[_eventBlocks addObject:newBlock];
	
	UIPanGestureRecognizer *pan =
		[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureOnEventBlock:)];
    [newBlock addGestureRecognizer:pan];
    [pan release];
	
	[_calendarDay addSubview:newBlock];
	return newBlock;
}

- (void)checkForEventBlocksParallelTo:(CalendarEvent*)thisEvent {
	NSEnumerator *e = [_eventBlocks objectEnumerator];
	CalendarEvent *thatEvent;
    NSMutableSet *parallelBlocks = [[NSMutableSet alloc] initWithCapacity:[_eventBlocks count]];
    
	while (thatEvent = [e nextObject]) {
		if (timesIntersect(thatEvent.startTime, thatEvent.endTime, thisEvent.startTime, thisEvent.endTime)) {
			[parallelBlocks addObject:thatEvent];
		}
    }
    
    [parallelBlocks addObject:thisEvent];
    NSArray *descriptors = [[NSArray alloc] initWithObjects:
                           [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
                           [NSSortDescriptor sortDescriptorWithKey:@"eventId" ascending:YES],
                           nil];
    NSArray *sorted = [parallelBlocks sortedArrayUsingDescriptors:descriptors];
    
    for (int i = 0; i < [sorted count]; i++) {
        [(CalendarEvent*)[sorted objectAtIndex:i] setMultitaskIndex:i outOf:[sorted count]];
    }
    
    [parallelBlocks release];
}

#pragma mark -
#pragma mark Gesture Recognizers

- (void)createGestureRecognizers {
	UILongPressGestureRecognizer *longPress =
	[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    [longPress release];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {	
	float yLoc = [recognizer locationInView:_calendarDay].y;
	
	if (_activeEventBlock == NULL) {
		NSTimeInterval startTime = [_delegate floorTimeToMinInterval:([_delegate pixelToTimeOffset:yLoc] + _startTime)];
		_activeEventBlock = [self createEventBlockWithStartTime:startTime];
	}
	
	_activeEventBlock.endTime = _startTime + [_delegate pixelToTimeOffset:yLoc];
	[self checkForEventBlocksParallelTo:_activeEventBlock];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		_activeEventBlock.endTime = [_delegate floorTimeToMinInterval:[_activeEventBlock endTime]];
	
		[_activeEventBlock setFocus];
		_activeEventBlock = NULL;
	}
}

- (void)handlePanGestureOnEventBlock:(UIPanGestureRecognizer*)recognizer {
	if (_activeEventBlock == NULL) {
		if ([recognizer locationInView:[recognizer view]].y < EDGE_DRAG_PIXELS) {
			_activeEventBlock = (CalendarEvent*)[recognizer view];
			_initDragTime = [_activeEventBlock startTime];
			_dragStartTime = YES;
			_initDragPos = [recognizer translationInView:_activeEventBlock].y;
		} else if ([recognizer locationInView:[recognizer view]].y > [recognizer view].frame.size.height - EDGE_DRAG_PIXELS) {
			_activeEventBlock = (CalendarEvent*)[recognizer view];
			_initDragTime = [_activeEventBlock endTime];
			_dragStartTime = NO;
			_initDragPos = [recognizer translationInView:_activeEventBlock].y;
		} else {
			return;
		}
	}

	NSTimeInterval timeDiff = _initDragTime + [_delegate pixelToTimeOffset:([recognizer translationInView:_activeEventBlock].y - _initDragPos)];
	if (_dragStartTime) {
		[_activeEventBlock setStartTime:timeDiff];
	} else {
		[_activeEventBlock setEndTime:timeDiff];
	}
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		_activeEventBlock.startTime = [_delegate floorTimeToMinInterval:_activeEventBlock.startTime];
		_activeEventBlock.endTime = [_delegate floorTimeToMinInterval:_activeEventBlock.endTime];
		
		_activeEventBlock = NULL;
	}
}

#pragma mark -
#pragma mark UIViewController Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_topTime = (NSTimeInterval)[scrollView contentOffset].y / [_delegate getPixelsPerHour] * SECONDS_PER_HOUR + _startTime;
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
