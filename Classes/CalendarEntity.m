#import "CalendarEntity.h"

@implementation CalendarEntity

@synthesize delegate=_delegate, startTime=_startTime, endTime=_endTime, entKey=_entKey;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
	[super init];
	
    _baseTime = baseTime;
	[self setStartTime:startTime];
	[self setEndTime:endTime];
	[self setDelegate:delegate];
    
    [self setFrame:[self reframe]];
	[self setBackgroundColor:[UIColor clearColor]];
    
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	_startTime = startTime;
	if (_endTime - startTime < MIN_TIME_INTERVAL) {
		_endTime = startTime + MIN_TIME_INTERVAL;
	}
	
	[self setNeedsDisplay];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	_endTime = endTime;
	if (endTime - _startTime < MIN_TIME_INTERVAL) {
		_endTime = _startTime + MIN_TIME_INTERVAL;
	}
	
	[self setNeedsDisplay];
}
     
- (CGRect)reframe {
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context {
}

- (void)dealloc {
    [super dealloc];
}


@end
