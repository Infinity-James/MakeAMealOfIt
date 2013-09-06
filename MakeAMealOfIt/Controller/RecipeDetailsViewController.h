//
//  RecipeDetailsViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RightControllerDelegate.h"
#import "UICentreViewController.h"

@class Recipe;

#pragma mark - Recipe Details VC Public Interface

@interface RecipeDetailsViewController : UICentreViewController <RightControllerDelegate> {}

#pragma mark - Public Methods

/**
 *	Called to initialise an instance of this class with an ID of a recipe to present as well as it's name.
 *
 *	@param	recipeID					The ID of the recipe this view controller will show through it's views.
 *	@param	recipeName					The name of the recipe this view controller will show.
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
				   andRecipeName:(NSString *)recipeName;
/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipe:(Recipe *)recipe;

@end