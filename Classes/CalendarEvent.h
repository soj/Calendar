#import <Foundation/Foundation.h>
#import "UIColor+Tools.h"
#import "CalendarEntity.h"
#import "Category.h"
#import "CategoryChooserController.h"
#import "LayerDelegate.h"

#define UI_EVENT_DX             75.0
#define UI_RIGHT_PADDING        5.0
#define UI_EDGE_DRAG_PIXELS     35.0f
#define UI_DELETION_WIDTH       50.0

#define UI_HIGHLIGHT_LINE_SIZE  20.0
#define UI_HIGHLIGHT_HEIGHT     25.0
#define UI_HIGHLIGHT_WIDTH      UI_BOX_BORDER_WIDTH
#define UI_HIGHLIGHT_PADDING    UI_BORDER_PADDING_X

#define UI_BOX_BORDER_WIDTH     1.0
#define UI_RAIL_COLOR_WIDTH     22.0
#define UI_DEPTH_BORDER_WIDTH   7.0
#define UI_DEPTH_BORDER_HEIGHT  5.0

#define UI_BOX_BG_WHITENESS     0.9
#define UI_DEPTH_BORDER_DARKEN  0.8

#define UI_BORDER_PADDING_X     10.0
#define UI_BORDER_PADDING_Y     5.0
#define UI_BORDER_MARGIN_Y      2.0

#define UI_NAME_FIELD_HEIGHT    35.0f

#define UI_EVENT_BG_COLOR       [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]
#define UI_NAME_COLOR           [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.0]
#define UI_NAME_FONT            [UIFont fontWithName:@"Helvetica-Light" size:26.0f]

#define UI_ANIM_DURATION_RAISE  4.15

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooser;
- (void)dismissCategoryChooser;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

typedef enum {
    kHighlightTop,
    kHighlightBottom,
    kHighlightAll,
    kHighlightDelete
} HighlightArea;

@interface CalendarEvent : CalendarEntity <UITextViewDelegate> {
    id<CalendarEventDelegate> _delegate;
    
    CALayer *_boxLayer;
    CALayer *_highlightLayer;
    CALayer *_railLayer;
    CALayer *_depthLayer;
    CAShapeLayer *_depthMask;
    CAShapeLayer *_categoryLayer;

    HighlightArea _highlightArea;
    BOOL _hasFocus;
    BOOL _isActive;
    BOOL _hasCategory;
    
	NSString *_eventId;
	UITextView *_nameField;

    UIColor *_baseColor;
    
    float _deletionProgress;
}

@property (strong) id delegate;
@property (nonatomic, strong) NSString *eventId;
@property BOOL hasFocus;
@property BOOL hasCategory;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id<CalendarEventDelegate>)delegate;

- (BOOL)pointInsideTextView:(CGPoint)pt;
- (BOOL)pointInsideCatView:(CGPoint)pt;

- (void)setDeletionProgress:(float)dX;
- (void)nullDeletionProgress;

- (void)setNameFocus;
- (void)setCategoryFocus;
- (void)resignFocus;
- (BOOL)hasFocus;

- (void)setIsActive:(BOOL)isActive;

- (void)setTitle:(NSString*)title;
- (void)setColor:(UIColor*)color;

- (void)highlightArea:(HighlightArea)area;
- (void)unhighlight;

@end
