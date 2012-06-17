//
//  CalendarController.m
//  calendar
//
//  Created by Fravic Fernando on 12-06-16.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "CalendarController.h"


@implementation CalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_pixelsPerHour = PIXELS_PER_HOUR;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
