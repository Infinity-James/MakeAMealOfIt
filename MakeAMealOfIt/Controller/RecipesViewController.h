//
//  RecipesViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RightControllerDelegate.h"
#import "UICentreViewController.h"

#pragma mark - Recipes View Controller Public Interface

@interface RecipesViewController : UICentreViewController <RightControllerDelegate> {}

#pragma mark - Public Properties

/**	An array of recipes for this view controller to display	*/
@property (nonatomic, strong)	NSArray					*recipes;
/**	The search phrase pertaining to the array of recipes to display	*/
@property (nonatomic, strong)	NSString				*searchPhrase;

@end