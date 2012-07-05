#import "CalendarSubEvent.h"
#import "CalendarMath.h"

@implementation CalendarSubEvent

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
    self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime andDelegate:delegate];
    
    if (self) {
        _multitaskIndex = 0;
    }
    return self;
}

- (void)setMultitaskIndex:(int)index { 
    NSAssert(_multitaskIndex >= 1, @"multitask index must be at least 1");
    
    _multitaskIndex = index;
    [self setFrame:[self reframe]];
    [self resizeTextFields];
}

- (CGRect)reframe {
    int multitaskDX = _multitaskIndex * MULTITASK_DX;
    int width = ([[CalendarMath getInstance] dayWidth] - EVENT_DX - RIGHT_RAIL_WIDTH) - multitaskDX;
    
    return CGRectMake(EVENT_DX + multitaskDX,
                      [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)],
                      width,
                      [[CalendarMath getInstance] pixelsPerHour] * (_endTime - _startTime) / SECONDS_PER_HOUR);
}

#pragma mark -
#pragma mark Drawing

- (void)drawInContext:(CGContextRef)context {
}

@end
