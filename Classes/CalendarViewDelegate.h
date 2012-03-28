//
//  TouchViewDelegate.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CalendarViewDelegate
- (void)touchDown:(id)sender;
- (void)touchUp:(id)sender;
- (float)timeToPixel:(NSTimeInterval)time;
@end
