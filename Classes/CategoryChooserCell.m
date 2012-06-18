#import <QuartzCore/QuartzCore.h>
#import "CategoryChooserCell.h"


@implementation CategoryChooserCell

@synthesize categoryName=_categoryName, colorView=_colorView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		_colorView.layer.borderColor = [UIColor blackColor].CGColor;
		_colorView.layer.borderWidth = 2.0f;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
