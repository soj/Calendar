#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CategoryChooserCell.h"
#import "Category.h"

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
}

@property (nonatomic, strong) IBOutlet UITableView *categoryTableView;

- (id)initWithDelegate:(id<CategoryChooserDelegate>)delegate;

@end
