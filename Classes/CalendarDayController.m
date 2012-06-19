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

- (void)createCalendarDay {
	NSTimeInterval endTime = _startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	CalendarDay *newDay = [[CalendarDay alloc] initWithBaseTime:_startTime startTime:_startTime endTime:endTime andDelegate:_delegate];
	
	[(UIScrollView*)self.view setContentSize:newDay.frame.size];
	[self.view addSubview:newDay];
}

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)time {
	CalendarEvent *newBlock = [[CalendarEvent alloc] initWithBaseTime:_startTime startTime:time endTime:time andDelegate:_delegate];
	[_eventBlocks addObject:newBlock];
	
	[self.view addSubview:newBlock];
	return newBlock;
}

- (void)chooseCategory:(Category*)cat {
	[_activeEventBlock setCategory:cat];
	_activeEventBlock = NULL;
}

BOOL timesIntersect(NSTimeInterval s1, NSTimeInterval e1, NSTimeInterval s2, NSTimeInterval e2) {
	return (s1 > s2 && s1 < e2) || (e1 > s2 && e1 < e2) || (s1 < s2 && e1 > e2);
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
		_activeEventBlock = [self createEventBlockWithStartTime:([_delegate pixelToTimeOffset:yLoc] + _startTime)];
	}
	
	_activeEventBlock.endTime = _startTime + [_delegate pixelToTimeOffset:yLoc];
    [_activeEventBlock setFrame:[_activeEventBlock reframe]];
	[self checkForEventBlocksParallelTo:_activeEventBlock];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		[_activeEventBlock setFocus];
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer {
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)recognize {
	[recognize scale];
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
