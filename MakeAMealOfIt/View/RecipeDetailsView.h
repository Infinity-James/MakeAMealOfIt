//
//  RecipeDetailsView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Recipe+FavouriteState.h"

#pragma mark - Recipe Detail View Delegate Protocol

@protocol RecipeDetailsViewDelegate <NSObject>

#pragma mark - Required Methods

@required

/**
 *	Opens the recipe's source website with instructions and other stuff.
 */
- (void)openRecipeWebsite;

#pragma mark - Optional Methods

@optional

/**
 *	Sent to the delegate when the sender has updated it's intrinsicContentSize.
 */
- (void)updatedIntrinsicContentSize;

@end

#pragma mark - Recipe Details View Public Interface

@interface RecipeDetailsView : UIView  {}

#pragma mark - Public Properties

/**	The object interested in updates to this view.	*/
@property (nonatomic, weak)	id <RecipeDetailsViewDelegate>	delegate;
/**	An object encapsulating the recipe that this view is showing. */
@property (nonatomic, readonly, strong)	Recipe	*recipe;
/**	Whether the view is in a position where, if required, it can indicate any loading.	*/
@property (nonatomic, assign)			BOOL	canShowLoading;

#pragma mark - Public Methods

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	recipe						The recipe object being represented by this view.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipe:(Recipe *)recipe;
/**
 *	Called when the recipe loaded it's details.
 */
- (void)recipeDictionaryHasLoaded;

@end