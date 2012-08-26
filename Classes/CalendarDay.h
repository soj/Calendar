#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CalendarEntity.h"
#import "LayerDelegate.h"

@interface CalendarDay : CalendarEntity {
    CALayer *_backgroundLayer;
    CALayer *_fullTimeLinesLayer;
    CALayer *_timeLinesLayer;    
	NSTimeInterval _currentTime;
}

@property (nonatomic) NSTimeInterval currentTime;

- (void)fadeOutTimeLines;
- (void)fadeInTimeLines;

@end
