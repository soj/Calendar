#import "CalendarMath.h"

@implementation CalendarMath

@synthesize pixelsPerHour=_pixelsPerHour, dayWidth=_dayWidth;

static CalendarMath* instance = nil;

+ (CalendarMath*)getInstance {
    if (instance == nil) {
        instance = [[CalendarMath alloc] init];
    }
    return instance;
}

- (id)init {
    NSAssert(instance == nil, @"Attempted to create multiple instances of Singleton");
    
    if (self = [super init]) {
        _pixelsPerHour = PIXELS_PER_HOUR;
        _dayWidth = PIXELS_PER_DAY;
    }
    return self;
}

+ (BOOL)timesIntersectS1:(NSTimeInterval)s1 e1:(NSTimeInterval)e1 s2:(NSTimeInterval)s2 e2:(NSTimeInterval)e2 {
	return (s1 > s2 && s1 < e2) || (e1 > s2 && e1 < e2) || (s1 < s2 && e1 > e2);
}

+ (NSInteger)calendarHourFromTime:(NSTimeInterval)time {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:date];
	NSInteger calHour = [components hour];
	return calHour;
}

+ (NSTimeInterval)floorTime:(NSTimeInterval)time toHour:(int)hour andMinutes:(int)minutes {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
	
	int modTime = ([components hour] % hour) * SECONDS_PER_HOUR + ([components minute] % minutes) * SECONDS_PER_MINUTE + [components second];
	int floorStep = hour * SECONDS_PER_HOUR + minutes * SECONDS_PER_MINUTE;
	if (modTime == floorStep) return time;
	return time - modTime;
}

+ (NSTimeInterval)floorTimeToStartOfDay:(NSTimeInterval)time {
	return [self floorTime:time toHour:HOURS_PER_DAY andMinutes:MINUTES_PER_HOUR];
}

+ (NSTimeInterval)roundTimeToGranularity:(NSTimeInterval)time {
    NSTimeInterval lower = [self floorTime:time toHour:1 andMinutes:(EVENT_TIME_GRANULARITY / SECONDS_PER_MINUTE)];
    NSTimeInterval upper = [self floorTime:(time + EVENT_TIME_GRANULARITY) toHour:1 andMinutes:(EVENT_TIME_GRANULARITY / SECONDS_PER_MINUTE)];
    if (time - lower < upper - time) return lower;
    else return upper;
}

- (NSTimeInterval)pixelToTimeOffset:(float)pixel {
	return pixel / _pixelsPerHour * SECONDS_PER_HOUR;
}

- (float)timeOffsetToPixel:(NSTimeInterval)time {
	return time / (float)SECONDS_PER_HOUR * _pixelsPerHour;
}

- (float)getPixelsPerHour {
	return _pixelsPerHour;
}

@end
