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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uiKeyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uiKeyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification object:nil];
        
        self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	return self;
}

- (void)viewDidLoad {
    _categoryTableView.delegate = self;
    [_categoryTableView flashScrollIndicators];
}

- (void)animateIn {
    CGPoint endPos = CGPointMake(self.view.layer.position.x, self.view.layer.position.y - self.view.layer.bounds.size.height);
    
    CABasicAnimation *shiftUp = [CABasicAnimation animationWithKeyPath:@"position"];
    shiftUp.fromValue = [NSValue valueWithCGPoint:self.view.layer.position];
    shiftUp.toValue = [NSValue valueWithCGPoint:endPos];
    shiftUp.duration = UI_CHOOSER_ANIM_DURATION;
    shiftUp.removedOnCompletion = NO;
    shiftUp.fillMode = kCAFillModeForwards;
    self.view.layer.position = endPos;
    [self.view.layer addAnimation:shiftUp forKey:@"positionUp"];
}

- (void)animateOut {
    CGPoint endPos = CGPointMake(self.view.layer.position.x, self.view.layer.position.y + self.view.layer.bounds.size.height);
    
    CABasicAnimation *shiftDown = [CABasicAnimation animationWithKeyPath:@"position"];
    shiftDown.fromValue = [NSValue valueWithCGPoint:self.view.layer.position];
    shiftDown.toValue = [NSValue valueWithCGPoint:endPos];
    shiftDown.duration = UI_CHOOSER_ANIM_DURATION;
    shiftDown.removedOnCompletion = NO;
    shiftDown.fillMode = kCAFillModeForwards;
    shiftDown.delegate = self;
    [self.view.layer addAnimation:shiftDown forKey:@"positionDown"];
}

- (void)sortCategories {
    _categories = [Category allCategories];
    
    _categories = [_categories sortedArrayUsingComparator:^(Category *c1, Category *c2) {
        return (NSComparisonResult)[c1.name compare:c2.name];
    }];
}

- (void)uiKeyboardDidShow:(NSNotification*)notification {
    // Note: When you animate this, use UIKeyboardAnimationDurationUserInfoKey, UIKeyboardAnimationCurveUserInfoKey and UIKeyboardFrameBeginUserInfoKey
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameEnd CGRectValue];
    
    CGRect frame = self.view.frame;
    CGRect newFrame = CGRectMake(frame.origin.x, 
                                 frame.origin.y - keyboardFrame.size.height,
                                 frame.size.width, frame.size.height);
    [self.view setFrame:newFrame];
    
    _keyboardOffset = YES;
}

- (void)uiKeyboardDidHide:(NSNotification*)notification {
    if (!_keyboardOffset) return;
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    
    CGRect frame = self.view.frame;
    CGRect newFrame = CGRectMake(frame.origin.x, 
                                 frame.origin.y + keyboardFrame.size.height,
                                 frame.size.width, frame.size.height);
    [self.view setFrame:newFrame];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.view removeFromSuperview];
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
    Category *newCat = [[Category alloc] initAndRegisterWithName:textField.text andColor:[_activeCell color]];
    [_delegate categoryChooser:self didSelectCategory:newCat];
    [self sortCategories];
    
    [_categoryTableView reloadData];
    [textField resignFirstResponder];
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
