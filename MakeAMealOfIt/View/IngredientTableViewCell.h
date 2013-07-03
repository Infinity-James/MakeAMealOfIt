//
//  IngredientTableViewCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 02/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@protocol IngredientTableViewCellDelegate <NSObject>

@required

/**
 *	Sent to the delegate when a cell has been told to exclude it's ingredient.
 *
 *	@param	ingredientDictionary				The ingredient dictionary presented by the cell which has been excluded.
 */
- (void)ingredientItemExcluded:(NSDictionary *)ingredientDictionary;
/**
 *	Sent to the delegate when a cell has been told to include it's ingredient.
 *
 *	@param	ingredientDictionary				The ingredient dictionary presented by the cell which has been oncluded.
 */
- (void)ingredientItemIncluded:(NSDictionary *)ingredientDictionary;

@end

#pragma mark - Ingredient Table View Cell Public Interface

@interface IngredientTableViewCell : UITableViewCell {}

/**	The ingredient dictionary that this table view renders.	*/
@property (nonatomic, strong)	NSDictionary	*ingredientDictionary;

@end