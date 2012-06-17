#import <Foundation/Foundation.h>
#import "CalendarEventBase.h"

#define BORDER_COLOR		[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define EVENT_DX			65.0

@interface CalendarEvent : CalendarEventBase <UITextFieldDelegate> {
	UITextField *_textField;
}

- (void)setFocus;
- (void)drawInContext:(CGContextRef)context;

@end
