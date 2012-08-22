#import <Foundation/Foundation.h>
#import "UIColor+Tools.h"
#import "CalendarEntity.h"
#import "Category.h"
#import "CategoryChooserController.h"
#import "LayerDelegate.h"

#import "CalendarEventName.h"

#import "CalendarEventLayer.h"
#import "BoxLayer.h"
#import "DepthLayer.h"
#import "HighlightLayer.h"
#import "RailLayer.h"
#import "DepthMaskLayer.h"
#import "CategoryLayer.h"

@class CalendarEvent;

@protocol CalendarEventDelegate
- (void)showCategoryChooser;
- (void)dismissCategoryChooser;
- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title;
@end

@interface CalendarEvent : CalendarEntity <UITextViewDelegate> {
    id<CalendarEventDelegate> _delegate;
        
    CalendarEventName *_nameView;
    
    BoxLayer *_boxLayer;
    HighlightBoxLayer *_highlightLayer;
    RailLayer *_railLayer;
    DepthLayer *_depthLayer;
    DepthMaskLayer *_depthMask;
    CategoryLayer *_categoryLayer;
    NameLayer *_nameLayer;

    BOOL _hasFocus;
    BOOL _isActive;
    BOOL _hasCategory;
    
	NSString *_eventId;

    UIColor *_baseColor;
    
    float _deletionProgress;
}

@property (strong) id delegate;
@property (nonatomic, strong) NSString *eventId;
@property BOOL hasFocus;
@property BOOL hasCategory;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id<CalendarEventDelegate>)delegate;

- (BOOL)isPointInsideTextView:(CGPoint)pt;
- (BOOL)isPointInsideCatView:(CGPoint)pt;

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
