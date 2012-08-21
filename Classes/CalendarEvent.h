#import <Foundation/Foundation.h>
#import "UIColor+Tools.h"
#import "CalendarEntity.h"
#import "Category.h"
#import "CategoryChooserController.h"
#import "LayerDelegate.h"

#import "CalendarEventLayer.h"
#import "BoxLayer.h"
#import "DepthLayer.h"
#import "HighlightLayer.h"
#import "RailLayer.h"

#define UI_EVENT_DX             75.0
#define UI_RIGHT_PADDING        5.0
#define UI_EDGE_DRAG_PIXELS     35.0f
#define UI_DELETION_WIDTH       50.0

#define UI_NAME_FIELD_HEIGHT    35.0f

#define UI_NAME_COLOR           [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.0]
#define UI_NAME_FONT            [UIFont fontWithName:@"Helvetica-Light" size:26.0f]

#define UI_ANIM_DURATION_RAISE  1.15

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooser;
- (void)dismissCategoryChooser;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

@interface CalendarEvent : CalendarEntity <UITextViewDelegate> {
    id<CalendarEventDelegate> _delegate;
    
    BoxLayer *_boxLayer;
    HighlightLayer *_highlightLayer;
    RailLayer *_railLayer;
    DepthLayer *_depthLayer;
    CAShapeLayer *_depthMask;
    CAShapeLayer *_categoryLayer;

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
