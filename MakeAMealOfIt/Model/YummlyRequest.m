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
 *	adds a course specification that the returned recipes need to include
 *
 *	@param	desiredCourse				the course that the user wants the recipes to be
 */
- (void)addDesiredCourse:(NSString *)desiredCourse
{
	//	only add the course if it is not nil, has not yet been added, and is a valid course
	if (desiredCourse && ![self.desiredCourses containsObject:desiredCourse] &&
		[[YummlyRequest availableCourses] containsObject:desiredCourse])
		[self.desiredCourses addObject:desiredCourse];
}

/**
 *	adds a cuisine type that returned recipes need to include
 *
 *	@param	desiredCuisine				the type of cuisine the user would like
 */
- (void)addDesiredCuisine:(NSString *)desiredCuisine
{
	if (desiredCuisine && ![self.desiredCuisines containsObject:desiredCuisine] &&
		[[YummlyRequest availableCuisines] containsObject:desiredCuisine])
		[self.desiredCuisines addObject:desiredCuisine];
}

/**
 *	adds a holiday that the meal needs to be related to
 *
 *	@param	desiredHoliday				the type of holiday that the user is interested in
 */
- (void)addDesiredHoliday:(NSString *)desiredHoliday
{
	if (desiredHoliday && ![self.desiredHolidays containsObject:desiredHoliday] &&
		[[YummlyRequest availableHolidays] containsObject:desiredHoliday])
		[self.desiredHolidays addObject:desiredHoliday];
}

/**
 *	adds an ingredient the user wanted the recipes to include
 *
 *	@param	desiredIngredient			the ingredient the user wants the meal to include
 */
- (void)addDesiredIngredient:(NSString *)desiredIngredient
{
	if (desiredIngredient && ![self.desiredIngredients containsObject:desiredIngredient] &&
		[[YummlyRequest availableIngredients] containsObject:desiredIngredient])
		[self.desiredIngredients addObject:desiredIngredient];
}

#pragma mark - Adding Exclusions

/**
 *	adds a course to exclude from recipe return results
 *
 *	@param	excludedCourse				a course type that the user doesn't want the meal to be
 */
- (void)addExcludedCourse:(NSString *)excludedCourse
{
	if (excludedCourse && ![self.excludedCourses containsObject:excludedCourse] &&
		[[YummlyRequest availableCourses] containsObject:excludedCourse])
		[self.excludedCourses addObject:excludedCourse];
}

/**
 *	adds a cuisine that the recipes should not include
 *
 *	@param	excludedCuisine				the cuisine type to not exclude from results
 */
- (void)addExcludedCuisine:(NSString *)excludedCuisine
{
	if (excludedCuisine && ![self.excludedCuisines containsObject:excludedCuisine] &&
		[[YummlyRequest availableCuisines] containsObject:excludedCuisine])
		[self.excludedCuisines addObject:excludedCuisine];
}

/**
 *	adds a holiday meal type to exclude from results
 *
 *	@param	excludedHoliday				the holiday to exclude from recipe results	
 */
- (void)addExcludedHoliday:(NSString *)excludedHoliday
{
	if (excludedHoliday && ![self.excludedHolidays containsObject:excludedHoliday] &&
		[[YummlyRequest availableHolidays] containsObject:excludedHoliday])
	[	self.excludedHolidays addObject:excludedHoliday];
}

/**
 *	adds an ingredient that if any meals include we should not receive them in results
 *
 *	@param	excludedIngredient			an ingredient to exclude
 */
- (void)addExcludedIngredient:(NSString *)excludedIngredient
{
	if (excludedIngredient && ![self.excludedIngredients containsObject:excludedIngredient] &&
		[[YummlyRequest availableIngredients] containsObject:excludedIngredient])
		[self.excludedIngredients addObject:excludedIngredient];
}

#pragma mark - Adding Requirements

/**
 *	adds an allergy type that a returned recipe must conform to
 *
 *	@param	requiredAllergy				the allergy that recipes should conform to
 */
- (void)addRequiredAllergy:(NSString *)requiredAllergy
{
	if (requiredAllergy && ![self.requiredAllergies containsObject:requiredAllergy] &&
		[[YummlyRequest availableAllergies] containsObject:requiredAllergy])
		[self.requiredAllergies addObject:requiredAllergy];
}

/**
 *	adds a diet type (like vegetarian) that recipes need to be
 *
 *	@param	requiredDiet				the recipes need to be okay for this diet
 */
- (void)addRequiredDiet:(NSString *)requiredDiet
{
	if (requiredDiet && ![self.requiredDiets containsObject:requiredDiet] &&
		[[YummlyRequest availableDiets] containsObject:requiredDiet])
		[self.requiredDiets addObject:requiredDiet];
}

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
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
 *	initialises all the arrays
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
 *	receive this messsage message when the value at the specified key path relative to the given object has changed
 *
 *	@param	keyPath						key path, relative to object, to the value that has changed
 *	@param	object						source object of the key path
 *	@param	change						dictionary that describing changes made to the value of the property at the key path
 *	@param	context						value provided when receiver registered to receive key-value observation notifications
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationYummlyRequestChanged object:nil];
}

#pragma mark - Remove Desires

/**
 *	removes a previously added course specification that the returned recipes needed to include
 *
 *	@param	desiredCourse				the course that the user wants the recipes to be
 */
- (void)removeDesiredCourse:(NSString *)desiredCourse
{
	if (!desiredCourse)					return;
	[self.desiredCourses removeObject:desiredCourse];
}

/**
 *	removes a previously added a cuisine type that returned recipes needed to include
 *
 *	@param	desiredCuisine				the type of cuisine the user would like
 */
- (void)removeDesiredCuisine:(NSString *)desiredCuisine
{
	if (!desiredCuisine)				return;
	[self.desiredCuisines removeObject:desiredCuisine];
}

/**
 *	removes a previously added holiday that the meal needed to be related to
 *
 *	@param	desiredHoliday				the type of holiday that the user is interested in
 */
- (void)removeDesiredHoliday:(NSString *)desiredHolday
{
	if (!desiredHolday)					return;
	[self.desiredHolidays removeObject:desiredHolday];
}

/**
 *	removes a previously added ingredient the user wanted the recipes to include
 *
 *	@param	desiredIngredient			the ingredient the user wants the meal to include
 */
- (void)removeDesiredIngredient:(NSString *)desiredIngredient
{
	if (!desiredIngredient)				return;
	[self.desiredIngredients removeObject:desiredIngredient];
}

#pragma mark - Remove Exclusions

/**
 *	removes a previously added course that was supposed to be excluded from recipe return results
 *
 *	@param	excludedCourse				a course type that the user doesn't want the meal to be
 */
- (void)removeExcludedCourse:(NSString *)excludedCourse
{
	if (!excludedCourse)				return;
	[self.excludedCourses removeObject:excludedCourse];
}

/**
 *	removes a previously added cuisine that the recipes should not have included
 *
 *	@param	excludedCuisine				the cuisine type to not exclude from results
 */
- (void)removeExcludedCuisine:(NSString *)excludedCuisine
{
	if (!excludedCuisine)				return;
	[self.excludedCuisines removeObject:excludedCuisine];
}

/**
 *	removes a previously added holiday meal type that was to be excluded from results
 *
 *	@param	excludedHoliday				the holiday to exclude from recipe results
 */
- (void)removeExcludedHoliday:(NSString *)excludedHoliday
{
	if (!excludedHoliday)				return;
	[self.excludedHolidays removeObject:excludedHoliday];
}

/**
 *	removes a previously added ingredient that if any meals included we should not have received them in results
 *
 *	@param	excludedIngredient			an ingredient to exclude
 */
- (void)removeExcludedIngredient:(NSString *)excludedIngredient
{
	if (!excludedIngredient)			return;
	[self.excludedIngredients removeObject:excludedIngredient];
}

#pragma mark - Remove Requirements

/**
 *	removes a previously added allergy type that a returned recipe must have conformed to
 *
 *	@param	requiredAllergy				the allergy that recipes should conform to
 */
- (void)removeRequiredAllergy:(NSString *)requiredAllergy
{
	if (!requiredAllergy)				return;
	[self.requiredAllergies removeObject:requiredAllergy];
}

/**
 *	removes a previously added diet type (like vegetarian) that recipes needed to be
 *
 *	@param	requiredDiet				the recipes need to be okay for this diet
 */
- (void)removeRequiredDiet:(NSString *)requiredDiet
{
	if (!requiredDiet)					return;
	[self.requiredDiets removeObject:requiredDiet];
}

#pragma mark - Available Metadata Methods

/**
 *	returns all of the available allergies names
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
 *	returns all of the available allergy dictionaries
 */
+ (NSArray *)availableAllergyDictionaries
{
	static NSArray *availableAllergyDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableAllergyDictionaries	= [YummlyAPI synchronousGetMetadataForKey:kYummlyMetadataAllergies];
	});
	
	return availableAllergyDictionaries;
}

/**
 *	returns all of the available course dictionaries
 */
+ (NSArray *)availableCourseDictionaries
{
	static NSArray *availableCourseDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableCourseDictionaries		= [YummlyAPI synchronousGetMetadataForKey:kYummlyMetadataCourses];
	});
	
	return availableCourseDictionaries;
}

/**
 *	returns all of the available courses names
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
 *	returns all of the available cuisine dictionaries
 */
+ (NSArray *)availableCuisineDictionaries
{
	static NSArray *availableCuisineDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableCuisineDictionaries		= [YummlyAPI synchronousGetMetadataForKey:kYummlyMetadataCuisines];
	});
	
	return availableCuisineDictionaries;
}

/**
 *	returns all of the available cuisines names
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
 *	returns all of the available diet dictionaries
 */
+ (NSArray *)availableDietDictionaries
{
	static NSArray *availableDietDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableDietDictionaries		= [YummlyAPI synchronousGetMetadataForKey:kYummlyMetadataDiets];
	});
	
	return availableDietDictionaries;
}

/**
 *	returns all of the available diets names
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
 *	returns all of the available holiday dictionaries
 */
+ (NSArray *)availableHolidayDictionaries
{
	static NSArray *availableHolidayDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableHolidayDictionaries	= [YummlyAPI synchronousGetMetadataForKey:kYummlyMetadataHolidays];
	});
	
	return availableHolidayDictionaries;
}

/**
 *	returns all of the available holiday names
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
 *	returns all of the available ingredient dictionaries
 */
+ (NSArray *)availableIngredientDictionaries
{
	static NSArray *availableIngredientDictionaries;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		availableIngredientDictionaries	= [YummlyAPI synchronousGetMetadataForKey:kYummlyMetadataIngredients];
	});
	
	return availableIngredientDictionaries;
}

/**
 *	returns all of the available ingredients names
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
 *	the valid flavours to specify for a request
 */
+ (NSArray *)flavourKeys
{
	return @[kYummlyFlavourBitter, kYummlyFlavourMeaty, kYummlyFlavourPiquant, kYummlyFlavourSalty, kYummlyFlavourSour, kYummlyFlavourSweet];
}

/**
 *	the valid ranges for requests
 */
+ (NSArray *)rangeKeys
{
	return @[kYummlyMaximumKey, kYummlyMinimumKey];
}

/**
 *	sets a value for a given flavour and at the given range extreme (min or max)
 *
 *	@param	flavourValue				the value from 0 to 1 for the flavour
 *	@param	flavourKey					the flavour to apply the value to
 *	@param	rangeKey					whether the value is the minimum or maximum for the flavour
 */
- (void)setFlavourValue:(CGFloat)flavourValue
				 forKey:(NSString *)flavourKey
				atRange:(NSString *)rangeKey;
{
	if (![[YummlyRequest flavourKeys] containsObject:flavourKey] ||
		![[YummlyRequest rangeKeys] containsObject:rangeKey] ||
		flavourValue > 1.0f)
		return;
	
	
	NSMutableDictionary *rangeValues	= [self.flavourDictionary[flavourKey] mutableCopy];
	if (!rangeValues) rangeValues		= [[NSMutableDictionary alloc] init];
	rangeValues[rangeKey]				= @(flavourValue);
	self.flavourDictionary[flavourKey]	= rangeValues;

}

#pragma mark - Utility Methods

/**
 *
 *
 *	@param
 */
- (void)executeSearchRecipesCallWithCompletionHandler:(YummlyRequestCompletionBlock)searchRecipesCallCompleted
{
	[YummlyAPI asynchronousSearchRecipesCallWithParameters:[self getAsSearchParameters] andCompletionHandler:searchRecipesCallCompleted];
}

/**
 *	returns this yummly request objects as the search parameters needed for a request
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
		[searchParameters appendFormat:@"start=%u", self.startIndexForResults];

	[searchParameters appendFormat:@"q=%@&", self.searchPhrase ? self.searchPhrase : @""];
	
	return searchParameters;
}

@end