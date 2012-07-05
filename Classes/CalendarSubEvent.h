#import "CalendarEvent.h"

#define MULTITASK_DX    10.0

@interface CalendarSubEvent : CalendarEvent {
    int _multitaskIndex;
}

- (void)setMultitaskIndex:(int)index;

@end
