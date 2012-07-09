#import <UIKit/UIKit.h>


@interface CategoryChooserCell : UITableViewCell <UITextFieldDelegate> {
	UILabel *_categoryName;
	UIView *_colorView;
	UITextField *_nameEntry;
	UIColor *_color;
}

@property (nonatomic, strong) IBOutlet UILabel *categoryName;
@property (nonatomic, strong) IBOutlet UIView *colorView;
@property (nonatomic, strong) IBOutlet UITextField *nameEntry;

- (void)setColor:(UIColor*)color;
- (void)setName:(NSString*)name;
- (UIColor*)color;

@end
