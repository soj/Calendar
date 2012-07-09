#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CategoryChooserCell.h"
#import "Category.h"

@class CategoryChooserController;

@protocol CategoryChooserDelegate
- (void)categoryChooser:(CategoryChooserController*)chooser didSelectCategory:(Category*)cat;
- (void)categoryChooser:(CategoryChooserController *)chooser didCreateNewCategory:(Category *)cat;  
@end

@interface CategoryChooserController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	id<CategoryChooserDelegate> _delegate;
    NSArray *_categories;
	
	UITableView *_categoryTableView;
}

@property (nonatomic, strong) IBOutlet UITableView *categoryTableView;

- (id)initWithDelegate:(id<CategoryChooserDelegate>)delegate;

@end
