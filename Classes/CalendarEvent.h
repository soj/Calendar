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

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooserWithDelegate:(id<CategoryChooserDelegate>)delegate;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

@interface CalendarEvent : CalendarEntity <UITextFieldDelegate, CategoryChooserDelegate> {
    id<CalendarEventDelegate> _delegate;
    
	NSString *_eventId;
	ShadowedTextField *_nameField;
	ShadowedTextField *_catField;
    
    int _multitaskIndex;
    int _numMultitasks;
}

@property (strong) id delegate;
@property (nonatomic, strong) NSString *eventId;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id<CalendarEventDelegate>)delegate;

- (void)setFocus;
- (void)drawInContext:(CGContextRef)context;
- (void)setCategory:(Category*)cat;
- (void)setMultitaskIndex:(int)index outOf:(int)numMultitasks;
- (void)resizeTextFields;
- (void)setTitle:(NSString*)title;

@end
