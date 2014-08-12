#import "HighlightLayer.h"
#import "UIColor+Tools.h"

@implementation HighlightBoxLayer

@synthesize highlightArea;

- (id)initWithParent:(CALayer *)parent {
    if (self = [super initWithParent:parent]) {
        self.name = @"Highlight";
        [self setNeedsDisplayOnBoundsChange:YES];
    }
    return self;
}

- (CGRect)defaultFrame {
    CGRect def = [super defaultFrame];
    return CGRectInset(def, UI_BOX_BORDER_WIDTH, UI_BOX_BORDER_WIDTH);
}

- (CGRect)squashFrameWithProgress:(float)prog active:(BOOL)active {
    CGRect def = [super squashFrameWithProgress:prog active:active];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width - prog, def.size.height);
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, self.baseColor.CGColor);
    
    float highlightHeight = UI_HIGHLIGHT_PADDING + UI_HIGHLIGHT_HEIGHT;
    
    CGRect highlight;
    CGColorRef fill = [UIColor colorForFadeBetweenFirstColor:self.baseColor
                                                 secondColor:UI_EVENT_BG_COLOR
                                                     atRatio:UI_BOX_BG_WHITENESS].CGColor;
    switch (self.highlightArea) {
        case kHighlightTop: {
            highlight = CGRectMake(0, 0,
                                   self.frame.size.width,
                                   highlightHeight);
            break;
        }
        case kHighlightBottom: {
            highlight = CGRectMake(0,
                                   self.frame.size.height - highlightHeight,
                                   self.frame.size.width,
                                   highlightHeight);
            break;
        }
        case kHighlightAll: {
            highlight = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            break;
        }
        case kHighlightDelete: {
            highlight = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            break;
        }
        default:{
            highlight = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            break;
        }
    }
    
    CGContextSetFillColorWithColor(context, fill);
    CGContextFillRect(context, highlight);
}

@end
