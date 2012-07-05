#import "CalendarDayController.h"
#import "CalendarMath.h"

@implementation CalendarDayController

@synthesize startTime=_startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id<CalendarDayDelegate>)delegate {
	self = [super initWithNibName:@"CalendarDayController" bundle:nil];

	if (self) {
		_delegate = delegate;
		_startTime = startTime;		// TODO: Assert that this is midnight of some day
		_eventBlocks = [[NSMutableSet alloc] init];
		
		NSAssert((int)_startTime == (int)[CalendarMath floorTimeToStartOfDay:_startTime],
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
        [self createEventBlockWithExistingEvent:event];
    }
}

- (void)setActiveEventBlock:(CalendarEvent*)event {
    [self unsetActiveEventBlock];
    
    _activeEventBlock = event;
    [_activeEventBlock addGestureRecognizer:_eventBlockPan];
}

- (void)unsetActiveEventBlock {
    if (_activeEventBlock != NULL) {
        [_activeEventBlock removeGestureRecognizer:_eventBlockPan];
        _activeEventBlock = NULL;
    }
}

- (void)createCalendarDay {
	NSTimeInterval endTime = _startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	_calendarDay = [[CalendarDay alloc] initWithBaseTime:_startTime startTime:_startTime endTime:endTime];
	
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

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    CalendarEvent *newBlock = [[CalendarEvent alloc] initWithBaseTime:_startTime startTime:startTime
                                                              endTime:endTime andDelegate:self];
	[_eventBlocks addObject:newBlock];
    
    UITapGestureRecognizer *eventBlockTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEventBlock:)];
    [newBlock addGestureRecognizer:eventBlockTap];
	
	[_calendarDay addSubview:newBlock];
	return newBlock;
}

- (CalendarEvent*)createEventBlockWithExistingEvent:(Event*)event {
    CalendarEvent *newBlock = [self createEventBlockWithStartTime:[event startTime] endTime:[event endTime]];
    [newBlock setTitle:[event title]];
    [newBlock setEventId:[event identifier]];
    return newBlock;
}

- (CalendarEvent*)createNewEventWithStartTime:(NSTimeInterval)time {
    NSTimeInterval endTime = time + MIN_TIME_INTERVAL;
    CalendarEvent* newBlock = [self createEventBlockWithStartTime:time endTime:endTime];
    
    Event* e = [_delegate createEventWithStartTime:time endTime:endTime];
    [newBlock setEventId:[e identifier]];
    
	return newBlock;
}

- (void)checkForEventBlocksParallelTo:(CalendarEvent*)thisEvent {
	NSEnumerator *e = [_eventBlocks objectEnumerator];
	CalendarEvent *thatEvent;
    NSMutableSet *parallelBlocks = [[NSMutableSet alloc] initWithCapacity:[_eventBlocks count]];
    
	while (thatEvent = [e nextObject]) {
		if ([CalendarMath timesIntersectS1:thatEvent.startTime e1:thatEvent.endTime s2:thisEvent.startTime e2:thisEvent.endTime]) {
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
}

#pragma mark -
#pragma mark Gesture Recognizers

- (void)createGestureRecognizers {
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
	UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    _eventBlockPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnEventBlock:)];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {	
	float yLoc = [recognizer locationInView:_calendarDay].y;
    
    if ([recognizer state] ==  UIGestureRecognizerStateBegan) {
		NSTimeInterval startTime = [CalendarMath roundTimeToGranularity:([[CalendarMath getInstance] pixelToTimeOffset:yLoc] + _startTime)];
		[self setActiveEventBlock:[self createNewEventWithStartTime:startTime]];
    }
	
	_activeEventBlock.endTime = _startTime + [[CalendarMath getInstance] pixelToTimeOffset:yLoc];
	[self checkForEventBlocksParallelTo:_activeEventBlock];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		_activeEventBlock.endTime = [CalendarMath roundTimeToGranularity:[_activeEventBlock endTime]];
        [_delegate updateEvent:_activeEventBlock.eventId endTime:_activeEventBlock.endTime];
		[_activeEventBlock setFocus];
	}
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    [self unsetActiveEventBlock];
}

- (void)handleTapOnEventBlock:(UITapGestureRecognizer*)recognizer {
    [self setActiveEventBlock:(CalendarEvent*)[recognizer view]];
}

- (void)handlePanOnEventBlock:(UIPanGestureRecognizer*)recognizer {
    NSAssert(_activeEventBlock == [recognizer view], @"Only the active event block may receive gestures");

    if ([recognizer state] ==  UIGestureRecognizerStateBegan) {
        if ([recognizer locationInView:[recognizer view]].y < EDGE_DRAG_PIXELS) {
            _dragType = kDragStartTime;
        } else if ([recognizer locationInView:[recognizer view]].y > [recognizer view].frame.size.height - EDGE_DRAG_PIXELS) {
            _dragType = kDragEndTime;
        } else {
            _dragType = kDragBoth;
        }
        _prevDragTime = 0;
    }

    float translation = [recognizer translationInView:_activeEventBlock].y;
	NSTimeInterval timeDiff = [[CalendarMath getInstance] pixelToTimeOffset:translation] - _prevDragTime;
	if (_dragType == kDragStartTime || _dragType == kDragBoth) {
		[_activeEventBlock setStartTime:(_activeEventBlock.startTime + timeDiff)];
	}
    if (_dragType == kDragEndTime || _dragType == kDragBoth) {
		[_activeEventBlock setEndTime:(_activeEventBlock.endTime + timeDiff)];
	}
    _prevDragTime = [[CalendarMath getInstance] pixelToTimeOffset:([recognizer translationInView:_activeEventBlock].y)];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		_activeEventBlock.startTime = [CalendarMath roundTimeToGranularity:_activeEventBlock.startTime];
		_activeEventBlock.endTime = [CalendarMath roundTimeToGranularity:_activeEventBlock.endTime];
        [_delegate updateEvent:_activeEventBlock.eventId startTime:_activeEventBlock.startTime];
        [_delegate updateEvent:_activeEventBlock.eventId endTime:_activeEventBlock.endTime];

	}
}

#pragma mark -
#pragma mark UIViewController Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark CalendarEventDelegate Methods

- (void)showCategoryChooserWithDelegate:(id<CategoryChooserDelegate>)delegate {
    [_delegate showCategoryChooserWithDelegate:delegate];
}

- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title {
    NSAssert([event eventId] != NULL, @"CalendarEvent does not have an identifier");
    [_delegate updateEvent:[event eventId] title:title];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_topTime = (NSTimeInterval)[scrollView contentOffset].y / [[CalendarMath getInstance] pixelsPerHour] * SECONDS_PER_HOUR + _startTime;
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

@end
