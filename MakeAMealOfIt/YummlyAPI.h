//
//  YummlyAPI.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Constants & Static Variables: Yummly Request Custom Result Keys

extern NSString *const kYummlyRequestResultsMetadataKey;

#pragma mark - Constants & Static Variables: Yummly Metadata Result Keys

extern NSString *const kYummlyMetadataDescriptionKey;
extern NSString *const kYummlyMetadataIDKey;
extern NSString *const kYummlyMetadataLongDescriptionKey;
extern NSString *const kYummlyMetadataSearchValueKey;
extern NSString *const kYummlyMetadataShortDescriptionKey;
extern NSString *const kYummlyMetadataTermKey;
extern NSString *const kYummlyMetadataTypeKey;

#pragma mark - Constants & Static Variables: Yummly Metadata Request Keys

extern NSString *const kYummlyMetadataAllergies;
extern NSString *const kYummlyMetadataCourses;
extern NSString *const kYummlyMetadataCuisines;
extern NSString *const kYummlyMetadataDiets;
extern NSString *const kYummlyMetadataHolidays;
extern NSString *const kYummlyMetadataIngredients;

#pragma mark - Constants & Static Variables: Yummly Search Recipe Keys

extern NSString *const kYummlyAttributionDictionaryKey;
extern NSString *const kYummlyAttributionHTMLKey;
extern NSString *const kYummlyAttributionLogoKey;
extern NSString *const kYummlyAttributionTextKey;
extern NSString *const kYummlyAttributionURLKey;

extern NSString *const kYummlyCriteriaDictionaryKey;

extern NSString *const kYummlyFacetCountsDictionaryKey;

extern NSString *const kYummlyMatchesArrayKey;
extern NSString *const kYummlyMatchAttributesKey;
extern NSString *const kYummlyMatchFlavoursKey;
extern NSString *const kYummlyMatchIDKey;
extern NSString *const kYummlyMatchIngredientsArrayKey;
extern NSString *const kYummlyMatchRatingKey;
extern NSString *const kYummlyMatchRecipeNameKey;
extern NSString *const kYummlyMatchSmallImageURLsArrayKey;
extern NSString *const kYummlyMatchSourceDisplayNameKey;
extern NSString *const kYummlyMatchTimeToMakeKey;

extern NSString *const kYummlyTotalMatchCountKey;

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