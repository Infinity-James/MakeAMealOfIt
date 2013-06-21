//
//  RecipeDetailsViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RightControllerDelegate.h"
#import "UICentreViewController.h"

#pragma mark - Recipe Details VC Public Interface

@interface RecipeDetailsViewController : UICentreViewController <RightControllerDelegate> {}

#pragma mark - Public Properties

/**
 *	Called to initialise an instance of this class with an ID of a recipe to present as well as it's name.
 *
 *	@param	recipeID					The ID of the recipe this view controller will show through it's views.
 *	@param	recipeName					The name of the recipe this view controller wil show.
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
				   andRecipeName:(NSString *)recipeName;

@end