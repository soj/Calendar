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
	CGRect frame = CGRectMake(0, 0, [self.view frame].size.width, [_delegate getPixelsPerHour] * HOURS_PER_DAY);
	NSTimeInterval endTime = _startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	CalendarDay *newDay = [[CalendarDay alloc] initWithFrame:frame startTime:_startTime endTime:endTime andDelegate:_delegate];
	
	[(UIScrollView*)self.view setContentSize:frame.size];
	[self.view addSubview:newDay];
}

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)time {
	CGRect frame = CGRectMake(EVENT_DX, [_delegate timeOffsetToPixel:(time - _startTime)],
							  [_delegate dayWidth] - EVENT_DX - RIGHT_RAIL_WIDTH,
							  [_delegate getPixelsPerHour] * HOURS_PER_DAY);
	
	CalendarEvent *newBlock = [[CalendarEvent alloc] initWithFrame:frame startTime:time endTime:time andDelegate:_delegate];
	[_eventBlocks addObject:newBlock];
	
	[newBlock setFrame:frame];
	
	[self.view addSubview:newBlock];
	return newBlock;
}

- (void)chooseCategory:(Category*)cat {
	[_activeEventBlock setCategory:cat];
	_activeEventBlock = NULL;
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
