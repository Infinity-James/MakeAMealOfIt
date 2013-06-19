//
//  YummlyMetadata.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 27/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAPI.h"

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
 *	Refreshes a chosen piece of metadata.
 *
 *	@param	metadataKey					The metadata to re-fetch (if nil will re-fetch all meatdata).
 */
+ (void)forceMetadataRefresh:(NSString *)metadataKey;

@end