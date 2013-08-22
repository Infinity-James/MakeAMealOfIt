//
//  Recipe.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Recipe.h"
#import "YummlyAPI.h"

#pragma mark - Constants & Static Variables: Yummly Recipe Keys

static NSString *const kYummlyRecipeAttributionKey							= @"attribution";
NSString *const kYummlyRecipeAttributionHTMLKey								= @"html";
NSString *const kYummlyRecipeAttributionLogoKey								= @"logo";
NSString *const kYummlyRecipeAttributionTextKey								= @"text";
NSString *const kYummlyRecipeAttributionURLKey								= @"url";

static NSString *const kYummlyRecipeIDKey									= @"id";

static NSString *const kYummlyRecipeImagesKey								= @"images";
static NSString *const kYummlyRecipeImagesLargeURLKey						= @"hostedLargeUrl";

static NSString *const kYummlyRecipeIngredientLinesKey						= @"ingredientLines";

static NSString *const kYummlyRecipeFlavoursKey								= @"flavors";
NSString *const kYummlyRecipeFlavoursBitterKey								= @"bitter";
NSString *const kYummlyRecipeFlavoursMeatyKey								= @"meaty";
NSString *const kYummlyRecipeFlavoursPiquantKey								= @"piquant";
NSString *const kYummlyRecipeFlavoursSaltyKey								= @"salty";
NSString *const kYummlyRecipeFlavoursSourKey								= @"sour";
NSString *const kYummlyRecipeFlavoursSweetKey								= @"sweet";

static NSString *const kYummlyRecipeNameKey									= @"name";

static NSString *const kYummlyRecipeNutritionEstimatesKey					= @"nutritionEstimates";
NSString *const kYummlyRecipeNutritionEstimatesAttributeKey					= @"attribute";
NSString *const kYummlyRecipeNutritionEstimatesDescriptionKey				= @"description";
NSString *const kYummlyRecipeNutritionEstimatesValueKey						= @"value";
NSString *const kYummlyRecipeNutritionEstimatesUnitKey						= @"unit";
NSString *const kYummlyRecipeNutritionEstimatesUnitNameKey					= @"name";
NSString *const kYummlyRecipeNutritionEstimatesUnitAbbreviationKey			= @"abbreviation";
NSString *const kYummlyRecipeNutritionEstimatesUnitPluralKey				= @"plural";
NSString *const kYummlyRecipeNutritionEstimatesUnitPluralAbbreviationKey	= @"pluralAbbreviation";

static NSString *const kYummlyRecipeRatingKey								= @"rating";

static NSString *const kYummlyRecipeServingsKey								= @"numberOfServings";

static NSString *const kYummlyRecipeSourceKey								= @"source";
NSString *const kYummlyRecipeSourceDisplayNameKey							= @"sourceDisplayName";
NSString *const kYummlyRecipeSourceRecipeURLKey								= @"sourceRecipeUrl";
NSString *const kYummlyRecipeSourceWebsiteURLKey							= @"sourceSiteUrl";

static NSString *const kYummlyRecipeTotalCookTimeKey						= @"totalTimeInSeconds";

static NSString *const kYummlyRecipeYieldKey								= @"yield";



#pragma mark - Recipe Private Class Extension

@interface Recipe () {}

#pragma mark - Private Properties

/**	The dictionary of details to be used when attributing Yummly for this recipe.	*/
@property (nonatomic, readwrite, strong)	NSDictionary	*attributionDictionary;
/**	An array of ingredients for the recipe.	*/
@property (nonatomic, readwrite, strong)	NSArray			*ingredientLines;
/**	A dictionary of the flavours of this recipe.	*/
@property (nonatomic, readwrite, strong)	NSDictionary	*flavourDictionary;
/**	The number of servings that this recipe provides.	*/
@property (nonatomic, readwrite, assign)	NSUInteger		numberOfServings;
/**	The rating out of five stars for this recipe.	*/
@property (nonatomic, readwrite, assign)	CGFloat			rating;
/**	The dictionary holding all of the properties of this recipe in a raw form.	*/
@property (nonatomic, strong)				NSDictionary	*recipeDictionary;
/**	A large image associated with this recipe.	*/
@property (nonatomic, readwrite, strong)	UIImage			*recipeImage;
/**	The name of this recipe.	*/
@property (nonatomic, readwrite, strong)	NSString		*recipeName;
/**	A dictionary of detail about the source of this recipe.	*/
@property (nonatomic, readwrite, strong)	NSDictionary	*sourceDictionary;
/**	The length of time in seconds required to cook the recipe.	*/
@property (nonatomic, readwrite, assign)	NSUInteger		totalCookTime;

@end

#pragma mark - Recipe Implementation

@implementation Recipe {}

#pragma mark - Initialisation

/**
 *	Initializes and returns a newly allocated recipe object with a unique ID and delegate.
 *
 *	@param	recipeID					A unique string for this recipe used when fetching the recipes.
 */
- (void)basicInitialisation:(NSString *)recipeID
{
	//	store the recipe dictionary results
	[YummlyAPI asynchronousGetRecipeCallForRecipeID:recipeID withCompletionHandler:^(BOOL success, NSDictionary *results)
	{
		self.recipeDictionary		= results;
	}];
}

/**
 *	Initializes and returns a newly allocated recipe object with a unique ID.
 *
 *	@param	recipeID					A unique string for this recipe used when fetching the recipes.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
{
	if (self = [super init])
	{
		[self basicInitialisation:recipeID];
	}
	
	return self;
}

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
					 andDelegate:(id <RecipeDelegate>)delegate
{
	if (self = [super init])
	{
		self.delegate					= delegate;
		
		[self basicInitialisation:recipeID];
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	This dictionary holds the stuff that attributes yummly for the search.
 *
 *	@return	A dictionary holding the various objects needed to properly attribute Yummly for a recipe.
 */
- (NSDictionary *)attributionDictionary
{
	if (!_attributionDictionary)
		_attributionDictionary			= self.recipeDictionary[kYummlyRecipeAttributionKey];
	
	return _attributionDictionary;
}

/**
 *	The ingredients required for the recipe along with the quantity.
 *
 *	@return	An array of ingredients required for the recipe.
 */
- (NSArray *)ingredientLines
{
	if (!_ingredientLines)
		_ingredientLines				= self.recipeDictionary[kYummlyRecipeIngredientLinesKey];
	
	return _ingredientLines;
}

/**
 *	A dictionary containing each flavour and their value for this recipe.
 *
 *	@return	An NSDictionary with each flavour as a key, and the value is how much of that flavour the recipe has.
 */
- (NSDictionary *)flavourDictionary
{
	if  (!_flavourDictionary)
		_flavourDictionary				= self.recipeDictionary[kYummlyRecipeFlavoursKey];
	
	return _flavourDictionary;
}

/**
 *	The amount of people this recipe serves.
 *
 *	@return	The amount of people this recipe serves.
 */
- (NSUInteger)numberOfServings
{
	if (!_numberOfServings)
		_numberOfServings				= [self.recipeDictionary[kYummlyRecipeServingsKey] integerValue];
	
	return _numberOfServings;
}

/**
 *	The rating of this recipe out of five.
 *
 *	@return	The rating of this recipe out of five.
 */
- (CGFloat)rating
{
	if (!_rating)
		_rating							= [self.recipeDictionary[kYummlyRecipeRatingKey] floatValue];
	
	return _rating;
}

/**
 *	The image for the recipe.
 *
 *	@return	A large UIImage for the recipe.
 */
- (UIImage *)recipeImage
{
	if (!_recipeImage)
	{
		NSString *imageURLString		= self.recipeDictionary[kYummlyRecipeImagesKey][0][kYummlyRecipeImagesLargeURLKey];
		imageURLString					= [imageURLString stringByReplacingOccurrencesOfString:@".l." withString:@".xl."];
		if (!imageURLString)			return nil;
		[NetworkActivityIndicator start];
		NSData *imageData				= [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:imageURLString]];
		[NetworkActivityIndicator stop];
		_recipeImage					= [[UIImage alloc] initWithData:imageData];
	}
	
	return _recipeImage;
}

/**
 *	The name of the recipe.
 *
 *	@return The name of the recipe.
 */
- (NSString *)recipeName
{
	if (!_recipeName)
		_recipeName						= self.recipeDictionary[kYummlyRecipeNameKey];
	
	return _recipeName;
}

/**
 *	Sets the delegate interested in knowing the details of this recipe.
 *
 *	@param	delegate					The object interested in knowing the details of this recipe.
 */
- (void)setDelegate:(id<RecipeDelegate>)delegate
{
	_delegate							= delegate;
	
	if (self.recipeDictionary && [_delegate respondsToSelector:@selector(recipeDictionaryHasLoaded)])
		[self.delegate recipeDictionaryHasLoaded];
}

/**
 *	Sets the recipe dictionary with the dictionary of all the recipe details we fetched.
 *
 *	@param	recipeDictionary			The dictionary with details about the recipe we wanted to fetch.
 */
- (void)setRecipeDictionary:(NSDictionary *)recipeDictionary
{
	_recipeDictionary					= recipeDictionary;
	
	if (_recipeDictionary)
		if ([self.delegate respondsToSelector:@selector(recipeDictionaryHasLoaded)])
			[self.delegate recipeDictionaryHasLoaded];
}

/**
 *	The dictionary holding the information about the source of this recipe.
 *
 *	@return	The dictionary holding the information about the source of this recipe.
 */
- (NSDictionary *)sourceDictionary
{
	if (!_sourceDictionary)
		_sourceDictionary				= self.recipeDictionary[kYummlyRecipeSourceKey];
	
	return _sourceDictionary;
}

/**
 *	The amount of time this recipe takes to make (in seconds).
 *
 *	@return	The amount of time this recipe takes to make (in seconds).
 */
- (NSUInteger)totalCookTime
{
	if (!_totalCookTime)
		_totalCookTime					= [self.recipeDictionary[kYummlyRecipeTotalCookTimeKey] integerValue];
	
	return _totalCookTime;
}

@end