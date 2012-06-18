//
//  CategoryChooserCell.h
//  calendar
//
//  Created by Fravic Fernando on 12-06-17.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CategoryChooserCell : UITableViewCell {
	UILabel *_categoryName;
	UIView *_colorView;
}

@property (nonatomic, retain) IBOutlet UILabel *categoryName;
@property (nonatomic, retain) IBOutlet UIView *colorView;

@end
