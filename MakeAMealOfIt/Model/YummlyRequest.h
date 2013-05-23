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

@property (nonatomic, assign)	NSUInteger	maximumCookTime;
@property (nonatomic, assign)	NSUInteger	numberOfResults;
@property (nonatomic, assign)	BOOL		requirePictures;
@property (nonatomic, strong)	NSString	*searchPhrase;
@property (nonatomic, assign)	NSUInteger	startIndexForResults;

#pragma mark - Adding Desires

- (void)addDesiredCourse:(NSString *)desiredCourse;
- (void)addDesiredCuisine:(NSString *)desiredCuisine;
- (void)addDesiredHoliday:(NSString *)desiredHolday;
- (void)addDesiredIngredient:(NSString *)desiredIngredient;

#pragma mark - Adding Exclusions

- (void)addExcludedCourse:(NSString *)excludedCourse;
- (void)addExcludedCuisine:(NSString *)excludedCuisine;
- (void)addExcludedHoliday:(NSString *)excludedHoliday;
- (void)addExcludedIngredient:(NSString *)excludedIngredient;

#pragma mark - Adding Requirements

- (void)addRequiredAllergy:(NSString *)requiredAllergy;
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

- (NSString *)getAsSearchParameters;
- (void)executeSearchRecipesCallWithCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted;

@end