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
	Calendar *_calendar;
	id<CategoryChooserDelegate> _delegate;
	
	UITableView *_categoryTableView;
}

@property (nonatomic, strong) IBOutlet UITableView *categoryTableView;

- (id)initWithCalendar:(Calendar*)cal andDelegate:(id<CategoryChooserDelegate>)delegate;

@end
