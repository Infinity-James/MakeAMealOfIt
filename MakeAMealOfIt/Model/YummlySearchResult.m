//
//  YummlySearchResult.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlySearchResult.h"

#pragma mark - Constants & Static Variables: Yummly Request Custom Result Keys

NSString *const kYummlyRequestResultsMetadataKey		= @"metadata";

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


@implementation YummlySearchResult {}

@end