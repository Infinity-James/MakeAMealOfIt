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
/**	*/
@property (nonatomic, readwrite, strong)	NSDictionary	*flavourDictionary;
@property (nonatomic, readwrite, assign)	NSUInteger		numberOfServings;
@property (nonatomic, readwrite, assign)	CGFloat			rating;
@property (nonatomic, readwrite, strong)	UIImage			*recipeImage;
@property (nonatomic, readwrite, strong)	NSString		*recipeName;
@property (nonatomic, readwrite, strong)	NSDictionary	*sourceDictionary;
@property (nonatomic, readwrite, assign)	NSUInteger		totalCookTime;

@property (nonatomic, strong)				NSDictionary	*recipeDictionary;

@end

#pragma mark - Recipe Implementation

@implementation Recipe {}

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
{
	if (self = [super init])
	{
		//	store the recipe dictionary results
		[YummlyAPI asynchronousGetRecipeCallForRecipeID:recipeID withCompletionHandler:^(BOOL success, NSDictionary *results)
		 {
			 self.recipeDictionary		= results;
		 }];
	}
	
	return self;
}

/**
 *	called to initialise a class instance
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
					 andDelegate:(id <RecipeDelegate>)delegate
{
	if (self = [super init])
	{
		self.delegate					= delegate;
		
		//	store the recipe dictionary results
		[YummlyAPI asynchronousGetRecipeCallForRecipeID:recipeID withCompletionHandler:^(BOOL success, NSDictionary *results)
		{
			self.recipeDictionary		= results;
		}];
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	this dictionary holds the stuff that attributes yummly for the search
 */
- (NSDictionary *)attributionDictionary
{
	if (!_attributionDictionary)
		_attributionDictionary			= self.recipeDictionary[kYummlyRecipeAttributionKey];
	
	return _attributionDictionary;
}

/**
 *	the ingredients required for the recipe along with the quantity
 */
- (NSArray *)ingredientLines
{
	if (!_ingredientLines)
		_ingredientLines				= self.recipeDictionary[kYummlyRecipeIngredientLinesKey];
	
	return _ingredientLines;
}

/**
 *	a dictionary containing each flavour and their value for this recipe
 */
- (NSDictionary *)flavourDictionary
{
	if  (!_flavourDictionary)
		_flavourDictionary				= self.recipeDictionary[kYummlyRecipeFlavoursKey];
	
	return _flavourDictionary;
}

/**
 *	the amount of people this recipe serves
 */
- (NSUInteger)numberOfServings
{
	if (!_numberOfServings)
		_numberOfServings				= [self.recipeDictionary[kYummlyRecipeServingsKey] integerValue];
	
	return _numberOfServings;
}

/**
 *	the rating of this recipe in stars
 */
- (CGFloat)rating
{
	if (!_rating)
		_rating							= [self.recipeDictionary[kYummlyRecipeRatingKey] floatValue];
	
	return _rating;
}

/**
 *	the image for the recipe
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
 *	returns the name for the recipe
 */
- (NSString *)recipeName
{
	if (!_recipeName)
		_recipeName						= self.recipeDictionary[kYummlyRecipeNameKey];
	
	return _recipeName;
}

/**
 *	sets the recipe dictionary with the dictionary of all the recipe details we fetched
 *
 *	@param	recipeDictionary			the dictionary with details about the recipe we wanted to fetch
 */
- (void)setRecipeDictionary:(NSDictionary *)recipeDictionary
{
	_recipeDictionary					= recipeDictionary;
	
	if (_recipeDictionary)
		if ([self.delegate respondsToSelector:@selector(recipeDictionaryHasLoaded)])
			[self.delegate recipeDictionaryHasLoaded];
}

/**
 *	the dictionary holding the information about the source of this recipe
 */
- (NSDictionary *)sourceDictionary
{
	if (!_sourceDictionary)
		_sourceDictionary				= self.recipeDictionary[kYummlyRecipeSourceKey];
	
	return _sourceDictionary;
}

/**
 *	the amount of time this recipe takes to make (in seconds)
 */
- (NSUInteger)totalCookTime
{
	if (!_totalCookTime)
		_totalCookTime					= [self.recipeDictionary[kYummlyRecipeTotalCookTimeKey] integerValue];
	
	return _totalCookTime;
}

@end