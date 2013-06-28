//
//  YummlyMetadata.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 27/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Constants & Static Variables: Yummly Metadata Result Keys

extern NSString *const kYummlyMetadataDescriptionKey;
extern NSString *const kYummlyMetadataIDKey;
extern NSString *const kYummlyMetadataLongDescriptionKey;
extern NSString *const kYummlyMetadataSearchValueKey;
extern NSString *const kYummlyMetadataShortDescriptionKey;
extern NSString *const kYummlyMetadataTermKey;
extern NSString *const kYummlyMetadataTypeKey;

#pragma mark - Constants & Static Variables: Yummly Metadata Request Keys

extern NSString *const kYummlyMetadataAllergies;
extern NSString *const kYummlyMetadataCourses;
extern NSString *const kYummlyMetadataCuisines;
extern NSString *const kYummlyMetadataDiets;
extern NSString *const kYummlyMetadataHolidays;
extern NSString *const kYummlyMetadataIngredients;

#pragma mark - Yummly Metadata Public Interface

@interface YummlyMetadata : NSObject

#pragma mark - Public Properties

/**
 *	Gets all of the available metadata from Yummly; either from their database or from or document store.
 *
 *	@return	A dictionary of the various types of metadata.
 */
+ (NSDictionary *)allMetadata;
/**
 *	Called to find whether a kind of metadata can be excluded from search results.
 *
 *	@param	metadataKey				A constant string for the type of metadata.
 *
 *	@return	YES if the metadata can be excluded from Yummly recipe searches, NO otherwsie.
 */
+ (BOOL)canMetadataBeExcluded:(NSString *)metadataKey;
/**
 *	Refreshes a chosen piece of metadata.
 *
 *	@param	metadataKey					The metadata to re-fetch (if nil will re-fetch all meatdata).
 */
+ (void)forceMetadataRefresh:(NSString *)metadataKey;

@end