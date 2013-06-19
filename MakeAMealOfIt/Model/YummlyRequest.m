//
//  YummlyRequest.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyRequest.h"

#pragma mark - Constants & Static Variables

NSString *const kYummlyFlavourBitter		= @"bitter";
NSString *const kYummlyFlavourMeaty			= @"meaty";
NSString *const kYummlyFlavourPiquant		= @"piquant";
NSString *const kYummlyFlavourSalty			= @"salty";
NSString *const kYummlyFlavourSour			= @"sour";
NSString *const kYummlyFlavourSweet			= @"sweet";
NSString *const kYummlyMaximumKey			= @"max";
NSString *const kYummlyMinimumKey			= @"min";

#pragma mark - Yummly Request Private Class Extension

@interface YummlyRequest () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	NSMutableArray			*desiredCourses;
@property (nonatomic, strong)	NSMutableArray			*desiredCuisines;
@property (nonatomic, strong)	NSMutableArray			*desiredHolidays;
@property (nonatomic, strong)	NSMutableArray			*desiredIngredients;
@property (nonatomic, strong)	NSMutableArray			*excludedCourses;
@property (nonatomic, strong)	NSMutableArray			*excludedCuisines;
@property (nonatomic, strong)	NSMutableArray			*excludedHolidays;
@property (nonatomic, strong)	NSMutableArray			*excludedIngredients;
@property (nonatomic, strong)	NSMutableDictionary		*flavourDictionary;
@property (nonatomic, strong)	NSMutableArray			*requiredAllergies;
@property (nonatomic, strong)	NSMutableArray			*requiredDiets;


@end

#pragma mark - Yummly Request Implementation

@implementation YummlyRequest {}

#pragma mark - Adding Desires

/**
 *	Adds a course specification that the returned recipes need to include.
 *
 *	@param	desiredCourse				The course that the user wants the recipes to be.
 */
- (void)addDesiredCourse:(NSString *)desiredCourse
{
	//	only add the course if it is not nil, has not yet been added, and is a valid course
	if (desiredCourse && ![self.desiredCourses containsObject:desiredCourse] &&
		[[YummlyRequest availableCourses] containsObject:desiredCourse])
		[self.desiredCourses addObject:desiredCourse];
}

/**
 *	Adds a cuisine type that returned recipes need to include.
 *
 *	@param	desiredCuisine				The type of cuisine the user would like.
 */
- (void)addDesiredCuisine:(NSString *)desiredCuisine
{
	if (desiredCuisine && ![self.desiredCuisines containsObject:desiredCuisine] &&
		[[YummlyRequest availableCuisines] containsObject:desiredCuisine])
		[self.desiredCuisines addObject:desiredCuisine];
}

/**
 *	Adds a holiday that the meal needs to be related to.
 *
 *	@param	desiredHoliday				The type of holiday that the user is interested in.
 */
- (void)addDesiredHoliday:(NSString *)desiredHoliday
{
	if (desiredHoliday && ![self.desiredHolidays containsObject:desiredHoliday] &&
		[[YummlyRequest availableHolidays] containsObject:desiredHoliday])
		[self.desiredHolidays addObject:desiredHoliday];
}

/**
 *	Adds an ingredient the user wanted the recipes to include.
 *
 *	@param	desiredIngredient			The ingredient the user wants the meal to include.
 */
- (void)addDesiredIngredient:(NSString *)desiredIngredient
{
	if (desiredIngredient && ![self.desiredIngredients containsObject:desiredIngredient] &&
		[[YummlyRequest availableIngredients] containsObject:desiredIngredient])
		[self.desiredIngredients addObject:desiredIngredient];
}

#pragma mark - Adding Exclusions

/**
 *	Adds a course to exclude from recipe return results.
 *
 *	@param	excludedCourse				A course type that the user doesn't want the meal to be.
 */
- (void)addExcludedCourse:(NSString *)excludedCourse
{
	if (excludedCourse && ![self.excludedCourses containsObject:excludedCourse] &&
		[[YummlyRequest availableCourses] containsObject:excludedCourse])
		[self.excludedCourses addObject:excludedCourse];
}

/**
 *	Adds a cuisine that the recipes should not include.
 *
 *	@param	excludedCuisine				The cuisine type to not exclude from results.
 */
- (void)addExcludedCuisine:(NSString *)excludedCuisine
{
	if (excludedCuisine && ![self.excludedCuisines containsObject:excludedCuisine] &&
		[[YummlyRequest availableCuisines] containsObject:excludedCuisine])
		[self.excludedCuisines addObject:excludedCuisine];
}

/**
 *	Adds a holiday meal type to exclude from results.
 *
 *	@param	excludedHoliday				The holiday to exclude from recipe results.
 */
- (void)addExcludedHoliday:(NSString *)excludedHoliday
{
	if (excludedHoliday && ![self.excludedHolidays containsObject:excludedHoliday] &&
		[[YummlyRequest availableHolidays] containsObject:excludedHoliday])
	[	self.excludedHolidays addObject:excludedHoliday];
}

/**
 *	Adds an ingredient that if any meals include we should not receive them in results.
 *
 *	@param	excludedIngredient			An ingredient to exclude from the recipe results.
 */
- (void)addExcludedIngredient:(NSString *)excludedIngredient
{
	if (excludedIngredient && ![self.excludedIngredients containsObject:excludedIngredient] &&
		[[YummlyRequest availableIngredients] containsObject:excludedIngredient])
		[self.excludedIngredients addObject:excludedIngredient];
}

#pragma mark - Adding Requirements

/**
 *	Adds an allergy type that a returned recipe must conform to.
 *
 *	@param	requiredAllergy				The allergy that recipes should conform to.
 */
- (void)addRequiredAllergy:(NSString *)requiredAllergy
{
	if (requiredAllergy && ![self.requiredAllergies containsObject:requiredAllergy] &&
		[[YummlyRequest availableAllergies] containsObject:requiredAllergy])
		[self.requiredAllergies addObject:requiredAllergy];
}

/**
 *	Adds a diet type (like vegetarian) that recipes need to conform to.
 *
 *	@param	requiredDiet				The recipes need to be okay for this diet.
 */
- (void)addRequiredDiet:(NSString *)requiredDiet
{
	if (requiredDiet && ![self.requiredDiets containsObject:requiredDiet] &&
		[[YummlyRequest availableDiets] containsObject:requiredDiet])
		[self.requiredDiets addObject:requiredDiet];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		[self initialiseArrays];
		[self addObserver:self forKeyPath:@"desiredCourses" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"desiredCuisines" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"desiredHolidays" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"desiredIngredients" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"excludedCourses" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"excludedCuisines" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"excludedHolidays" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"desiredIngredients" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"flavourDictionary" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"requiredAllergies" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"requiredDiets" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"maximumCookTime" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"numberOfResults" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"requirePictures" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"searchPhrase" options:kNilOptions context:nil];
		[self addObserver:self forKeyPath:@"startIndexForResults" options:kNilOptions context:nil];
	}
	
	return self;
}

/**
 *	Initialises all the arrays.
 */
- (void)initialiseArrays
{
	self.desiredCourses					= [[NSMutableArray alloc] init];
	self.desiredCuisines				= [[NSMutableArray alloc] init];
	self.desiredHolidays				= [[NSMutableArray alloc] init];
	self.desiredIngredients				= [[NSMutableArray alloc] init];
	self.excludedCourses				= [[NSMutableArray alloc] init];
	self.excludedCuisines				= [[NSMutableArray alloc] init];
	self.excludedHolidays				= [[NSMutableArray alloc] init];
	self.excludedIngredients			= [[NSMutableArray alloc] init];
	self.flavourDictionary				= [[NSMutableDictionary alloc] init];
	self.requiredAllergies				= [[NSMutableArray alloc] init];
	self.requiredDiets					= [[NSMutableArray alloc] init];
}

#pragma mark - NSKeyValueObserving Methods

/**
 *	This message is sent to the receiver when the value at the specified key path relative to the given object has changed.
 *
 *	@param	keyPath						The key path, relative to object, to the value that has changed.
 *	@param	object						The source object of the key path keyPath.
 *	@param	change						A dictionary describing the changes that have been made to the value of the property at the key path relative to object.
 *	@param	context						The value that was provided when the receiver was registered to receive key-value observation notifications.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	//	we just post a general notification that this the yummly request has been changed
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationYummlyRequestChanged object:nil];
}

#pragma mark - Remove Desires

/**
 *	Removes a previously added course specification that the returned recipes needed to include.
 *
 *	@param	desiredCourse				The course that the user wanted the recipes to be, but doesn't anymore.
 */
- (void)removeDesiredCourse:(NSString *)desiredCourse
{
	if (!desiredCourse)					return;
	[self.desiredCourses removeObject:desiredCourse];
}

/**
 *	Removes a previously added a cuisine type that returned recipes needed to include.
 *
 *	@param	desiredCuisine				The type of cuisine the user wanted but no longer does.
 */
- (void)removeDesiredCuisine:(NSString *)desiredCuisine
{
	if (!desiredCuisine)				return;
	[self.desiredCuisines removeObject:desiredCuisine];
}

/**
 *	Removes a previously added holiday that the meal needed to be related to.
 *
 *	@param	desiredHoliday				the type of holiday that the user was interested in but is no longer.
 */
- (void)removeDesiredHoliday:(NSString *)desiredHolday
{
	if (!desiredHolday)					return;
	[self.desiredHolidays removeObject:desiredHolday];
}

/**
 *	Removes a previously added ingredient the user wanted the recipes to include.
 *
 *	@param	desiredIngredient			The ingredient the user wanted the meal to include but no longer does.
 */
- (void)removeDesiredIngredient:(NSString *)desiredIngredient
{
	if (!desiredIngredient)				return;
	[self.desiredIngredients removeObject:desiredIngredient];
}

#pragma mark - Remove Exclusions

/**
 *	Removes a previously added course that was supposed to be excluded from recipe return results.
 *
 *	@param	excludedCourse				A course type that was previously excluded.
 */
- (void)removeExcludedCourse:(NSString *)excludedCourse
{
	if (!excludedCourse)				return;
	[self.excludedCourses removeObject:excludedCourse];
}

/**
 *	Removes a previously added cuisine that the recipes should not have included.
 *
 *	@param	excludedCuisine				The cuisine type that was previously excluded.
 */
- (void)removeExcludedCuisine:(NSString *)excludedCuisine
{
	if (!excludedCuisine)				return;
	[self.excludedCuisines removeObject:excludedCuisine];
}

/**
 *	Removes a previously added holiday meal type that was to be excluded from results.
 *
 *	@param	excludedHoliday				The holiday to no longer exclude.
 */
- (void)removeExcludedHoliday:(NSString *)excludedHoliday
{
	if (!excludedHoliday)				return;
	[self.excludedHolidays removeObject:excludedHoliday];
}

/**
 *	Removes a previously added ingredient that if any meals included we should not have received them in results.
 *
 *	@param	excludedIngredient			An ingredient to no longer exclude.
 */
- (void)removeExcludedIngredient:(NSString *)excludedIngredient
{
	if (!excludedIngredient)			return;
	[self.excludedIngredients removeObject:excludedIngredient];
}

#pragma mark - Remove Requirements

/**
 *	Removes a previously added allergy type that a returned recipe must have conformed to.
 *
 *	@param	requiredAllergy				The allergy that recipes no longer have to conform to.
 */
- (void)removeRequiredAllergy:(NSString *)requiredAllergy
{
	if (!requiredAllergy)				return;
	[self.requiredAllergies removeObject:requiredAllergy];
}

/**
 *	Removes a previously added diet type (like vegetarian) that recipes needed to be.
 *
 *	@param	requiredDiet				The diet that recipes no longer have to conform to.
 */
- (void)removeRequiredDiet:(NSString *)requiredDiet
{
	if (!requiredDiet)					return;
	[self.requiredDiets removeObject:requiredDiet];
}

#pragma mark - Available Metadata Methods

/**
 *	Returns all of the available allergies names.
 *
 *	@return	An array with names of each allergy available.
 */
+ (NSArray *)availableAllergies
{
	static NSMutableArray *availableAllergies;
	
	if (!availableAllergies)
	{
		availableAllergies				= [[NSMutableArray alloc] init];
		for (NSDictionary *allergyDictionary in [YummlyRequest availableAllergyDictionaries])
			[availableAllergies addObject:allergyDictionary[kYummlyMetadataShortDescriptionKey]];
	}
	
	return (NSArray *)availableAllergies;
}

/**
 *	Returns all of the available allergy dictionaries.
 *
 *	@return	An array of each allergy dictionary available.
 */
+ (NSArray *)availableAllergyDictionaries
{
	static NSArray *availableAllergyDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableAllergyDictionaries	= [YummlyMetadata allMetadata][kYummlyMetadataAllergies];
	});
	
	return availableAllergyDictionaries;
}

/**
 *	Returns all of the available course dictionaries.
 *
 *	@return	An array of each course dictionary available.
 */
+ (NSArray *)availableCourseDictionaries
{
	static NSArray *availableCourseDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableCourseDictionaries		= [YummlyMetadata allMetadata][kYummlyMetadataCourses];
	});
	
	return availableCourseDictionaries;
}

/**
 *	Returns all of the available course names.
 *
 *	@return	An array with names of each course available.
 */
+ (NSArray *)availableCourses
{
	static NSMutableArray *availableCourses;
	
	if (!availableCourses)
	{
		availableCourses				= [[NSMutableArray alloc] init];
		for (NSDictionary *courseDictionary in [YummlyRequest availableCourseDictionaries])
			[availableCourses addObject:courseDictionary[kYummlyMetadataDescriptionKey]];
	}
	
	return (NSArray *)availableCourses;
}

/**
 *	Returns all of the available cuisine dictionaries.
 *
 *	@return	An array of each cuisine dictionary available.
 */
+ (NSArray *)availableCuisineDictionaries
{
	static NSArray *availableCuisineDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableCuisineDictionaries		= [YummlyMetadata allMetadata][kYummlyMetadataCuisines];
	});
	
	return availableCuisineDictionaries;
}

/**
 *	Returns all of the available cuisine names.
 *
 *	@return	An array with names of each cuisine available.
 */
+ (NSArray *)availableCuisines
{
	static NSMutableArray *availableCuisines;

	if (!availableCuisines)
	{
		availableCuisines				= [[NSMutableArray alloc] init];
		for (NSDictionary *cuisineDictionary in [YummlyRequest availableCuisineDictionaries])
			[availableCuisines addObject:cuisineDictionary[kYummlyMetadataDescriptionKey]];
	}
	
	return (NSArray *)availableCuisines;
}

/**
 *	Returns all of the available diet dictionaries.
 *
 *	@return	An array of each diet dictionary available.
 */
+ (NSArray *)availableDietDictionaries
{
	static NSArray *availableDietDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableDietDictionaries		= [YummlyMetadata allMetadata][kYummlyMetadataDiets];
	});
	
	return availableDietDictionaries;
}

/**
 *	Returns all of the available diet names.
 *
 *	@return	An array with names of each diet available.
 */
+ (NSArray *)availableDiets
{
	static NSMutableArray *availableDiets;
	
	if (!availableDiets)
	{
		availableDiets					= [[NSMutableArray alloc] init];
		for (NSDictionary *dietDictionary in [YummlyRequest availableDietDictionaries])
			[availableDiets addObject:dietDictionary[kYummlyMetadataShortDescriptionKey]];
	}
	
	return (NSArray *)availableDiets;
}

/**
 *	Returns all of the available holiday dictionaries.
 *
 *	@return	An array of each holiday dictionary available.
 */
+ (NSArray *)availableHolidayDictionaries
{
	static NSArray *availableHolidayDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableHolidayDictionaries	= [YummlyMetadata allMetadata][kYummlyMetadataHolidays];
	});
	
	return availableHolidayDictionaries;
}

/**
 *	Returns all of the available holiday names.
 *
 *	@return	An array with names of each holiday available.
 */
+ (NSArray *)availableHolidays
{
	static NSMutableArray *availableHolidays;

	if (!availableHolidays)
	{
		availableHolidays				= [[NSMutableArray alloc] init];
		for (NSDictionary *holidayDictionary in [YummlyRequest availableHolidayDictionaries])
			[availableHolidays addObject:holidayDictionary[kYummlyMetadataDescriptionKey]];
	}
	
	return (NSArray *)availableHolidays;
}

/**
 *	Returns all of the available ingredient dictionaries.
 *
 *	@return	An array of each holiday ingredient available.
 */
+ (NSArray *)availableIngredientDictionaries
{
	static NSArray *availableIngredientDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableIngredientDictionaries	= [YummlyMetadata allMetadata][kYummlyMetadataIngredients];
	});
	
	return availableIngredientDictionaries;
}

/**
 *	Returns all of the available ingredient names.
 *
 *	@return	An array with names of each ingredient available.
 */
+ (NSArray *)availableIngredients
{
	static NSMutableArray *availableIngredients;
	
	if (!availableIngredients)
	{
		availableIngredients			= [[NSMutableArray alloc] init];
		for (NSDictionary *ingredientDictionary in [YummlyRequest availableIngredientDictionaries])
			[availableIngredients addObject:ingredientDictionary[kYummlyMetadataDescriptionKey]];
	}
	
	return (NSArray *)availableIngredients;
}

#pragma mark - Setter & Getter Methods 

/**
 *	The valid flavours to specify for a request.
 *
 *	@return	An array of keys that can be used when specifying a flavour.
 */
+ (NSArray *)flavourKeys
{
	return @[kYummlyFlavourBitter, kYummlyFlavourMeaty, kYummlyFlavourPiquant, kYummlyFlavourSalty, kYummlyFlavourSour, kYummlyFlavourSweet];
}

/**
 *	The getter for the number of results to ask for in the fetch.
 *
 *	@return	The amount of results returned in a request.
 */
- (NSUInteger)numberOfResults
{
	if (!_numberOfResults)
		_numberOfResults				= 40;
	
	return _numberOfResults;
}

/**
 *	The valid ranges for requests.
 *
 *	@return	An array of keys representing the ranges available to be specified.
 */
+ (NSArray *)rangeKeys
{
	return @[kYummlyMaximumKey, kYummlyMinimumKey];
}

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
{
	//	check the given flavours and range are valid
	if (![[YummlyRequest flavourKeys] containsObject:flavourKey] ||
		![[YummlyRequest rangeKeys] containsObject:rangeKey] ||
		flavourValue > 1.0f)
		return;
	
	//	alter the flavour dictionary
	NSMutableDictionary *rangeValues	= [self.flavourDictionary[flavourKey] mutableCopy];
	if (!rangeValues) rangeValues		= [[NSMutableDictionary alloc] init];
	rangeValues[rangeKey]				= @(flavourValue);
	self.flavourDictionary[flavourKey]	= rangeValues;

}

#pragma mark - Utility Methods

/**
 *	Executes this request with all the parameters defined in it.
 *
 *	@param	searchRecipesCallCompleted	The completion handler to call with the results of the request.
 */
- (void)executeSearchRecipesCallWithCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted
{
	self.startIndexForResults			= 0;
	[YummlyAPI asynchronousSearchRecipesCallWithParameters:[self getAsSearchParameters] andCompletionHandler:searchRecipesCallCompleted];
}

/**
 *	Returns this yummly request objects as the search parameters needed for a request.
 *
 *	@return	A string of search parameters to be used in a URL for Yummly.
 */
- (NSString *)getAsSearchParameters
{	
	NSMutableString *searchParameters	= [[NSMutableString alloc] init];
	
	for (NSString *desiredCourse in self.desiredCourses)
		for (NSDictionary *courseDictionary in [YummlyRequest availableCourseDictionaries])
			if ([courseDictionary[kYummlyMetadataDescriptionKey] isEqualToString:desiredCourse])
				[searchParameters appendFormat:@"allowedCourse[]=%@&", courseDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *desiredCuisine in self.desiredCuisines)
		for (NSDictionary *cuisineDictionary in [YummlyRequest availableCuisineDictionaries])
			if ([cuisineDictionary[kYummlyMetadataDescriptionKey] isEqualToString:desiredCuisine])
				[searchParameters appendFormat:@"allowedCuisine[]=%@&", cuisineDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *desiredHoliday in self.desiredHolidays)
		for (NSDictionary *holidayDictionary in [YummlyRequest availableHolidayDictionaries])
			if ([holidayDictionary[kYummlyMetadataDescriptionKey] isEqualToString:desiredHoliday])
				[searchParameters appendFormat:@"allowedHoliday[]=%@&", holidayDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *desiredIngredient in self.desiredIngredients)
		for (NSDictionary *ingredientDictionary in [YummlyRequest availableIngredientDictionaries])
			if ([ingredientDictionary[kYummlyMetadataDescriptionKey] isEqualToString:desiredIngredient])
				[searchParameters appendFormat:@"allowedIngredient[]=%@&", ingredientDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *excludedCourse in self.excludedCourses)
		for (NSDictionary *courseDictionary in [YummlyRequest availableCourseDictionaries])
			if ([courseDictionary[kYummlyMetadataDescriptionKey] isEqualToString:excludedCourse])
				[searchParameters appendFormat:@"excludedCourse[]=%@&", courseDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *excludedCuisine in self.excludedCuisines)
		for (NSDictionary *cuisineDictionary in [YummlyRequest availableCuisineDictionaries])
			if ([cuisineDictionary[kYummlyMetadataDescriptionKey] isEqualToString:excludedCuisine])
				[searchParameters appendFormat:@"excludedCuisine[]=%@&", cuisineDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *excludedHoliday in self.excludedHolidays)
		for (NSDictionary *holidayDictionary in [YummlyRequest availableHolidayDictionaries])
			if ([holidayDictionary[kYummlyMetadataDescriptionKey] isEqualToString:excludedHoliday])
				[searchParameters appendFormat:@"excludedHoliday[]=%@&", holidayDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *excludedIngredient in self.excludedIngredients)
		for (NSDictionary *ingredientDictionary in [YummlyRequest availableIngredientDictionaries])
			if ([ingredientDictionary[kYummlyMetadataDescriptionKey] isEqualToString:excludedIngredient])
				[searchParameters appendFormat:@"excludedIngredient[]=%@&", ingredientDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *requiredAllergy in self.requiredAllergies)
		for (NSDictionary *allergyDictionary in [YummlyRequest availableAllergyDictionaries])
			if ([allergyDictionary[kYummlyMetadataShortDescriptionKey] isEqualToString:requiredAllergy])
				[searchParameters appendFormat:@"allowedAllergy[]=%@&", allergyDictionary[kYummlyMetadataSearchValueKey]];
	
	for (NSString *requiredDiet in self.requiredDiets)
		for (NSDictionary *dietDictionary in [YummlyRequest availableDietDictionaries])
			if ([dietDictionary[kYummlyMetadataShortDescriptionKey] isEqualToString:requiredDiet])
				[searchParameters appendFormat:@"allowedDiet[]=%@&", dietDictionary[kYummlyMetadataSearchValueKey]];
	
	if (self.maximumCookTime)
		[searchParameters appendFormat:@"maxTotalTimeInSeconds=%u&", self.maximumCookTime];
	if (self.numberOfResults)
		[searchParameters appendFormat:@"maxResult=%u&", self.numberOfResults];
	if (self.requirePictures)
		[searchParameters appendString:@"requirePictures=true&"];
	if (self.startIndexForResults)
		[searchParameters appendFormat:@"start=%u&", self.startIndexForResults];

	[searchParameters appendFormat:@"q=%@&", self.searchPhrase ? self.searchPhrase : @""];
	
	return searchParameters;
}

/**
 *	This should be called after results have already been fetched and the user wants more results with the same request.
 *
 *	@param	completionHandler			The block to call when the request for more results has completed.
 */
- (void)getMoreResults:(YummlyRequestCompletionBlock)completionHandler
{
	self.startIndexForResults			+= self.numberOfResults;
	[YummlyAPI asynchronousSearchRecipesCallWithParameters:[self getAsSearchParameters] andCompletionHandler:completionHandler];
}
@end