#import <Foundation/Foundation.h>
#import "UIColor+Tools.h"
#import "CalendarEntity.h"
#import "ShadowedTextField.h"
#import "Category.h"
#import "CategoryChooserController.h"

#define EVENT_DX			65.0
#define RIGHT_RAIL_WIDTH	45.0

#define BORDER_COLOR		0, 0, 0, 0.4
#define BORDER_PADDING_X	10.0
#define BORDER_PADDING_Y	5.0

#define BG_GRADIENT_DARKEN  0.85

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooser;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

@interface CalendarEvent : CalendarEntity <UITextFieldDelegate> {
    id<CalendarEventDelegate> _delegate;
    
	NSString *_eventId;
	ShadowedTextField *_nameField;

    UIColor *_baseColor;
    
    int _multitaskIndex;
    int _numMultitasks;
}

@property (strong) id delegate;
@property (nonatomic, strong) NSString *eventId;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id<CalendarEventDelegate>)delegate;

- (void)setFocus;

- (void)setTitle:(NSString*)title;
- (void)setColor:(UIColor*)color;
- (void)setMultitaskIndex:(int)index outOf:(int)numMultitasks;

- (void)resizeTextFields;

@end
