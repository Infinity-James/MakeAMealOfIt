//
//  Recipe.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Public Constants & Static Variables: Yummly Recipe Keys

extern NSString *const kYummlyRecipeAttributionHTMLKey;
extern NSString *const kYummlyRecipeAttributionLogoKey;
extern NSString *const kYummlyRecipeAttributionTextKey;
extern NSString *const kYummlyRecipeAttributionURLKey;

NSString *const kYummlyRecipeFlavoursBitterKey;
NSString *const kYummlyRecipeFlavoursMeatyKey;
NSString *const kYummlyRecipeFlavoursPiquantKey;
NSString *const kYummlyRecipeFlavoursSaltyKey;
NSString *const kYummlyRecipeFlavoursSourKey;
NSString *const kYummlyRecipeFlavoursSweetKey;

extern NSString *const kYummlyRecipeNutritionEstimatesAttributeKey;
extern NSString *const kYummlyRecipeNutritionEstimatesDescriptionKey;
extern NSString *const kYummlyRecipeNutritionEstimatesValueKey;
extern NSString *const kYummlyRecipeNutritionEstimatesUnitKey;
extern NSString *const kYummlyRecipeNutritionEstimatesUnitNameKey;
extern NSString *const kYummlyRecipeNutritionEstimatesUnitAbbreviationKey;
extern NSString *const kYummlyRecipeNutritionEstimatesUnitPluralKey;
extern NSString *const kYummlyRecipeNutritionEstimatesUnitPluralAbbreviationKey;

extern NSString *const kYummlyRecipeSourceDisplayNameKey;
extern NSString *const kYummlyRecipeSourceRecipeURLKey;
extern NSString *const kYummlyRecipeSourceWebsiteURLKey;

#pragma mark - Recipe Delegate Protocol

@protocol RecipeDelegate <NSObject>

@optional

- (void)recipeDictionaryHasLoaded;

@end

#pragma mark - Recipe Public Interface

@interface Recipe : NSObject {}

#pragma mark - Public Properties

@property (nonatomic, readonly, strong)	NSDictionary	*attributionDictionary;
@property (nonatomic, readonly, strong)	NSArray			*ingredientLines;
@property (nonatomic, readonly, strong)	NSDictionary	*flavourDictionary;
@property (nonatomic, readonly, assign)	NSUInteger		numberOfServings;
@property (nonatomic, readonly, assign)	CGFloat			rating;
@property (nonatomic, readonly, strong)	UIImage			*recipeImage;
@property (nonatomic, readonly, strong)	NSString		*recipeName;
@property (nonatomic, readonly, strong)	NSDictionary	*sourceDictionary;
@property (nonatomic, readonly, assign)	NSUInteger		totalCookTime;

@property (nonatomic, weak)		id <RecipeDelegate>		delegate;

#pragma mark - Public Methods

- (instancetype)initWithRecipeID:(NSString *)recipeID;
- (instancetype)initWithRecipeID:(NSString *)recipeID
					 andDelegate:(id <RecipeDelegate>)delegate;

@end