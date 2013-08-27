//
//  Recipe+FavouriteState.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "FavouriteRecipesStore.h"
#import "Recipe+FavouriteState.h"

@implementation Recipe (FavouriteState)

#pragma mark - Favourite Management

/**
 *	Adds this recipe to favourites asynchronously.
 */
- (void)favourite
{
	dispatch_async(dispatch_queue_create("Favourite Recipe", NULL),
	^{
		[FavouriteRecipesStore addRecipe:self];
	});
}

/**
 *	Removes this recipe from the user's favourites asynchronously.
 */
- (void)unfavourite
{
	dispatch_async(dispatch_queue_create("Unfavourite Recipe", NULL),
	^{
		[FavouriteRecipesStore removeRecipe:self];
	});
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	A convenient way to know whether the recipe has been favourited or not.
 *
 *	@return	YES if this recipe has been favourited, NO otherwise.
 */
- (BOOL)isFavourited
{
	return [FavouriteRecipesStore isRecipeIDFavourited:self.recipeID];
}

@end