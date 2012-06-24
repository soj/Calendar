#import "Calendar.h"

@protocol CalendarDayDelegate
- (NSInteger)calendarHourFromTime:(NSTimeInterval)time;
- (NSTimeInterval)floorTimeToStartOfDay:(NSTimeInterval)time;
- (NSTimeInterval)floorTimeToMinInterval:(NSTimeInterval)time;

- (float)timeOffsetToPixel:(NSTimeInterval)time;
- (NSTimeInterval)pixelToTimeOffset:(float)pixel;

- (float)getPixelsPerHour;
- (int)dayWidth;

- (Calendar*)getCalendar;
- (UIView*)calendarView;
@end
