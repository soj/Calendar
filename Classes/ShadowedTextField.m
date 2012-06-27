#import "ShadowedTextField.h"


@implementation ShadowedTextField

- (id)init {
    self = [super init];
    
    if (self) {
		[self layer].shadowColor = [[UIColor blackColor] CGColor];
		[self layer].shadowOffset = CGSizeMake(0, -1);
		[self layer].shadowOpacity = 0.4;
		[self layer].shadowRadius = 0;
		[self setTextColor:[UIColor whiteColor]];
		[self setKeyboardAppearance:UIKeyboardAppearanceAlert];
		[self setReturnKeyType:UIReturnKeyDone];
		[self setAdjustsFontSizeToFitWidth:YES];
		[self setMinimumFontSize:16.0];
		[self setFont:[UIFont systemFontOfSize:25.0]];
		[self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    }
    
    return self;
}

@end
