//
//  EventBlockDrawer.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-22.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarEntity.h"

#define BORDER_COLOR		[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define EVENT_DX			65.0

@interface EventBlock : CalendarEntity <UITextFieldDelegate> {
	UITextField *_textField;
}

- (void)setFocus;

- (void)drawInContext:(CGContextRef)context;

@end
