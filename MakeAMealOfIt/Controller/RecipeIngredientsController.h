//
//  RecipeIngredientsController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Constants & Static Variables

/**	An ID for cells used by this table view (for use in a reuse pool).	*/
extern NSString *const kCellIdentifier;

#pragma mark - Recipe Ingredients Controller Public Interface

@interface RecipeIngredientsController : NSObject <UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Public Properties

@property (nonatomic, strong)	NSArray		*ingredients;

#pragma mark - Public Methods

/**
 *	The preferred height for the table view that we manage.
 *
 *	@return	A calculated value for the height required to show each cell in one view.
 */
- (CGFloat)desiredTableViewHeight;
/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	ingredients					The ingredients that this controller is in charge of managing.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithIngredients:(NSArray *)ingredients;

@end