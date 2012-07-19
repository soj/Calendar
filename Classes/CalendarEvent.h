#import <Foundation/Foundation.h>
#import "UIColor+Tools.h"
#import "CalendarEntity.h"
#import "Category.h"
#import "CategoryChooserController.h"
#import "LayerDelegate.h"

#define UI_EVENT_DX             75.0
#define UI_RIGHT_PADDING        5.0
#define UI_EDGE_DRAG_PIXELS     30.0f

#define UI_HIGHLIGHT_SIZE       20.0
#define UI_HIGHLIGHT_WIDTH      UI_BOX_BORDER_WIDTH
#define UI_HIGHLIGHT_PADDING    UI_BORDER_PADDING_X

#define UI_BOX_BORDER_WIDTH     1.0
#define UI_RAIL_COLOR_WIDTH     22.0
#define UI_DEPTH_BORDER_WIDTH   7.0
#define UI_DEPTH_BORDER_HEIGHT  5.0

#define UI_BOX_BG_WHITENESS     0.95
#define UI_DEPTH_BORDER_DARKEN  0.8

#define UI_BORDER_PADDING_X     10.0
#define UI_BORDER_PADDING_Y     7.0
#define UI_BORDER_MARGIN_Y      2.0

#define UI_NAME_FIELD_HEIGHT    35.0f

#define UI_EVENT_BG_COLOR       [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]
#define UI_NAME_COLOR           [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.0]
#define UI_NAME_FONT            [UIFont fontWithName:@"Helvetica-Light" size:26.0f]

#define UI_ANIM_DURATION_RAISE  0.15

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooser;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

typedef enum {
    kHighlightTop,
    kHighlightBottom,
    kHighlightAll
} HighlightArea;

@interface CalendarEvent : CalendarEntity <UITextFieldDelegate> {
    id<CalendarEventDelegate> _delegate;
    
    CALayer *_boxLayer;
    CALayer *_highlightLayer;
    CALayer *_railLayer;
    CALayer *_depthLayer;
    CAShapeLayer *_depthMask;

    HighlightArea _highlightArea;
    BOOL _hasFocus;
    BOOL _isActive;
    
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

- (void)setIsActive:(BOOL)isActive;

- (void)setTitle:(NSString*)title;
- (void)setColor:(UIColor*)color;

- (void)highlightArea:(HighlightArea)area;
- (void)unhighlight;

- (void)resizeTextFields;

@end
