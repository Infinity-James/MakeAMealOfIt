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

#pragma mark - Make API Call Methods: Asynchronous

/**
 *	Asynchronously makes a request to Yummly for metadata.
 *
 *	@param	metadataKey					The type of metadata to request.
 *	@param	getMetadataCallCompleted	A block called when the request has completed. Results will be found under the kYummlyRequestResultsMetadataKey.
 */
+ (void)asynchronousGetMetadataForKey:(NSString *)metadataKey
				withCompletionHandler:(YummlyRequestCompletionBlock)getMetadataCallCompleted
{
	dispatch_async(dispatch_queue_create("Metadata Fetcher", NULL),
	^{
		//	executes the synchronous request but in a separate thread
		NSArray *results				= [self synchronousGetMetadataForKey:metadataKey];
		
		//	call the completion block indicating either success or failure
		if (results)
			getMetadataCallCompleted(YES, @{kYummlyRequestResultsMetadataKey: results})	;
		else
			getMetadataCallCompleted(NO, nil);
	});
}

/**
 *	Asynchronously makes a request to Yummly for details on a specific recipe.
 *
 *	@param	recipeID					The ID for the recipe to get the details of.
 *	@param	getRecipeCallCompleted		A block called when the recipe is retrieved (either successfully or not).
 */
+ (void)asynchronousGetRecipeCallForRecipeID:(NSString *)recipeID
					   withCompletionHandler:(YummlyRequestCompletionBlock)getRecipeCallCompleted
{
	//	create the url and request object
	NSString *getRecipeURL				= [NSString stringWithFormat:@"%@/recipe/%@", kYummlyBaseAPIURL, recipeID];
	NSURLRequest *yummlyURLRequest		= [self authenticatedYummlyURLRequestForURL:[[NSURL alloc] initWithString:getRecipeURL]];
	
	//	execute the created and authenticated request asynchronously
	[self asynchronouslyExecuteYummlyURLRequest:yummlyURLRequest withCompletionHandler:getRecipeCallCompleted];
}

/**
 *	Asynchronously searches for recipes with the given search parameters.
 *
 *	@param	searchParameters			The defined terms for the recipes search.
 *	@param	searchRecipesCallCompleted	A block which is called when the search for recipes has completed (successfully or not).
 */
+ (void)asynchronousSearchRecipesCallWithParameters:(NSString *)searchParameters
							   andCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted
{
	//	create the url and request object
	NSString *yummlySearchURL			= [[NSString alloc] initWithFormat:@"%@/recipes?%@", kYummlyBaseAPIURL, searchParameters];
	yummlySearchURL						= [yummlySearchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"Final URL: %@", yummlySearchURL);
	NSURLRequest *yummlyURLRequest		= [self authenticatedYummlyURLRequestForURL:[[NSURL alloc] initWithString:yummlySearchURL]];
	
	//	execute the created and authenticated request asynchronously
	[self asynchronouslyExecuteYummlyURLRequest:yummlyURLRequest withCompletionHandler:searchRecipesCallCompleted];
	
}

#pragma mark - Make API Call Methods: Synchronous

/**
 *	Synchronously makes a request to Yummly for metadata.
 *
 *	@param	metadataKey					The type of metadata to request.
 *
 *	@return	An array of the the dictionaries of the type of metadata requested.
 */
+ (NSArray *)synchronousGetMetadataForKey:(NSString *)metadataKey
{
	//	makes sure that the requested type of metadata requested is actually valid
	if (![[self metadataKeys] containsObject:metadataKey])
		return nil;
	
	NSString *getMetadataURL			= [NSString stringWithFormat:@"%@/metadata/%@?%@", kYummlyBaseAPIURL, metadataKey, kYummlyAuthorisationURLExtension];
	[NetworkActivityIndicator start];
	NSString *jsonString				= [[NSString alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:getMetadataURL] encoding:NSUTF8StringEncoding error:nil];
	[NetworkActivityIndicator stop];
	jsonString							= [jsonString stringByReplacingOccurrencesOfString:@"set_metadata(" withString:@""];
	jsonString							= [jsonString stringByReplacingOccurrencesOfString:@");" withString:@""];
	jsonString							= [jsonString stringByReplacingOccurrencesOfString:[[NSString alloc] initWithFormat:@"'%@', ", metadataKey] withString:@""];
	NSData *jsonData					= [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *results					= [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
	return results;
}

#pragma mark - Setter & Getter Methods

/**
 *	Returns the valid metadata keys.
 *
 *	@return	An array of metadata keys that exist on the Yummly database.
 */
+ (NSArray *)metadataKeys
{
	return @[kYummlyMetadataAllergies, kYummlyMetadataCourses, kYummlyMetadataCuisines, kYummlyMetadataDiets, kYummlyMetadataHolidays, kYummlyMetadataIngredients];
}

#pragma mark - Utility Methods

/**
 *	Takes a URL request, executes it asynchronously and calls back with the results.
 *
 *	@param	yummlyURLRequest			The URL request to be executed in a separate thread.
 *	@param	yummlyURLRequestCompleted	The completion block to call when the URL request has finished, either successfully or unsuccessfully.
 */
+ (void)asynchronouslyExecuteYummlyURLRequest:(NSURLRequest *)yummlyURLRequest
						withCompletionHandler:(YummlyRequestCompletionBlock)yummlyURLRequestCompleted
{
	//	create a queue for the request to be executed on
	NSOperationQueue *yummlyQueue		= [[NSOperationQueue alloc] init];
	
	//	executes the request asynchronously indicating the use of internet with network activity indicator 
	[NetworkActivityIndicator start];
	[NSURLConnection sendAsynchronousRequest:yummlyURLRequest
									   queue:yummlyQueue
						   completionHandler:^(NSURLResponse *response, NSData *jsonData, NSError *error)
	{
		//	stop the network activity indicator now the request is complete
		[NetworkActivityIndicator stop];
		//	if it failed we log as much
		if (error)						NSLog(@"Yummly Request Failed: %@\n With Response: %@", error.localizedDescription, response);
		NSLog(@"Response: %@", response);
		
		//	get a dictionary of results from the returned json
		NSDictionary *results			= jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
																			  options:NSJSONReadingMutableLeaves
																				error:&error] : nil;
		
		if (error)						NSLog(@"JSON Serialisation Failed: %@", error.localizedDescription);
		
		//	call back with whether it was a success and any results we got
		yummlyURLRequestCompleted(!error, results);
	}];
}

/**
 *	Returns a URL request object with authentication header for a given URL.
 *
 *	@param	url							The URL to use to create the request with.
 *
 *	@return	A URL request for the given URL with the app ID and keys in the headers for authentication.
 */
+ (NSURLRequest *)authenticatedYummlyURLRequestForURL:(NSURL *)url
{
	//	creates the url request with the given url
	NSMutableURLRequest *yummlyURLRequest	= [[NSMutableURLRequest alloc] initWithURL:url];
	
	//	adds the authentication id's to the quest through headers
	[yummlyURLRequest addValue:kYummlyAppID forHTTPHeaderField:kYummlyAppIDHeaderField];
	[yummlyURLRequest addValue:kYummlyAppKey forHTTPHeaderField:kYummlyAppKeyHeaderField];
	
	//	makes sure that the request times out after 20 seconds of waiting
	yummlyURLRequest.timeoutInterval		= 20.0f;
	
	return (NSURLRequest *)yummlyURLRequest;
}

/**
 *	Takes a URL request and executes it synchronously.
 *
 *	@param	yummlyURLRequest			The URL request to be executed.
 *
 *	@return	A dictionary of any results we got back from Yummly.
 */
+ (NSDictionary *)synchronouslyExecuteYummlyURLRequest:(NSURLRequest *)yummlyURLRequest
{	
	NSURLResponse *response;
	NSError *error;
	
	[NetworkActivityIndicator start];
	NSData *jsonData					= [NSURLConnection sendSynchronousRequest:yummlyURLRequest returningResponse:&response error:&error];
	[NetworkActivityIndicator stop];
	
	if (error)							NSLog(@"Yummly Request Failed: %@\n With Response: %@", error.localizedDescription, response);
	
	NSDictionary *results				= jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
																		 options:NSJSONReadingMutableLeaves
																		   error:&error] : nil;
	
	if (error)							NSLog(@"JSON Serialisation Failed: %@", error.localizedDescription);
	
	return results;
}

@end