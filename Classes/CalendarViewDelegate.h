#import <UIKit/UIKit.h>

@protocol CalendarViewDelegate
- (float)timeToPixel:(NSTimeInterval)time;
- (NSTimeInterval)pixelToTime:(float)pixel;
- (float)getPixelsPerHour;
- (NSTimeInterval)getVisibleTimeInterval;
- (NSInteger)calendarHourFromReferenceHour:(int)refHour;
@end
