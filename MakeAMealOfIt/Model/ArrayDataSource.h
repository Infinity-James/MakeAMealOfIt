//
//  ArrayDataSource.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Type Definitions

/**	A block to be used when configuring a cell with a given item.	*/
typedef void (^TableViewCellConfigureBlock)(id cell, id item);

#pragma mark - Array Data Source Public Interface

@interface ArrayDataSource : NSObject <UICollectionViewDataSource, UITableViewDataSource> {}

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	items						The array of items to be used as the data source.
 *	@param	cellIdentifier				The unique identifier to be used for reusing cells.
 *	@param	configureCellBlock			A block to be used when configuring a cell with a given item.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithItems:(NSArray *)items
			   cellIdentifier:(NSString *)cellIdentifier
		andConfigureCellBlock:(TableViewCellConfigureBlock)configureCellBlock;
/**
 *	A convenient way to get a UICollectionViewCell's item given it's index path.
 *
 *	@param	indexPath					The index path of the cell requiring the item.
 *
 *	@return	The appropriate item for a given index path.
 */
- (id)itemForItemAtIndexPath:(NSIndexPath *)indexPath;
/**
 *	A convenient way to get a UITableViewCell's item given it's index path.
 *
 *	@param	indexPath					The index path of the cell requiring the item.
 *
 *	@return	The appropriate item for a given index path.
 */
- (id)itemForRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 *	Updates this array data source with recently edited items.
 *
 *	@param	items						The array of items to be used as the data source.
 */
- (void)updateWithItems:(NSArray *)items;

@end