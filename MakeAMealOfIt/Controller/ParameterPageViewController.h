//
//  ParameterPageViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIRightViewController.h"

#pragma mark - Parameters Page View Controller Public Interface

@interface ParameterPageViewController : UIRightViewController {}

#pragma mark - Public Properties

/**	The index of this page within the containing page view controller.	*/
@property (nonatomic, assign)	NSUInteger	index;
/**	An array of options for this page to show.	*/
@property (nonatomic, strong)	NSArray		*options;
/**	The title of this page.	*/
@property (nonatomic, strong)	NSString	*optionCategoryTitle;

@end