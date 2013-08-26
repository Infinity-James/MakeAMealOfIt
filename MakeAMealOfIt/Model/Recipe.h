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

/**
 *	Called when the recipe loaded it's details.
 */
- (void)recipeDictionaryHasLoaded;

@end

#pragma mark - Recipe Public Interface

@interface Recipe : NSObject <NSCoding> {}

#pragma mark - Public Properties

/**	The dictionary of details to be used when attributing Yummly for this recipe.	*/
@property (nonatomic, readonly, strong)	NSDictionary	*attributionDictionary;
/**	An array of ingredients for the recipe.	*/
@property (nonatomic, readonly, strong)	NSArray			*ingredientLines;
/**	A dictionary of the flavours of this recipe.	*/
@property (nonatomic, readonly, strong)	NSDictionary	*flavourDictionary;
/**	The number of servings that this recipe provides.	*/
@property (nonatomic, readonly, assign)	NSUInteger		numberOfServings;
/**	The rating out of five for this recipe.	*/
@property (nonatomic, readonly, assign)	CGFloat			rating;
/**	The ID of the recipe being displayed.	*/
@property (nonatomic, readonly, strong)	NSString		*recipeID;
/**	A large image associated with this recipe.	*/
@property (nonatomic, readonly, strong)	UIImage			*recipeImage;
/**	The name of this recipe.	*/
@property (nonatomic, readonly, strong)	NSString		*recipeName;
/**	A dictionary of detail about the source of this recipe.	*/
@property (nonatomic, readonly, strong)	NSDictionary	*sourceDictionary;
/**	The length of time in seconds required to cook the recipe.	*/
@property (nonatomic, readonly, assign)	NSUInteger		totalCookTime;
/**	The delegate interested in knowing the details of this recipe.	*/
@property (nonatomic, weak)		id <RecipeDelegate>		delegate;

#pragma mark - Public Methods

/**
 *	Initializes and returns a newly allocated recipe object with a unique ID.
 *
 *	@param	recipeID					A unique string for this recipe used when fetching the recipes.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID;
/**
 *
 *	Initializes and returns a newly allocated recipe object with a unique ID and delegate.
 *
 *	@param	recipeID					A unique string for this recipe used when fetching the recipes.
 *	@param	delegate					The delegate interested in knowing the details of this recipe.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
					 andDelegate:(id <RecipeDelegate>)delegate;

@end