#import "CalendarDayController.h"

@implementation CalendarDayController

#pragma mark -
#pragma mark ViewController Methods

- (id)initWithDelegate:(id<CalendarDayDelegate>)delegate {
	self = [super initWithNibName:@"CalendarDayController" bundle:nil];

	if (self) {
		_delegate = delegate;
		_baseTime = _topTime = [[NSDate date] timeIntervalSinceReferenceDate];
		_eventBlocks = [[NSMutableSet alloc] init];
		
		[self createGestureRecognizers];
		[self.view addSubview:[self createCalendarDayWithStartTime:_baseTime]];
	}
	
	return self;
}

- (CalendarDay*)createCalendarDayWithStartTime:(NSTimeInterval)startTime {
	CGSize size = CGSizeMake([self.view frame].size.width, [_delegate getPixelsPerHour] * HOURS_PER_DAY);
	int endTime = startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	CalendarDay *newDay = [[CalendarDay alloc] initWithSize:size startTime:startTime endTime:endTime andDelegate:_delegate];
	return newDay;
}

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)startTime {
	CGSize size = CGSizeMake([self.view frame].size.width, [_delegate getPixelsPerHour] * HOURS_PER_DAY);
	CalendarEvent *newBlock = [[CalendarEvent alloc] initWithSize:size startTime:startTime endTime:startTime andDelegate:_delegate];
	[_eventBlocks addObject:newBlock];
	return newBlock;
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
		// TODO: Create new event block
	}
	
	_activeEventBlock.endTime = _baseTime + [_delegate pixelToTimeOffset:yLoc];
	
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
	_topTime = (NSTimeInterval)[scrollView contentOffset].y / [_delegate getPixelsPerHour] * SECONDS_PER_HOUR + _baseTime;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
