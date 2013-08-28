//
//  ArrayDataSource.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ArrayDataSource.h"

#pragma mark - Array Data Source Private Class Extension

@interface ArrayDataSource () {}

#pragma mark - Private Properties

/**	The unique identifier to be used for reusing cells.	*/
@property (nonatomic, copy)		NSString					*cellIdentifier;
/**	A block to be used when configuring a cell with a given item.	*/
@property (nonatomic, copy)		TableViewCellConfigureBlock	configureCellBlock;
/**	The array of items to be used as the data source.	*/
@property (nonatomic, strong)	NSArray						*items;

@end

#pragma mark - Array Data Source Implementation

@implementation ArrayDataSource {}

#pragma mark - Array Handling

/**
 *	Updates this array data source with recently edited items.
 *
 *	@param	items						The array of items to be used as the data source.
 */
- (void)updateWithItems:(NSArray *)items
{
	self.items							= items;
}

#pragma mark - Convenience & Helper Methods

/**
 *	A convenient way to get a UICollectionViewCell's item given it's index path.
 *
 *	@param	indexPath					The index path of the cell requiring the item.
 *
 *	@return	The appropriate item for a given index path.
 */
- (id)itemForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.items[indexPath.item];
}

/**
 *	A convenient way to get a UITableViewCell's item given it's index path.
 *
 *	@param	indexPath					The index path of the cell requiring the item.
 *
 *	@return	The appropriate item for a given index path.
 */
- (id)itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.items[indexPath.row];
}

#pragma mark - Initialisation

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
		andConfigureCellBlock:(TableViewCellConfigureBlock)configureCellBlock
{
	if (self = [super init])
	{
		self.cellIdentifier				= cellIdentifier;
		self.configureCellBlock			= configureCellBlock;
		self.items						= items;
	}
	
	return self;
}

#pragma mark - UICollectionViewDataSource Methods

/**
 *	As the data source we return the cell that corresponds to the specified item in the collection view.
 *
 *	@param	collectionView				Object representing the collection view requesting this information.
 *	@param	indexPath					Index path that specifies the location of the item.
 *
 *	@return	A collection view cell appropriate for the given index path.
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell			= [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
																			 forIndexPath:indexPath];
	
	id item								= [self itemForItemAtIndexPath:indexPath];
	self.configureCellBlock(cell, item);
	
	return cell;
}

/**
 *	Asks the data source for the number of items in the specified section.
 *
 *	@param	collectionView				An object representing the collection view requesting this information.
 *	@param	section						An index number identifying a section in collectionView. This index value is 0-based.
 *
 *	@return	The number of rows in section.
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section
{
	return self.items.count;
}

#pragma mark - UITableViewDataSource Methods

/**
 *	Asks the data source for a cell to insert in a particular location of the table view.
 *
 *	@param	tableView					A table-view object requesting the cell.
 *	@param	indexPath					An index path locating a row in tableView.
 *
 *	@return	An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell				= [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
	
	id item								= [self itemForRowAtIndexPath:indexPath];
	self.configureCellBlock(cell, item);
	
	return cell;
}

/**
 *	Tells the data source to return the number of rows in a given section of a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	section						An index number identifying a section in tableView.
 *
 *	@return	The number of rows in section.
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return self.items.count;
}

@end