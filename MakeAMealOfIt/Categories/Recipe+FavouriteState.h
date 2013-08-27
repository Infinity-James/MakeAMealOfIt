//
//  Recipe+FavouriteState.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Recipe.h"

@interface Recipe (FavouriteState) {}

/**
 *	Adds this recipe to favourites.
 */
- (void)favourite;
/**
 *	A convenient way to know whether the recipe has been favourited or not.
 *
 *	@return	YES if this recipe has been favourited, NO otherwise.
 */
- (BOOL)isFavourited;
/**
 *	Removes this recipe from the user's favourites.
 */
- (void)unfavourite;

@end