//
//  RecipeDetailsIngredientCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 17/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Recipe Details Ingredient Cell Public Interface

@interface RecipeDetailsIngredientCell : UITableViewCell

#pragma mark - Public Properties

/**	An ingredient and it's quantity for a recipe.	*/
@property (nonatomic, strong)	NSString	*ingredientLine;

#pragma mark - Public Methods

+ (CGFloat)heightOfCellWithIngredientLine:(NSString *)ingredientLine
					   withSuperviewWidth:(CGFloat)superviewWidth;

@end