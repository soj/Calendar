#import <Foundation/Foundation.h>
#import "CalendarEntity.h"
#import "ShadowedTextField.h"
#import "Category.h"

#define EVENT_DX			65.0
#define RIGHT_RAIL_WIDTH	45.0

#define BORDER_COLOR		[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define BORDER_PADDING_X	10.0
#define BORDER_PADDING_Y	5.0

@interface CalendarEvent : CalendarEntity <UITextFieldDelegate> {
	ShadowedTextField *_nameField;
	ShadowedTextField *_catField;
    
    int _multitaskIndex;
    int _numMultitasks;
}

- (void)setFocus;
- (void)drawInContext:(CGContextRef)context;
- (void)setCategory:(Category*)cat;
- (void)setMultitaskIndex:(int)index outOf:(int)numMultitasks;
- (void)resizeTextFields;

@end
