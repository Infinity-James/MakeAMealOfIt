//
//  IngredientTableViewCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 02/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@class IngredientTableViewCell;

@protocol IngredientTableViewCellDelegate <NSObject>

#pragma mark - Required Methods

@required

/**
 *	Sent to the delegate when a cell has been told to exclude it's ingredient.
 *
 *	@param	ingredientTableViewCell		The ingredient cell that has been updated in some way (included or excluded, or an undo of either).
 */
- (void)ingredientCellUpdated:(IngredientTableViewCell *)ingredientTableViewCell;

@end

#pragma mark - Ingredient Table View Cell Public Interface

@interface IngredientTableViewCell : UITableViewCell {}

#pragma mark - Public Methods

/**
 *	A special setter for the excluded property of this cell.
 *
 *	@param	excluded					Whether or not the user wants to exclude this ingredient from the search.
 *	@param	updateDelegate				Whether or not to inform the delegate that this cell has been updated.
 */
- (void)setExcluded:(BOOL)excluded
			updated:(BOOL)updateDelegate
		   animated:(BOOL)animated;
/**
 *	A special setter for the included property of this cell.
 *
 *	@param	included					Whether or not the user wants to include this ingredient from the search.
 *	@param	updateDelegate				Whether or not to inform the delegate that this cell has been updated.
 */
- (void)setIncluded:(BOOL)included
			updated:(BOOL)updateDelegate
		   animated:(BOOL)animated;

#pragma mark - Public Properties

/**	The delegate for this ingredient table view cell.	*/
@property (nonatomic, weak)		id <IngredientTableViewCellDelegate>	delegate;
/**	Whether the ingredient dictionary rendered by us is marked excluded.	*/
@property (nonatomic, assign)	BOOL			excluded;
/**	Whether the ingredient dictionary rendered by us is marked included.	*/
@property (nonatomic, assign)	BOOL			included;
/**	The ingredient dictionary that this table view renders.	*/
@property (nonatomic, strong)	NSDictionary	*ingredientDictionary;

@end