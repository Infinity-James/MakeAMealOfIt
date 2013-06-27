//
//  RecipeSearchParametersViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 20/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIRightViewController.h"

#pragma mark - Type Definitions

typedef void(^MetadataNeedsRemoving)(NSString *metadata, NSString *metadataType, BOOL included);

#pragma mark - SelectedSearchParametersDelegate Protocol

@protocol SelectedSearchParametersDelegate <NSObject>

#pragma mark - Optional Methods

@optional

/**
 *	Passes a block to the delegate to allow the removing of pieces of metadata.
 *
 *	@param	removeMetadata				A block that the delegate needs to call with the piece of metadata to remove from search.
 */
- (void)blockToCallToRemoveMetadata:(MetadataNeedsRemoving)removeMetadata;

#pragma mark - Required Methods

@required

/**
 *	Sent to the delegate when a piece of metadata has been excluded from the search.
 *
 *	@param	metadata					The piece of metadata being used to narrow the Yummly search.
 *	@param	metadataType				The type of the metadata that was excluded.
 *
 *	@return	YES if the metadata was added to the table view, NO otherwise.
 */
- (BOOL)metadataExcluded:(NSString *)metadata
				  ofType:(NSString *)metadataType;
/**
 *	Sent to the delegate when a piece of metadata has been included in the search.
 *
 *	@param	metadata					The piece of metadata being used to narrow the Yummly search.
 *	@param	metadataType				The type of the metadata that was included.
 *
 *	@return	YES if the metadata was added to the table view, NO otherwise.
 */
- (BOOL)metadataIncluded:(NSString *)metadata
				  ofType:(NSString *)metadataType;

@end

#pragma mark - Recipe Search Parameters VC Public Interface

@interface RecipeSearchParametersViewController : UIRightViewController {}

#pragma mark - Public Properties

/**	The delegate interested in finding out what was added to the Yummly search.	*/
@property (nonatomic, weak)	id <SelectedSearchParametersDelegate>	delegate;

@end