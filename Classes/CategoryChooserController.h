#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CategoryChooserCell.h"
#import "Category.h"

#define UI_CHOOSER_ANIM_DURATION    0.3

@class CategoryChooserController;

@protocol CategoryChooserDelegate
- (void)categoryChooser:(CategoryChooserController*)chooser didSelectCategory:(Category*)cat;
@end

@interface CategoryChooserController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	id<CategoryChooserDelegate> _delegate;
    NSArray *_categories;
	
	UITableView *_categoryTableView;
    CategoryChooserCell *_activeCell;
    
    BOOL _keyboardOffset;
    BOOL _animatingOut;
}

@property (nonatomic, strong) IBOutlet UITableView *categoryTableView;

- (id)initWithDelegate:(id<CategoryChooserDelegate>)delegate;
- (void)animateIn;
- (void)animateOut;

@end
