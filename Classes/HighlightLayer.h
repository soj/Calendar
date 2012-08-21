#import "CalendarEventLayer.h"

#define UI_HIGHLIGHT_LINE_SIZE  20.0
#define UI_HIGHLIGHT_HEIGHT     25.0
#define UI_HIGHLIGHT_WIDTH      UI_BOX_BORDER_WIDTH
#define UI_HIGHLIGHT_PADDING    UI_BOX_BORDER_PADDING_Y

#define UI_BOX_BG_WHITENESS     0.9

typedef enum {
    kHighlightTop,
    kHighlightBottom,
    kHighlightAll,
    kHighlightDelete
} HighlightArea;

@interface HighlightLayer : CalendarEventLayer

@property (nonatomic) HighlightArea highlightArea;

@end
