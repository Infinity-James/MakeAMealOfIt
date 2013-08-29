//
//  FavouriteRecipesStore.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 23/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "FavouriteRecipesStore.h"

#pragma mark - Constants & Static Variables

/**	The name of the favourite recipes file.	*/
static NSString *const kFavouriteRecipesFile		= @"favourite-recipes";
/**	The notification triggered when a favourite recipe has been added.	*/
NSString *const FavouriteRecipesStoreNotificationFavouriteRecipeAdded	= @"NotificationFavouriteAdded";
/**	The notification triggered when a favourite recipe has been removed.	*/
NSString *const FavouriteRecipesStoreNotificationFavouriteRecipeRemoved	= @"NotificationFavouriteRemoved";

#pragma mark - Favourite Recipes Store Private Class Extension

@interface FavouriteRecipesStore () {}

#pragma mark - Private Properties

@end

#pragma mark - Favourite Recipes Store Implementation

@implementation FavouriteRecipesStore {}

#pragma mark - Favourited Recipes Management

/**
 *	Adds a recipe to the list of favourite recipes.
 *
 *	@param	recipe						The recipe that has been favourited.
 */
+ (void)addRecipe:(Recipe *)recipe
{
	[[NSNotificationCenter defaultCenter] postNotificationName:FavouriteRecipesStoreNotificationFavouriteRecipeAdded object:recipe];
	
	NSMutableDictionary *favouriteRecipes	= [[NSMutableDictionary alloc] initWithDictionary:self.favouriteRecipesDictionary];
	
	NSString *recipeID					= recipe.recipeID;
	
	NSData *recipeData					= [NSKeyedArchiver archivedDataWithRootObject:recipe];
	favouriteRecipes[recipeID]			= recipeData;
	[self addRecipeID:recipeID];
	
	[favouriteRecipes writeToFile:self.favouriteRecipesPath atomically:YES];
}

/**
 *	Adds a recipe ID to the list of favourite recipes.
 *
 *	@param	recipe						The recipe that has been favourited.
 */
+ (void)addRecipeID:(NSString *)recipeID
{
	NSUserDefaults *userDefaults		= [NSUserDefaults standardUserDefaults];
	NSMutableSet *favouriteRecipeIDs	= [[NSMutableSet alloc] initWithArray:[userDefaults objectForKey:kFavouriteRecipesFile]];
	[favouriteRecipeIDs addObject:recipeID];
	[userDefaults setObject:[favouriteRecipeIDs allObjects] forKey:kFavouriteRecipesFile];
	[userDefaults synchronize];
}

/**
 *	Checks if the recipe with the given ID has been favourited.
 *
 *	@param	recipeID					The ID to check.
 *
 *	@return	YES if the recipe with the given ID has been favourited, NO otherwise.
 */
+ (BOOL)isRecipeIDFavourited:(NSString *)recipeID
{
	NSUserDefaults *userDefaults		= [NSUserDefaults standardUserDefaults];
	NSArray *favouriteRecipeIDs			= [userDefaults objectForKey:kFavouriteRecipesFile];
	
	if (!favouriteRecipeIDs || favouriteRecipeIDs.count == 0)
		return NO;
	else
		return [favouriteRecipeIDs containsObject:recipeID];
}

/**
 *	Removes a recipe from the list of favourites.
 *
 *	@param	recipeID					The recipe ID to remove.
 */
+ (void)removeRecipe:(Recipe *)recipe
{
	[[NSNotificationCenter defaultCenter] postNotificationName:FavouriteRecipesStoreNotificationFavouriteRecipeRemoved object:recipe];
	
	NSMutableDictionary *favouriteRecipes	= [[NSMutableDictionary alloc] initWithDictionary:self.favouriteRecipesDictionary];
	
	NSString *recipeID					= recipe.recipeID;
	
	[favouriteRecipes removeObjectForKey:recipeID];
	[self removeRecipeID:recipeID];
	
	[favouriteRecipes writeToFile:self.favouriteRecipesPath atomically:YES];
}

/**
 *	Removes a recipe ID from the list of favourites.
 *
 *	@param	recipeID					The recipe ID to remove.
 */
+ (void)removeRecipeID:(NSString *)recipeID
{
	NSUserDefaults *userDefaults		= [NSUserDefaults standardUserDefaults];
	NSMutableSet *favouriteRecipeIDs	= [[NSMutableSet alloc] initWithArray:[userDefaults objectForKey:kFavouriteRecipesFile]];
	[favouriteRecipeIDs removeObject:recipeID];
	[userDefaults setObject:[favouriteRecipeIDs allObjects] forKey:kFavouriteRecipesFile];
	[userDefaults synchronize];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	Used to gets the list of favourited recipes.
 *
 *	@return	Returns an NSArray with all of the favourited recipes in alphabetical order, or nil if none exist.
 */
+ (NSArray *)favouriteRecipes
{
	NSDictionary *favouriteRecipesDictionary	= self.favouriteRecipesDictionary;
	NSMutableArray *favouriteRecipes			= [[NSMutableArray alloc] initWithCapacity:favouriteRecipesDictionary.count];
	
	for (NSData *recipeData in favouriteRecipesDictionary.allValues)
	{
		[favouriteRecipes addObject:[NSKeyedUnarchiver unarchiveObjectWithData:recipeData]];
	}
	
	return [favouriteRecipes sortedArrayUsingComparator:^NSComparisonResult(Recipe *recipeA, Recipe *recipeB)
	{
		return [recipeA.recipeName compare:recipeB.recipeName];
	}];
}

/**
 *	Used to gets the list of favourited recipes.
 *
 *	@return	Returns an NSDictionary with all of the favourited recipes with the ID's as keys, or nil if none exist.
 */
+ (NSDictionary *)favouriteRecipesDictionary
{
	if (![self.fileManager fileExistsAtPath:self.favouriteRecipesPath])
		return nil;
	
	return [[NSDictionary alloc] initWithContentsOfFile:self.favouriteRecipesPath];
}

/**
 *	Returns a recipe for a given recipe ID.
 *
 *	@param	recipeID					The ID for which to return the recipe.
 *
 *	@return	Returns a recipe for the given recipe ID.
 */
+ (Recipe *)getRecipeForRecipeID:(NSString *)recipeID
{
	NSDictionary *favouriteRecipes		= self.favouriteRecipesDictionary;
	
	NSData *recipeData					= favouriteRecipes[recipeID];
	
	if (!recipeData)					return nil;
	
	return [NSKeyedUnarchiver unarchiveObjectWithData:recipeData];
}

#pragma mark - Utility Methods - Document & File Management

/**
 *	The document directory to save app-specific documents into.
 *
 *	@return	The document directory available to this app.
 */
+ (NSString *)documentDirectory
{
	static NSString *documentDirectory;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		//	there is only one document directory so we get an array of them and use the only object in the array
		NSArray *directories			= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentDirectory				= directories[0];
	});
	
	return documentDirectory;
}

/**
 *	Returns a file manager object for handling documents.
 *
 *	@return	The file manager to be used when handling the saving and loading of metadata.
 */
+ (NSFileManager *)fileManager
{
	static NSFileManager *fileManager;
	static dispatch_once_t once;
	
	dispatch_once(&once,
	^{
		fileManager					= [[NSFileManager alloc] init];
	});
	
	return fileManager;
}

/**
 *	Returns a fully constrcuted path within the document directory to save metadata to.
 *
 *	@return	A string detailing the path to save metadata in.
 */
+ (NSString *)favouriteRecipesPath
{
	return [self.documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", kFavouriteRecipesFile]];
}

@end