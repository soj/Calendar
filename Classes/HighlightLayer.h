#import "UIConstants.h"
#import "CalendarEventLayer.h"

typedef enum {
    kHighlightTop,
    kHighlightBottom,
    kHighlightAll,
    kHighlightDelete
} HighlightArea;

@interface HighlightBoxLayer : CalendarEventLayer

@property (nonatomic) HighlightArea highlightArea;

@end
