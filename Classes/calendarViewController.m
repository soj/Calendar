//
//  calendarViewController.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "calendarViewController.h"

@implementation calendarViewController

@synthesize calendarView;

#pragma mark -
#pragma mark ViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[calendarView setDelegate:self];
	[(UIScrollView*)self.view setContentSize:CGSizeMake(0, SCREEN_H + 400)];
	
	NSTimeInterval startTime = [[NSDate date] timeIntervalSinceReferenceDate];
	[calendarView setTopTime:startTime];
	[calendarView setBaseTime:startTime];
	[calendarView setPixelsPerHour:PIXELS_PER_HOUR];
	
	[self createGestureRecognizers];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Gesture Recognizers

- (void)createGestureRecognizers {
    UITapGestureRecognizer *singleFingerDTap =
		[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 2;
    [calendarView addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
	
	UILongPressGestureRecognizer *longPress =
	[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [calendarView addGestureRecognizer:longPress];
    [longPress release];
	
    UIPinchGestureRecognizer *pinchGesture =
		[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [calendarView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
	float yLoc = [recognizer locationInView:calendarView].y;
	
	if (_activeEventBlock == NULL) {
		_activeEventBlock = [[EventBlock alloc] init];
		_activeEventBlock.delegate = self;
		[calendarView addEventBlock:_activeEventBlock];
		_activeEventBlock.startTime = [self pixelToTime:yLoc];
	}
	
	_activeEventBlock.endTime = [self pixelToTime:yLoc];
	[calendarView setNeedsDisplay];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		[_activeEventBlock release];
		_activeEventBlock = NULL;
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer {
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)recognize {
	[recognize scale];
}

- (void)touchDown:(id)sender {
}

- (void)touchUp:(id)sender {
}

#pragma mark -
#pragma mark Utility Functions

- (NSTimeInterval)pixelToTime:(float)pixel {
	return [calendarView baseTime] + pixel / [calendarView pixelsPerHour] * SECONDS_PER_HOUR;
}

- (float)timeToPixel:(NSTimeInterval)time {
	return (time - [calendarView baseTime]) / (float)SECONDS_PER_HOUR * [calendarView pixelsPerHour];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[(UIScrollView*)self.view setContentSize:CGSizeMake(0, [scrollView contentOffset].y + SCREEN_H + 400)];
	
	NSTimeInterval topTime = (NSTimeInterval)[scrollView contentOffset].y / [calendarView pixelsPerHour] * SECONDS_PER_HOUR + [calendarView baseTime];
	[calendarView setTopTime:topTime];
	
	if ([calendarView visibilityChange]) {
//		[calendarView setFrame:CGRectMake(0, 0, SCREEN_W, [scrollView contentOffset].y + SCREEN_H + 400)];
		[calendarView setNeedsDisplay];
	}
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
