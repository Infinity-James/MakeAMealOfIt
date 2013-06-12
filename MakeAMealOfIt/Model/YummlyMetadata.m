//
//  YummlyMetadata.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 27/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyMetadata.h"

static NSDictionary *metadata;

#pragma mark - Constants & Static Variables

static NSString *const kYummlyMetadataDictionary	= @"metadata";

#pragma mark - Yummly Metadata Implementation

@implementation YummlyMetadata

#pragma mark - Metadata Access

/**
 *	returns a full metadata dictionary array
 */
+ (NSDictionary *)allMetadata
{
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		metadata						= [self getMetadataPropertyListAsDictionary];
		
		if (!metadata)
		{
			metadata					= [self fetchAllMetadata];
			
			[self saveMetadataDictionaryToPropertyList:metadata];
			
		}
	});
	
	return metadata;
}

/**
 *	refreshes a chosen piece of metadata
 *
 *	@param	metadataKey					the metadata to re-fetch (if nil will re-fetch all meatdata)
 */
+ (void)forceMetadataRefresh:(NSString *)metadataKey
{
	if (!metadataKey)
	{
		metadata						= [self fetchAllMetadata];
		return;
	}
	
	NSArray *newMetadata;
	
	if ([[YummlyAPI metadataKeys] containsObject:metadataKey])
		newMetadata						= [YummlyAPI synchronousGetMetadataForKey:metadataKey];
	
	
	NSMutableDictionary *mutableMetadata= [metadata mutableCopy];
	mutableMetadata[metadataKey]		= newMetadata;
	metadata							= (NSDictionary *)mutableMetadata;
}

#pragma mark - Metadata Document Management

/**
 *	gets all of the metadata from the yummly database
 */
+ (NSDictionary *)fetchAllMetadata
{
	NSMutableDictionary *metadataDictionary	= [[NSMutableDictionary alloc] init];
	
	for (NSString *metadataKey in [YummlyAPI metadataKeys])
		metadataDictionary[metadataKey]	= [YummlyAPI synchronousGetMetadataForKey:metadataKey];
	
	return (NSDictionary *)metadataDictionary;
}

/**
 *	returns the saved metadata property list as a dictionary
 */
+ (NSDictionary *)getMetadataPropertyListAsDictionary
{
	if (![self.fileManager fileExistsAtPath:self.metadataPath])
		return nil;
	else
		return [NSDictionary dictionaryWithContentsOfFile:self.metadataPath];
}

/**
 *	saves the passed in metadata dictionary as a property list
 *
 *	@param	metadata					the dictionary to write to a file
 */
+ (void)saveMetadataDictionaryToPropertyList:(NSDictionary *)metadataDictionary
{
	[metadataDictionary writeToFile:self.metadataPath atomically:YES];
}

#pragma mark - Convenience Methods

/**
 *	returns the document directory for convenience
 */
+ (NSString *)documentDirectory
{
	static NSString *documentDirectory;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		NSArray *directories			= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentDirectory				= directories[0];
	});
	
	return documentDirectory;
}

/**
 *	returns a nsfilemanager object for handling documents
 */
+ (NSFileManager *)fileManager
{
	static NSFileManager *fileManager;
	static dispatch_once_t once;
	
	dispatch_once(&once,
	^{
		fileManager					= [[NSFileManager alloc] init];
	});
	
	return fileManager;
}

/**
 *	returns the path of the metadata plist
 */
+ (NSString *)metadataPath
{
	return [self.documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", kYummlyMetadataDictionary]];
}

@end