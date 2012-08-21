#import "HighlightLayer.h"
#import "UIColor+Tools.h"

@implementation HighlightLayer

@synthesize highlightArea;

- (id)initWithParent:(CALayer *)parent {
    if (self == [super initWithParent:parent]) {
        self.name = @"Highlight";
        [self setNeedsDisplayOnBoundsChange:YES];
    }
    return self;
}

- (CGRect)defaultFrame {
    CGRect def = [super defaultFrame];
    return CGRectInset(def, UI_BOX_BORDER_WIDTH, UI_BOX_BORDER_WIDTH);
}

- (CGRect)activeFrame {
    CGRect def = [self defaultFrame];
    return CGRectMake(def.origin.x - UI_DEPTH_BORDER_WIDTH,
                      def.origin.y - UI_DEPTH_BORDER_HEIGHT,
                      def.size.width, def.size.height);
}

- (CGRect)squashFrameWithProgress:(float)prog {
    CGRect def = [self activeFrame];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width - prog, def.size.height);
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, self.baseColor.CGColor);
    CGContextSetLineWidth(context, UI_HIGHLIGHT_WIDTH);
    
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
        }
    }
    
    CGContextSetFillColorWithColor(context, fill);
    CGContextFillRect(context, highlight);
}

@end
