#import <Foundation/Foundation.h>

#define EVENT_TIME_GRANULARITY	15 * SECONDS_PER_MINUTE

#define UI_PIXELS_PER_HOUR			100.0
#define UI_DAY_WIDTH                320.0

@interface CalendarMath : NSObject {
    float _pixelsPerHour;
    int _dayWidth;
}

@property (nonatomic) float pixelsPerHour;
@property (nonatomic) int dayWidth;

+ (CalendarMath*)getInstance;

+ (BOOL)timesIntersectS1:(NSTimeInterval)s1 e1:(NSTimeInterval)e1 s2:(NSTimeInterval)s2 e2:(NSTimeInterval)e2;

+ (NSInteger)calendarHourFromTime:(NSTimeInterval)time;
+ (NSTimeInterval)floorTime:(NSTimeInterval)time toHour:(int)hour andMinutes:(int)minutes;
+ (NSTimeInterval)floorTimeToStartOfDay:(NSTimeInterval)time;
+ (NSTimeInterval)roundTimeToGranularity:(NSTimeInterval)time;

- (float)timeOffsetToPixel:(NSTimeInterval)time;
- (NSTimeInterval)pixelToTimeOffset:(float)pixel;

@end
