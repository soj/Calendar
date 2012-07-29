#import <UIKit/UIKit.h>

#define BORDER_COLOR    [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.0]

@interface CategoryChooserCell : UITableViewCell <UITextFieldDelegate> {
	UILabel *_categoryName;
	UIView *_colorView;
	UITextField *_nameEntry;
	UIColor *_color;
    UIView *_border;
}

@property (nonatomic, strong) IBOutlet UILabel *categoryName;
@property (nonatomic, strong) IBOutlet UIView *colorView;
@property (nonatomic, strong) IBOutlet UITextField *nameEntry;
@property (nonatomic, strong) IBOutlet UIView *border;

- (void)setColor:(UIColor*)color;
- (void)setName:(NSString*)name;
- (UIColor*)color;

@end
