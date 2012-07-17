#import <Foundation/Foundation.h>
#import "UIColor+Tools.h"
#import "CalendarEntity.h"
#import "Category.h"
#import "CategoryChooserController.h"
#import "LayerDelegate.h"

#define EVENT_DX			75.0
#define RAIL_COLOR_WIDTH    20.0
#define RIGHT_RAIL_WIDTH	5.0
#define DEPTH_BORDER_WIDTH  10.0
#define DEPTH_BORDER_DARKEN_MULTIPLIER 0.8

#define BORDER_PADDING_X	10.0
#define BORDER_PADDING_Y	5.0

#define EVENT_BG_COLOR      [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]

#define NAME_COLOR          [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.0]
#define NAME_FONT           [UIFont fontWithName:@"Helvetica-Light" size:25.0f]
#define NAME_FIELD_HEIGHT   30.0f

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooser;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

@interface CalendarEvent : CalendarEntity <UITextFieldDelegate> {
    id<CalendarEventDelegate> _delegate;
    
    CALayer *_boxLayer;
    CALayer *_railLayer;
    CALayer *_depthLayer;

    BOOL _hasFocus;
    
	NSString *_eventId;
	UITextField *_nameField;

    UIColor *_baseColor;
}

@property (strong) id delegate;
@property (nonatomic, strong) NSString *eventId;
@property BOOL hasFocus;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id<CalendarEventDelegate>)delegate;

- (void)setFocus;
- (void)resignFocus;
- (BOOL)hasFocus;

- (void)setTitle:(NSString*)title;
- (void)setColor:(UIColor*)color;

- (void)resizeTextFields;

@end
