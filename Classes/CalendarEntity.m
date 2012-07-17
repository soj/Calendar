#import "CalendarEntity.h"

@implementation CalendarEntity

@synthesize startTime=_startTime, endTime=_endTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
	
    if (self = [super init]) {	
        _sublayerDelegate = [[LayerDelegate alloc] initWithView:self];
        
        _baseTime = baseTime;
        [self setStartTime:startTime];
        [self setEndTime:endTime];
        
        [self setFrame:[self reframe]];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	_startTime = startTime;
	[self setNeedsDisplay];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	_endTime = endTime;
	[self setNeedsDisplay];
}

- (NSTimeInterval)size {
    return _endTime - _startTime;
}
     
- (CGRect)reframe {
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return CGRectZero;
}

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context {
}

@end
