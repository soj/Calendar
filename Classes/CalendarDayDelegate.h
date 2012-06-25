#import "Calendar.h"
#import "CategoryChooserController.h"

@protocol CalendarDayDelegate
- (NSInteger)calendarHourFromTime:(NSTimeInterval)time;
- (NSTimeInterval)floorTimeToStartOfDay:(NSTimeInterval)time;
- (NSTimeInterval)floorTimeToMinInterval:(NSTimeInterval)time;

- (float)timeOffsetToPixel:(NSTimeInterval)time;
- (NSTimeInterval)pixelToTimeOffset:(float)pixel;

- (float)getPixelsPerHour;
- (int)dayWidth;

- (void)showCategoryChooserWithDelegate:(id<CategoryChooserDelegate>)delegate;
@end
