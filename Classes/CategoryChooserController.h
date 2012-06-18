#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CategoryChooserCell.h"
#import "Category.h"

@class CategoryChooserController;

@protocol CategoryChooserDelegate
- (void)categoryChooser:(CategoryChooserController*)chooser didSelectCategory:(Category*)cat;
@end

@interface CategoryChooserController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	Calendar *_calendar;
	id<CategoryChooserDelegate> _delegate;
	
	UITableView *_categories;
}

@property (nonatomic, retain) IBOutlet UITableView *categories;

- (id)initWithCalendar:(Calendar*)cal andDelegate:(id<CategoryChooserDelegate>)delegate;

@end
