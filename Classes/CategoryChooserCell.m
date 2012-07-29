#import <QuartzCore/QuartzCore.h>
#import "CategoryChooserCell.h"


@implementation CategoryChooserCell

@synthesize categoryName=_categoryName, colorView=_colorView, nameEntry=_nameEntry, border=_border;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		_colorView.layer.borderColor = [UIColor blackColor].CGColor;
		_colorView.layer.borderWidth = 2.0f;
    }
    return self;
}

- (void)setColor:(UIColor*)color {
	_colorView.backgroundColor = color;
	_color = color;
}

- (UIColor*)color {
    return _color;
}

- (void)setName:(NSString*)name {
	_categoryName.text = name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _colorView.backgroundColor = _color;
    _border.backgroundColor = BORDER_COLOR;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _colorView.backgroundColor = _color;
    _border.backgroundColor = BORDER_COLOR;
}

@end
