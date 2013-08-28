//
//  FavouriteRecipesStore.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 23/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Recipe.h"

#pragma mark - Constants & Static Variables

/**	The notification triggered when a favourite recipe has been added.	*/
extern NSString *const FavouriteRecipesStoreNotificationFavouriteRecipeAdded;
/**	The notification triggered when a favourite recipe has been removed.	*/
extern NSString *const FavouriteRecipesStoreNotificationFavouriteRecipeRemoved;

#pragma mark - Favourite Recipes Store Public Interface

@interface FavouriteRecipesStore : NSObject {}

#pragma mark - Public Methods

/**
 *	Adds a recipe to the list of favourite recipes.
 *
 *	@param	recipe						The recipe that has been favourited.
 */
+ (void)addRecipe:(Recipe *)recipe;
/**
 *	Used to gets the list of favourited recipes.
 *
 *	@return	Returns an NSArray with all of the favourited recipes, or nil if none exist.
 */
+ (NSArray *)favouriteRecipes;
/**
 *	Checks if the recipe with the given ID has been favourited.
 *
 *	@param	recipeID					The ID to check.
 *
 *	@return	YES if the recipe with the given ID has been favourited, NO otherwise.
 */
+ (BOOL)isRecipeIDFavourited:(NSString *)recipeID;
/**
 *	Removes a recipe from the list of favourites.
 *
 *	@param	recipe						The recipe to remove.
 */
+ (void)removeRecipe:(Recipe *)recipe;

@end