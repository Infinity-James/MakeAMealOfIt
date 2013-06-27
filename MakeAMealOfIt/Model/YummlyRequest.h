//
//  YummlyRequest.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAPI.h"
#import "YummlyMetadata.h"

#pragma mark - Constants & Static Variables

extern NSString *const kYummlyFlavourBitter;
extern NSString *const kYummlyFlavourMeaty;
extern NSString *const kYummlyFlavourPiquant;
extern NSString *const kYummlyFlavourSour;
extern NSString *const kYummlyFlavourSweet;
extern NSString *const kYummlyMaximumKey;
extern NSString *const kYummlyMinimumKey;

#pragma mark - Yummly Request Public Interface

@interface YummlyRequest : NSObject {}

#pragma mark - Request Properties

/**	The maximum time the recipe should take to make.	*/
@property (nonatomic, assign)	NSUInteger	maximumCookTime;
/**	The number of results desired by the request.	*/
@property (nonatomic, assign)	NSUInteger	numberOfResults;
/**	Whether or not pictures should be required for each result.	*/
@property (nonatomic, assign)	BOOL		requirePictures;
/**	A query phrase to be used in the search for recipes.	*/
@property (nonatomic, strong)	NSString	*searchPhrase;
/**	Where the index of results should begin.	*/
@property (nonatomic, assign)	NSUInteger	startIndexForResults;

#pragma mark - Adding Desires

/**
 *	Adds a course specification that the returned recipes need to include.
 *
 *	@param	desiredCourse				The course that the user wants the recipes to be.
 */
- (void)addDesiredCourse:(NSString *)desiredCourse;
/**
 *	Adds a cuisine type that returned recipes need to include.
 *
 *	@param	desiredCuisine				The type of cuisine the user would like.
 */
- (void)addDesiredCuisine:(NSString *)desiredCuisine;
/**
 *	Adds a holiday that the meal needs to be related to.
 *
 *	@param	desiredHoliday				The type of holiday that the user is interested in.
 */
- (void)addDesiredHoliday:(NSString *)desiredHolday;
/**
 *	Adds an ingredient the user wanted the recipes to include.
 *
 *	@param	desiredIngredient			The ingredient the user wants the meal to include.
 */
- (void)addDesiredIngredient:(NSString *)desiredIngredient;

#pragma mark - Adding Exclusions

/**
 *	Adds a course to exclude from recipe return results.
 *
 *	@param	excludedCourse				A course type that the user doesn't want the meal to be.
 */
- (void)addExcludedCourse:(NSString *)excludedCourse;
/**
 *	Adds a cuisine that the recipes should not include.
 *
 *	@param	excludedCuisine				The cuisine type to not exclude from results.
 */
- (void)addExcludedCuisine:(NSString *)excludedCuisine;
/**
 *	Adds a holiday meal type to exclude from results.
 *
 *	@param	excludedHoliday				The holiday to exclude from recipe results.
 */
- (void)addExcludedHoliday:(NSString *)excludedHoliday;
/**
 *	Adds an ingredient that if any meals include we should not receive them in results.
 *
 *	@param	excludedIngredient			An ingredient to exclude from the recipe results.
 */
- (void)addExcludedIngredient:(NSString *)excludedIngredient;

#pragma mark - Adding Requirements

/**
 *	Adds an allergy type that a returned recipe must conform to.
 *
 *	@param	requiredAllergy				The allergy that recipes should conform to.
 */
- (void)addRequiredAllergy:(NSString *)requiredAllergy;
/**
 *	Adds a diet type (like vegetarian) that recipes need to conform to.
 *
 *	@param	requiredDiet				The recipes need to be okay for this diet.
 */
- (void)addRequiredDiet:(NSString *)requiredDiet;

#pragma mark - Remove Desires

/**
 *	Removes a previously added course specification that the returned recipes needed to include.
 *
 *	@param	desiredCourse				The course that the user wanted the recipes to be, but doesn't anymore.
 */
- (void)removeDesiredCourse:(NSString *)desiredCourse;
/**
 *	Removes a previously added a cuisine type that returned recipes needed to include.
 *
 *	@param	desiredCuisine				The type of cuisine the user wanted but no longer does.
 */
- (void)removeDesiredCuisine:(NSString *)desiredCuisine;
/**
 *	Removes a previously added holiday that the meal needed to be related to.
 *
 *	@param	desiredHoliday				the type of holiday that the user was interested in but is no longer.
 */
- (void)removeDesiredHoliday:(NSString *)desiredHolday;
/**
 *	Removes a previously added ingredient the user wanted the recipes to include.
 *
 *	@param	desiredIngredient			The ingredient the user wanted the meal to include but no longer does.
 */
- (void)removeDesiredIngredient:(NSString *)desiredIngredient;

#pragma mark - Remove Exclusions

/**
 *	Removes a previously added course that was supposed to be excluded from recipe return results.
 *
 *	@param	excludedCourse				A course type that was previously excluded.
 */
- (void)removeExcludedCourse:(NSString *)excludedCourse;
/**
 *	Removes a previously added cuisine that the recipes should not have included.
 *
 *	@param	excludedCuisine				The cuisine type that was previously excluded.
 */
- (void)removeExcludedCuisine:(NSString *)excludedCuisine;
/**
 *	Removes a previously added holiday meal type that was to be excluded from results.
 *
 *	@param	excludedHoliday				The holiday to no longer exclude.
 */
- (void)removeExcludedHoliday:(NSString *)excludedHoliday;
/**
 *	Removes a previously added ingredient that if any meals included we should not have received them in results.
 *
 *	@param	excludedIngredient			An ingredient to no longer exclude.
 */
- (void)removeExcludedIngredient:(NSString *)excludedIngredient;

#pragma mark - Remove Requirements

/**
 *	Removes a previously added allergy type that a returned recipe must have conformed to.
 *
 *	@param	requiredAllergy				The allergy that recipes no longer have to conform to.
 */
- (void)removeRequiredAllergy:(NSString *)requiredAllergy;
/**
 *	Removes a previously added allergy type that a returned recipe must have conformed to.
 *
 *	@param	requiredAllergy				The allergy that recipes no longer have to conform to.
 */
- (void)removeRequiredDiet:(NSString *)requiredDiet;

#pragma mark - Set Values

/**
 *	Sets a value for a given flavour and at the given range extreme (min or max).
 *
 *	@param	flavourValue				The value from 0 to 1 for the flavour.
 *	@param	flavourKey					The flavour to apply the value to.
 *	@param	rangeKey					Whether the value is the minimum or maximum for the flavour.
 */
- (void)setFlavourValue:(CGFloat)flavourValue
				 forKey:(NSString *)flavourKey
				atRange:(NSString *)rangeKey;

#pragma mark - Utility Methods

/**
 *	Executes this request with all the parameters defined in it.
 *
 *	@param	searchRecipesCallCompleted	The completion handler to call with the results of the request.
 */
- (void)executeSearchRecipesCallWithCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted;
/**
 *	Returns this yummly request objects as the search parameters needed for a request.
 *
 *	@return	A string of search parameters to be used in a URL for Yummly.
 */
- (NSString *)getAsSearchParameters;
/**
 *	This should be called after results have already been fetched and the user wants more results with the same request.
 *
 *	@param	completionHandler			The block to call when the request for more results has completed.
 */
- (void)getMoreResults:(YummlyRequestCompletionBlock)completionHandler;
/**
 *	Resets the entirety of this Yummly Request.
 */
- (void)reset;

@end