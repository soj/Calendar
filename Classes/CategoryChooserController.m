#import <QuartzCore/QuartzCore.h>

#import "CategoryChooserController.h"
#import "Category.h"

@implementation CategoryChooserController

@synthesize categoryTableView=_categoryTableView;

- (id)initWithDelegate:(id<CategoryChooserDelegate>)delegate {
	self = [super initWithNibName:@"CategoryChooserController" bundle:nil];
	
	if (self != nil) {
		_delegate = delegate;
        [self sortCategories];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uiKeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uiKeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
        self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	return self;
}

- (void)viewDidLoad {
    _categoryTableView.delegate = self;
    [_categoryTableView flashScrollIndicators];
}

- (void)sortCategories {
    _categories = [Category allCategories];
    
    _categories = [_categories sortedArrayUsingComparator:^(Category *c1, Category *c2) {
        return (NSComparisonResult)[c1.name compare:c2.name];
    }];
}

#pragma mark -
#pragma mark Animations

- (void)animateIn {
    CGPoint endPos = CGPointMake(self.view.layer.position.x,
                                 self.view.layer.position.y - self.view.layer.bounds.size.height);
    
    [UIView animateWithDuration:UI_CHOOSER_ANIM_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.layer.position = endPos;
                     }
                     completion:NULL
     ];
}

- (void)animateOut {    
    CGPoint endPos = CGPointMake(self.view.layer.position.x,
                                 self.view.layer.position.y + self.view.layer.bounds.size.height);
    
    [UIView animateWithDuration:UI_CHOOSER_ANIM_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.layer.position = endPos;
                     }
                     completion:NULL
     ];
}

- (void)uiKeyboardWillShow:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGRect newFrame = CGRectMake(self.view.frame.origin.x,
                                 self.view.frame.origin.y - keyboardFrame.size.height,
                                 self.view.frame.size.width, self.view.frame.size.height);
    
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [UIView setAnimationCurve:animationCurve];
    NSTimeInterval animDur;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animDur];
    
    [UIView animateWithDuration:animDur
                    animations:^{
                        self.view.frame = newFrame;
                    }
    ];
    
    _keyboardOffset = YES;
}

- (void)uiKeyboardWillHide:(NSNotification*)notification {
    if (!_keyboardOffset) return;
    
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGRect frame = self.view.frame;
    CGRect newFrame = CGRectMake(frame.origin.x,
                                 frame.origin.y + keyboardFrame.size.height,
                                 frame.size.width, frame.size.height);
    
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [UIView setAnimationCurve:animationCurve];
    NSTimeInterval animDur;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animDur];
    
    [self.view.layer removeAllAnimations];
    [UIView animateWithDuration:animDur
                     animations:^{
                         self.view.frame = newFrame;
                     }
     ];
    
    _keyboardOffset = NO;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_categories count] + 1;  // +1 for new button
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *CellIdentifier = @"CustomCell";
	
	CategoryChooserCell *cell = (CategoryChooserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryChooserCell" owner:self options:nil];
		cell = [topLevelObjects objectAtIndex:0];
	}
    
    if (indexPath.row >= _categories.count) {
        [cell setName:@"New Category..."];
    } else {
        Category *cat = (Category*)[_categories objectAtIndex:indexPath.row];
        [cell setName:[cat name]];
        [cell setColor:[cat color]];
    }
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= _categories.count) {
        CategoryChooserCell *cell = (CategoryChooserCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.categoryName setHidden:YES];
        [cell.nameEntry setHidden:NO];
        [cell.nameEntry becomeFirstResponder];
        [cell.nameEntry setDelegate:self];
        [cell setColor:[UIColor redColor]];
        _activeCell = cell;
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [_delegate categoryChooser:self didSelectCategory:[_categories objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder]; // Do this first to animate correctly
    
    Category *newCat = [[Category alloc] initAndRegisterWithName:textField.text andColor:[_activeCell color]];
    [self sortCategories];
    
    [_categoryTableView reloadData];
    return YES;
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
