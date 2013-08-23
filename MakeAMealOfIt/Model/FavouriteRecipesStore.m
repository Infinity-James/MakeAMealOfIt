//
//  FavouriteRecipesStore.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 23/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "FavouriteRecipesStore.h"

#pragma mark - Constants & Static Variables

/**	The name of the favourite recipes file.	*/
static NSString *const kFavouriteRecipesFile		= @"favourite-recipes";

#pragma mark - Favourite Recipes Store Private Class Extension

@interface FavouriteRecipesStore () {}

#pragma mark - Private Properties

@end

#pragma mark - Favourite Recipes Store Implementation

@implementation FavouriteRecipesStore {}

#pragma mark - Property Accessor Methods - Getters

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
+ (NSString *)favouriteRecipesPath
{
	return [self.documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", kFavouriteRecipesFile]];
}

@end