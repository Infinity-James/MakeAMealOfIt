//
//  YummlyRequest.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAPI.h"

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

- (void)removeDesiredCourse:(NSString *)desiredCourse;
- (void)removeDesiredCuisine:(NSString *)desiredCuisine;
- (void)removeDesiredHoliday:(NSString *)desiredHolday;
- (void)removeDesiredIngredient:(NSString *)desiredIngredient;

#pragma mark - Remove Exclusions

- (void)removeExcludedCourse:(NSString *)excludedCourse;
- (void)removeExcludedCuisine:(NSString *)excludedCuisine;
- (void)removeExcludedHoliday:(NSString *)excludedHoliday;
- (void)removeExcludedIngredient:(NSString *)excludedIngredient;

#pragma mark - Remove Requirements

- (void)removeRequiredAllergy:(NSString *)requiredAllergy;
- (void)removeRequiredDiet:(NSString *)requiredDiet;

#pragma mark - Set Values

- (void)setFlavourValue:(CGFloat)flavourValue
				 forKey:(NSString *)flavourKey
				atRange:(NSString *)rangeKey;

#pragma mark - Utility Methods

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

@end