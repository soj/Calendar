#import <UIKit/UIKit.h>

@protocol CalendarDayDelegate
- (float)timeOffsetToPixel:(NSTimeInterval)time;
- (NSTimeInterval)pixelToTimeOffset:(float)pixel;
- (float)getPixelsPerHour;
- (NSInteger)calendarHourFromTime:(NSTimeInterval)time;
- (NSTimeInterval)floorTimeToStartOfDay:(NSTimeInterval)time;
@end
