#import "CategoryChooserController.h"
#import "Category.h"

@implementation CategoryChooserController

@synthesize categoryTableView=_categoryTableView;

- (id)initWithCalendar:(Calendar*)cal andDelegate:(id<CategoryChooserDelegate>)delegate {
	self = [super initWithNibName:@"CategoryChooserController" bundle:nil];
	
	if (self != nil) {
		_calendar = cal;
		_delegate = delegate;
	}
    
	return self;
}

- (void)viewDidLoad {
    _categoryTableView.delegate = self;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_calendar categories] count] + 1;  // +1 for new button
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *CellIdentifier = @"CustomCell";
	
	CategoryChooserCell *cell = (CategoryChooserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryChooserCell" owner:self options:nil];
		cell = [topLevelObjects objectAtIndex:0];
	}
    
    if (indexPath.row >= [_calendar categories].count) {
        [cell setName:@"New Category..."];
    } else {
        Category *cat = (Category*)[[_calendar categories] objectAtIndex:indexPath.row];
        [cell setName:[cat name]];
        [cell setColor:[cat color]];
    }
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
	
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_calendar categories].count) {
        Category *newCat = [[Category alloc] initWithName:@"New Category" andColor:[UIColor redColor]];
        [_delegate categoryChooser:self didCreateNewCategory:newCat];
    } else {
        [_delegate categoryChooser:self didSelectCategory:[[_calendar categories] objectAtIndex:indexPath.row]];
    }
    [self.view removeFromSuperview];
}

#pragma mark -
#pragma mark ViewController Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
