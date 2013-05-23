//
//  YummlyAPI.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAPI.h"

#pragma mark - Constants & Static Variables: URL Request Strings

static NSString *const kYummlyAppID						= @"286bc6f3";
static NSString *const kYummlyAppIDHeaderField			= @"X-Yummly-App-ID";
static NSString *const kYummlyAppKey					= @"a175c2748234fcb57b0e4594ea95f3d7";
static NSString *const kYummlyAppKeyHeaderField			= @"X-Yummly-App-Key";
static NSString *const kYummlyAuthorisationURLExtension	= @"_app_id=286bc6f3&_app_key=a175c2748234fcb57b0e4594ea95f3d7";
static NSString *const kYummlyBaseAPIURL				= @"https://api.yummly.com/v1/api";

#pragma mark - Constants & Static Variables: Yummly Request Custom Result Keys

NSString *const kYummlyRequestResultsMetadataKey		= @"metadata";

#pragma mark - Constants & Static Variables: Yummly Metadata Result Keys

NSString *const kYummlyMetadataDescriptionKey			= @"description";
NSString *const kYummlyMetadataIDKey					= @"id";
NSString *const kYummlyMetadataLongDescriptionKey		= @"longDescription";
NSString *const kYummlyMetadataSearchValueKey			= @"searchValue";
NSString *const kYummlyMetadataShortDescriptionKey		= @"shortDescription";
NSString *const kYummlyMetadataTermKey					= @"term";
NSString *const kYummlyMetadataTypeKey					= @"type";

#pragma mark - Constants & Static Variables: Yummly Metadata Request Keys

NSString *const kYummlyMetadataAllergies				= @"allergy";
NSString *const kYummlyMetadataCourses					= @"course";
NSString *const kYummlyMetadataCuisines					= @"cuisine";
NSString *const kYummlyMetadataDiets					= @"diet";
NSString *const kYummlyMetadataHolidays					= @"holiday";
NSString *const kYummlyMetadataIngredients				= @"ingredient";

#pragma mark - Constants & Static Variables: Yummly Search Recipe Keys

NSString *const kYummlyAttributionDictionaryKey			= @"attribution";
NSString *const kYummlyAttributionHTMLKey				= @"html";
NSString *const kYummlyAttributionLogoKey				= @"logo";
NSString *const kYummlyAttributionTextKey				= @"text";
NSString *const kYummlyAttributionURLKey				= @"url";

NSString *const kYummlyCriteriaDictionaryKey			= @"criteria";

NSString *const kYummlyFacetCountsDictionaryKey			= @"facetCounts";

NSString *const kYummlyMatchesArrayKey					= @"matches";
NSString *const kYummlyMatchAttributesKey				= @"attributes";
NSString *const kYummlyMatchFlavoursKey					= @"flavors";
NSString *const kYummlyMatchIDKey						= @"id";
NSString *const kYummlyMatchIngredientsArrayKey			= @"ingredients";
NSString *const kYummlyMatchRatingKey					= @"rating";
NSString *const kYummlyMatchRecipeNameKey				= @"recipeName";
NSString *const kYummlyMatchSmallImageURLsArrayKey		= @"smallImageUrls";
NSString *const kYummlyMatchSourceDisplayNameKey		= @"sourceDisplayName";
NSString *const kYummlyMatchTimeToMakeKey				= @"totalTimeInSeconds";

NSString *const kYummlyTotalMatchCountKey				= @"totalMatchCount";

#pragma mark - Yummly API Implementation

@implementation YummlyAPI {}

#pragma mark - Make API Call Methods: Synchronous

/**
 *	asynchronously makes a request to yummly for metadata (returns results in dictionary with results metadata key)
 *
 *	@param	metadataKey					the type of metadata to get
 *	@param	getMetadataCallCompleted	a block which is called when the metadata is retrieved (either successfully or not)
 */
+ (void)asynchronousGetMetadataForKey:(NSString *)metadataKey
				withCompletionHandler:(YummlyRequestCompletionBlock)getMetadataCallCompleted
{
	dispatch_async(dispatch_queue_create("Metadata Fetcher", NULL),
	^{
		NSArray *results				= [self synchronousGetMetadataForKey:metadataKey];
		
		if (results)
			getMetadataCallCompleted(YES, @{kYummlyRequestResultsMetadataKey: results})	;
		else
			getMetadataCallCompleted(NO, nil);
	});
}

#pragma mark - Make API Call Methods: Asynchronous

/**
 *	asynchronously makes a request to yummly for details on a specific recipe
 *
 *	@param	recipeID					the id for the recipe we want the url ot be able to get
 *	@param	getRecipeCallCompleted		a block which is called when the recipe is retrieved (either successfully or not)
 */
+ (void)asynchronousGetRecipeCallForRecipeID:(NSString *)recipeID
					   withCompletionHandler:(YummlyRequestCompletionBlock)getRecipeCallCompleted
{
	NSString *getRecipeURL				= [NSString stringWithFormat:@"%@/recipe/%@", kYummlyBaseAPIURL, recipeID];
	NSURLRequest *yummlyURLRequest		= [self authenticatedYummlyURLRequestForURL:[[NSURL alloc] initWithString:getRecipeURL]];
	[self asynchronouslyExecuteYummlyURLRequest:yummlyURLRequest withCompletionHandler:getRecipeCallCompleted];
}

/**
 *	asynchronously searches for recipes with the given search parameters
 *
 *	@param	searchParameters			the defined terms for the resipes search
 *	@param	searchRecipesCallCompleted	a block which is called when the search for recipes has completed (successfully or not)
 */
+ (void)asynchronousSearchRecipesCallWithParameters:(NSString *)searchParameters
							   andCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted
{
	NSString *yummlySearchURL			= [[NSString alloc] initWithFormat:@"%@/recipes?%@", kYummlyBaseAPIURL, searchParameters];
	yummlySearchURL						= [yummlySearchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"Final URL: %@", yummlySearchURL);
	NSURLRequest *yummlyURLRequest		= [self authenticatedYummlyURLRequestForURL:[[NSURL alloc] initWithString:yummlySearchURL]];
	[self asynchronouslyExecuteYummlyURLRequest:yummlyURLRequest withCompletionHandler:searchRecipesCallCompleted];
	
}

/**
 *	synchronously makes a request to yummly for metadata
 *
 *	@param	metadataKey					the type of metadata to get
 */
+ (NSArray *)synchronousGetMetadataForKey:(NSString *)metadataKey
{
	if (![[self metadataKeys] containsObject:metadataKey])
		return nil;
	
	NSString *getMetadataURL			= [NSString stringWithFormat:@"%@/metadata/%@?%@", kYummlyBaseAPIURL, metadataKey, kYummlyAuthorisationURLExtension];
	NSString *jsonString				= [[NSString alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:getMetadataURL] encoding:NSUTF8StringEncoding error:nil];
	jsonString							= [jsonString stringByReplacingOccurrencesOfString:@"set_metadata(" withString:@""];
	jsonString							= [jsonString stringByReplacingOccurrencesOfString:@");" withString:@""];
	jsonString							= [jsonString stringByReplacingOccurrencesOfString:[[NSString alloc] initWithFormat:@"'%@', ", metadataKey] withString:@""];
	NSData *jsonData					= [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *results					= [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
	return results;
}

#pragma mark - Setter & Getter Methods

/**
 *	returns the valid metadata keys
 */
+ (NSArray *)metadataKeys
{
	return @[kYummlyMetadataAllergies, kYummlyMetadataCourses, kYummlyMetadataCuisines, kYummlyMetadataDiets, kYummlyMetadataHolidays, kYummlyMetadataIngredients];
}

#pragma mark - Utility Methods

/**
 *	takes a url request and executes it asynchronously
 *
 *	@param	yummlyURLRequest
 */
+ (void)asynchronouslyExecuteYummlyURLRequest:(NSURLRequest *)yummlyURLRequest
						withCompletionHandler:(YummlyRequestCompletionBlock)yummlyURLRequestCompleted
{
	NSOperationQueue *yummlyQueue		= [[NSOperationQueue alloc] init];
	
	
	[NSURLConnection sendAsynchronousRequest:yummlyURLRequest
									   queue:yummlyQueue
						   completionHandler:^(NSURLResponse *response, NSData *jsonData, NSError *error)
	{
		if (error)						NSLog(@"Yummly Request Failed: %@\n With Response: %@", error.localizedDescription, response);
		NSLog(@"Response: %@", response);
		
		NSDictionary *results			= jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
																			  options:NSJSONReadingMutableLeaves
																				error:&error] : nil;
		
		if (error)						NSLog(@"JSON Serialisation Failed: %@", error.localizedDescription);
		
		yummlyURLRequestCompleted(!error, results);
	}];
}

/**
 *	returns a url request object with authentication header for a given url
 *
 *	@param	url							the url that this request is for
 */
+ (NSURLRequest *)authenticatedYummlyURLRequestForURL:(NSURL *)url
{
	NSMutableURLRequest *yummlyURLRequest	= [[NSMutableURLRequest alloc] initWithURL:url];
	
	[yummlyURLRequest addValue:kYummlyAppID forHTTPHeaderField:kYummlyAppIDHeaderField];
	[yummlyURLRequest addValue:kYummlyAppKey forHTTPHeaderField:kYummlyAppKeyHeaderField];
	
	return (NSURLRequest *)yummlyURLRequest;
}

/**
 *	takes a url request and executes it asynchronously
 *
 *	@param	yummlyURLRequest
 */
+ (NSDictionary *)synchronouslyExecuteYummlyURLRequest:(NSURLRequest *)yummlyURLRequest
{	
	NSURLResponse *response;
	NSError *error;
	
	NSData *jsonData					= [NSURLConnection sendSynchronousRequest:yummlyURLRequest returningResponse:&response error:&error];
	
	if (error)							NSLog(@"Yummly Request Failed: %@\n With Response: %@", error.localizedDescription, response);
	
	NSDictionary *results				= jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
																		 options:NSJSONReadingMutableLeaves
																		   error:&error] : nil;
	
	if (error)							NSLog(@"JSON Serialisation Failed: %@", error.localizedDescription);
	
	return results;
}

@end