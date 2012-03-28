//
//  calendarViewController.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "calendarViewController.h"

@implementation calendarViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	_calendarView = (CalendarView*)self.view;
	[_calendarView setDelegate:self];
	[_calendarView setTopTime:[[NSDate date] timeIntervalSinceReferenceDate]];
	[_calendarView setPixelsPerHour:PIXELS_PER_HOUR];
	
    [super viewDidLoad];
	[self createGestureRecognizers];
	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)createGestureRecognizers {
    UITapGestureRecognizer *singleFingerDTap =
		[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 2;
    [_calendarView addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
	
	UILongPressGestureRecognizer *longPress =
	[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [_calendarView addGestureRecognizer:longPress];
    [longPress release];
	
    UIPanGestureRecognizer *panGesture =
		[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [_calendarView addGestureRecognizer:panGesture];
    [panGesture release];
	
    UIPinchGestureRecognizer *pinchGesture =
		[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [_calendarView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
	float yLoc = [recognizer locationInView:_calendarView].y;
	
	if (_activeEventBlock == NULL) {
		_activeEventBlock = [[EventBlock alloc] init];
		_activeEventBlock.delegate = self;
		[_calendarView addEventBlock:_activeEventBlock];
		_activeEventBlock.startTime = [self pixelToTime:yLoc];		
	}
	
	_activeEventBlock.endTime = [self pixelToTime:yLoc];
	
	if ([recognizer state] == UIGestureRecognizerStateEnded) {
		[_activeEventBlock release];
		_activeEventBlock = NULL;
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer {
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)recognizer {
	_scrollVel = [recognizer velocityInView:_calendarView].y;
	if (_scrollVel < -SCROLL_MAX) {
		_scrollVel = -SCROLL_MAX;
	} else if (_scrollVel > SCROLL_MAX) {
		_scrollVel = SCROLL_MAX;
	}
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)recognize {
	[recognize scale];
}

- (NSTimeInterval)pixelToTime:(float)pixel {
	return [_calendarView topTime] + pixel / [_calendarView pixelsPerHour] * SECONDS_PER_HOUR;
}

- (float)timeToPixel:(NSTimeInterval)time {
	return (time - [_calendarView topTime]) / (float)SECONDS_PER_HOUR * [_calendarView pixelsPerHour];
}

- (void)runLoop {
	_scrollVel *= SCROLL_DECEL;
	_calendarView.topTime += (-_scrollVel / SCROLL_RATIO);
	
	[_calendarView update];		

	[_calendarView setNeedsDisplay];
}

- (void)touchDown:(id)sender {
	_scrollVel = 0;
}

- (void)touchUp:(id)sender {
}

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
