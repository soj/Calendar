#import "CalendarEntity.h"

@implementation CalendarEntity

@synthesize delegate=_delegate, startTime=_startTime, endTime=_endTime, entKey=_entKey;

- (id)initWithSize:(CGSize)size startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
	[super init];
	
	[self setStartTime:startTime];
	[self setEndTime:endTime];
	[self setDelegate:delegate];
	
	[self setFrame:CGRectMake(0, 0, size.width, size.height)];
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

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context {
}

- (void)dealloc {
    [super dealloc];
}


@end
