//
//  YummlyAPI.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlySearchResult.h"

#pragma mark - Type Definitions

typedef void(^YummlyRequestCompletionBlock)(BOOL success, NSDictionary *results);

#pragma mark - Yummly API Public Interface

@interface YummlyAPI : NSObject {}

#pragma mark - Public Methods

/**
 *	Asynchronously makes a request to Yummly for metadata.
 *
 *	@param	metadataKey					The type of metadata to request.
 *	@param	getMetadataCallCompleted	A block called when the request has completed. Results will be found under the kYummlyRequestResultsMetadataKey.
 */
+ (void)asynchronousGetMetadataForKey:(NSString *)metadataKey
				withCompletionHandler:(YummlyRequestCompletionBlock)getMetadataCallCompleted;
/**
 *	Asynchronously makes a request to Yummly for details on a specific recipe.
 *
 *	@param	recipeID					The ID for the recipe to get the details of.
 *	@param	getRecipeCallCompleted		A block called when the recipe is retrieved (either successfully or not).
 */
+ (void)asynchronousGetRecipeCallForRecipeID:(NSString *)recipeID
					   withCompletionHandler:(YummlyRequestCompletionBlock)getRecipeCallCompleted;
/**
 *	Asynchronously searches for recipes with the given search parameters.
 *
 *	@param	searchParameters			The defined terms for the recipes search.
 *	@param	searchRecipesCallCompleted	A block which is called when the search for recipes has completed (successfully or not).
 */
+ (void)asynchronousSearchRecipesCallWithParameters:(NSString *)searchParameters
							   andCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted;
/**
 *	Returns the valid metadata keys.
 *
 *	@return	An array of metadata keys that exist on the Yummly database.
 */
+ (NSArray *)metadataKeys;
/**
 *	Synchronously makes a request to Yummly for metadata.
 *
 *	@param	metadataKey					The type of metadata to request.
 *
 *	@return	An array of the the dictionaries of the type of metadata requested.
 */
+ (NSArray *)synchronousGetMetadataForKey:(NSString *)metadataKey;

@end