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
 *	Gets all of the available metadata from Yummly; either from their database or from or document store.
 *
 *	@return	A dictionary of the various types of metadata.
 */
+ (NSDictionary *)allMetadata
{
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		//	get the metadata from a saved plist
		metadata						= [self getMetadataPropertyListAsDictionary];
		
		//	if it's not in a plist we get it from the yummly server instead
		if (!metadata)
		{
			metadata					= [self fetchAllMetadata];
			
			[self saveMetadataDictionaryToPropertyList:metadata];
		}
	});
	
	return metadata;
}

/**
 *	Refreshes a chosen piece of metadata.
 *
 *	@param	metadataKey					The metadata to re-fetch (if nil will re-fetch all meatdata).
 */
+ (void)forceMetadataRefresh:(NSString *)metadataKey
{
	//	if the key is nil we fetch all metadata
	if (!metadataKey)
	{
		metadata						= [self fetchAllMetadata];
		return;
	}
	
	NSArray *newMetadata;
	
	//	if a valid key was passed in we fetch that specific metadata
	if ([[YummlyAPI metadataKeys] containsObject:metadataKey])
		newMetadata						= [YummlyAPI synchronousGetMetadataForKey:metadataKey];
	
	//	with the new specific metadata we add it into the dictionary
	NSMutableDictionary *mutableMetadata= [metadata mutableCopy];
	mutableMetadata[metadataKey]		= newMetadata;
	metadata							= (NSDictionary *)mutableMetadata;
}

#pragma mark - Metadata Document Management

/**
 *	Gets all of the metadata from the Yummly database synchronously.
 *
 *	@return	A dictionary of all fo the metadata available from Yummly.
 */
+ (NSDictionary *)fetchAllMetadata
{
	NSMutableDictionary *metadataDictionary	= [[NSMutableDictionary alloc] init];
	
	//	for each piece of metadata 
	for (NSString *metadataKey in [YummlyAPI metadataKeys])
		metadataDictionary[metadataKey]	= [YummlyAPI synchronousGetMetadataForKey:metadataKey];
	
	return (NSDictionary *)metadataDictionary;
}

/**
 *	Gets the metadata from a saved plist.
 *
 *	@return	A dictionary of all metadata or nil if there is no plist.
 */
+ (NSDictionary *)getMetadataPropertyListAsDictionary
{
	if (![self.fileManager fileExistsAtPath:self.metadataPath])
		return nil;
	else
		return [NSDictionary dictionaryWithContentsOfFile:self.metadataPath];
}

/**
 *	Saves the passed in metadata dictionary as a property list.
 *
 *	@param	metadata					The dictionary to write to a file.
 */
+ (void)saveMetadataDictionaryToPropertyList:(NSDictionary *)metadataDictionary
{
	[metadataDictionary writeToFile:self.metadataPath atomically:YES];
}

#pragma mark - Convenience Methods

/**
 *	The document directory to save app-specific documents into.
 *
 *	@return	The document directory available to this app.
 */
+ (NSString *)documentDirectory
{
	static NSString *documentDirectory;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken,
	^{
		//	there is only one document directory so we get an array of them and use the only object in the array
		NSArray *directories			= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentDirectory				= directories[0];
	});
	
	return documentDirectory;
}

/**
 *	Returns a file manager object for handling documents.
 *
 *	@return	The file manager to be used when handling the saving and loading of metadata.
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
 *	Returns a fully constrcuted path within the document directory to save metadata to.
 *
 *	@return	A string detailing the path to save metadata in.
 */
+ (NSString *)metadataPath
{
	return [self.documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", kYummlyMetadataDictionary]];
}

@end