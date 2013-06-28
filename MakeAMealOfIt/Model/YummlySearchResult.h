//
//  YummlySearchResult.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Constants & Static Variables: Yummly Request Custom Result Keys

extern NSString *const kYummlyRequestResultsMetadataKey;

#pragma mark - Constants & Static Variables: Yummly Metadata Request Keys

extern NSString *const kYummlyMetadataAllergies;
extern NSString *const kYummlyMetadataCourses;
extern NSString *const kYummlyMetadataCuisines;
extern NSString *const kYummlyMetadataDiets;
extern NSString *const kYummlyMetadataHolidays;
extern NSString *const kYummlyMetadataIngredients;

#pragma mark - Constants & Static Variables: Yummly Search Recipe Keys

extern NSString *const kYummlyAttributionDictionaryKey;
extern NSString *const kYummlyAttributionHTMLKey;
extern NSString *const kYummlyAttributionLogoKey;
extern NSString *const kYummlyAttributionTextKey;
extern NSString *const kYummlyAttributionURLKey;

extern NSString *const kYummlyCriteriaDictionaryKey;

extern NSString *const kYummlyFacetCountsDictionaryKey;

extern NSString *const kYummlyMatchesArrayKey;
extern NSString *const kYummlyMatchAttributesKey;
extern NSString *const kYummlyMatchFlavoursKey;
extern NSString *const kYummlyMatchIDKey;
extern NSString *const kYummlyMatchIngredientsArrayKey;
extern NSString *const kYummlyMatchRatingKey;
extern NSString *const kYummlyMatchRecipeNameKey;
extern NSString *const kYummlyMatchSmallImageURLsArrayKey;
extern NSString *const kYummlyMatchSourceDisplayNameKey;
extern NSString *const kYummlyMatchTimeToMakeKey;

extern NSString *const kYummlyTotalMatchCountKey;

#pragma mark - Yummly Search Result Public Interface

@interface YummlySearchResult : NSObject {}

@end