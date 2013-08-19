	
//
//  ExtraOptionsViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 22/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ExtraOptionsViewController.h"
#import "MetadataCell.h"
#import "RecipeSearchParametersViewController.h"
#import "YummlyMetadata.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier				= @"OptionsCellIdentifier";
static NSString *const kHeaderIdentifier			= @"HeaderViewIdentifier";
static CGFloat const kParametersControllerHeight	= 340.0f;

#pragma mark - Extra Options View Controller Private Class Extension

@interface ExtraOptionsViewController () <SelectedSearchParametersDelegate, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	A dictionary of excluded parameters with the parameters name and it's type.	*/
@property (nonatomic, strong)	NSMutableDictionary						*excludedParameters;
/**	A dictionary of included parameters with the parameters name and it's type.	*/
@property (nonatomic, strong)	NSMutableDictionary						*includedParameters;
/**	A comparator to be used when sorting metadata dictionaries.	*/
@property (nonatomic, assign)	NSComparator							metadataDictionaryComparator;
/**	This view controller represents parameters to choose from for recipe searches.	*/
@property (nonatomic, strong)	RecipeSearchParametersViewController	*recipeParametersController;
/**	A block to call with metadata that needs to be removed from the search.	*/
@property (nonatomic, copy)		MetadataNeedsRemoving					removeMetadata;
/**	The index path of the currently selected UITableViewCell.	*/
@property (nonatomic, strong)	NSIndexPath								*selectedCellIndexPath;
/**	This table view will be used to show the user the selected options.	*/
@property (nonatomic, strong)	UITableView								*tableView;

@end

#pragma mark - Extra Options View Controller Implementation

@implementation ExtraOptionsViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the global Yummly Request object has been reset.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
	dispatch_async(dispatch_queue_create("Table Clearer", NULL),
	^{
		[self.excludedParameters removeAllObjects];
		[self.includedParameters removeAllObjects];
		
		NSMutableArray *indexPaths			= [[NSMutableArray alloc] init];
		
		NSUInteger rowCount					= [self.tableView numberOfRowsInSection:0];
		
		for (NSUInteger index = 0; index < rowCount; index++)
			[indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
		
		rowCount							= [self.tableView numberOfRowsInSection:1];
		
		for (NSUInteger index = 0; index < rowCount; index++)
			[indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:1]];
		
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
		});
	});
}

#pragma mark - Autolayout Methods

/**
 *	Called when the view controller’s view needs to update its constraints.
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	NSArray *constraints;
	
	//	add the table view to the top of the view and the parameters view to the bottom
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Panel)-[tableView]|"
																options:kNilOptions
																metrics:@{@"Panel": @(kPanelWidth)}
																  views:self.viewsDictionary];
	
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(PanelPlus)-[recipeParameters]-|"
																options:kNilOptions
																metrics:@{@"PanelPlus": @(kPanelWidth + 20)}
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[recipeParameters(==Height)]|"
																options:kNilOptions
																metrics:@{	@"Height"	: @(kParametersControllerHeight)}
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Autorotation

/**
 *	Returns a Boolean value indicating whether rotation methods are forwarded to child view controllers.
 *
 *	@return	YES if rotation methods are forwarded or NO if they are not.
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	Returns whether the view controller’s contents should auto rotate.
 *
 *	@return	YES if the content should rotate, otherwise NO.
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

#pragma mark - Convenience & Helper Methods

/**
 *	Adds metadata to a passed in dictionary under a certain metadata type (key).
 *
 *	@param	metadata					The metadata to add to the dictionary.
 *	@param	metadataType				Used as a key under which to add the metadata.
 *	@param	metadataDictionary			The dictionary to add the metadata to.
 *
 *	@return	YES if the piece of metadata was successfully added, and NO otherwise.
 */
- (BOOL)addMetadata:(NSString *)metadata
			 ofType:(NSString *)metadataType
	   toDictionary:(NSMutableDictionary *)metadataDictionary
{
	//	gets any existing excluded metadata of this type in this dictionary
	NSMutableOrderedSet *existingMetadata	= [[NSMutableOrderedSet alloc] initWithArray:metadataDictionary[metadataType]];
	
	//	if there is no metadata of this type yet we make an empty array
	if (!existingMetadata)
		existingMetadata				= [[NSMutableOrderedSet alloc] init];
	
	//	if the set metadata already contains the metadata we cannot add it
	else if ([existingMetadata containsObject:metadata])
		return NO;
		
	//	we add this new metadata dictionary to the array for this type if it is not already in there
	[existingMetadata addObject:metadata];
	
	//	we sort the array alphabetically by the description before adding it back to the dictionary
	NSArray *newMetadata				= [existingMetadata sortedArrayUsingComparator:^NSComparisonResult(NSString *metadataA, NSString *metadataB)
	{
		return [metadataA compare:metadataB];
	}];
	
	metadataDictionary[metadataType]	= newMetadata;
	
	return YES;
}

/**
 *	A convenient way to find whether a piece of metadata is an a certain dictionary or not.
 *
 *	@param	metadata					The metadata to add to the dictionary.
 *	@param	metadataType				Used as a key under which to add the metadata.
 *	@param	metadataDictionary			The dictionary to add the metadata to.
 *
 *	@return	YES is the metadata was already in the dictionary, and NO if not.
 */
- (BOOL)checkIfMetadata:(NSString *)metadata
				 ofType:(NSString *)metadataType
		 isInDictionary:(NSDictionary *)metadataDictionary
{
	//	gets any existing metadata of the type passed in
	NSOrderedSet *existingMetadata		= [[NSOrderedSet alloc] initWithArray:metadataDictionary[metadataType]];
	
	//	if there is nothing in the set, obviously the metadata can't be there
	if (existingMetadata.count == 0)	return NO;
	
	//	if the metadata is in the set, we return YES
	if ([existingMetadata containsObject:metadata])
		return YES;
	
	//	if it was not in the set, we return NO
	return NO;
}

/**
 *	Inserts a given index path into the table view in an animated way.
 *
 *	@param	indexPath					The index path identifying the row to insert and which section to insert it into.
 */
- (void)insertIndexPath:(NSIndexPath *)indexPath
{
	self.selectedCellIndexPath			= nil;
	[self.tableView setEditing:NO animated:YES];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

/**
 *	A convenient way to get the metadata description of a piece of metadata at a certain index path.
 *
 *	@param	indexPath					The index path of the piece of metadata wanting it's type.
 *
 *	@return	The metadata description for a piece of metadata at the given index path, or nil if not valid.
 */
- (NSString *)metadataForItemAtIndexPath:(NSIndexPath *)indexPath
{	
	if (indexPath.section == 0)
		return self.allExcludedMetadata[indexPath.row];
	else if (indexPath.section == 1)
		return self.allIncludedMetadata[indexPath.row];
	
	return nil;
}

/**
 *	A convenient way to get the metadata type of a piece of metadata at a certain index path.
 *
 *	@param	indexPath					The index path of the piece of metadata wanting it's type.
 *
 *	@return	The metadata type of a piece of metadata at the given index path, or nil if not valid.
 */
- (NSString *)metadataTypeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger count					= 0;
	NSUInteger requestedItemIndex		= indexPath.row;
	
	if (indexPath.section == 0)
		for (NSString *key in [self sortedKeysForDictionary:self.excludedParameters])
		{
			count						+= ((NSArray *)self.excludedParameters[key]).count;
			
			if (count > requestedItemIndex)
				return key;
		}
	
	else if (indexPath.section == 1)
		for (NSString *key in [self sortedKeysForDictionary:self.includedParameters])
		{
			count						+= ((NSArray *)self.includedParameters[key]).count;
			
			if (count > requestedItemIndex)
				return key;
		}
	
	return nil;
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)removeMetadata:(NSString *)metadata ofType:(NSString *)metadataType included:(BOOL)included
{
	NSMutableDictionary *parameters		= included ? self.includedParameters : self.excludedParameters;
	NSMutableArray *metadataArray		= [parameters[metadataType] mutableCopy];
	[metadataArray removeObject:metadata];
	parameters[metadataType]			= metadataArray;
}

/**
 *	Returns an array of sorted keys for a passed in dictionary.
 *
 *	@param	dictionary					The dictionary whose keys to use.
 *
 *	@return	An array of all the keys sorted alphabetically.
 */
- (NSArray *)sortedKeysForDictionary:(NSDictionary *)dictionary
{
	return [dictionary.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		//self.restorationIdentifier		= NSStringFromClass([self class]);
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yummlyRequestHasBeenReset:) name:kNotificationYummlyRequestReset object:nil];
	}
	
	return self;
}

#pragma mark - SelectedSearchParametersDelegate Methods

/**
 *	Passes a block to the delegate to allow the removing of pieces of metadata.
 *
 *	@param	removeMetadata				A block that the delegate needs to call with the piece of metadata to remove from search.
 */
- (void)blockToCallToRemoveMetadata:(MetadataNeedsRemoving)removeMetadata
{
	self.removeMetadata					= removeMetadata;
}

/**
 *	Sent to the delegate when a piece of metadata has been excluded from the search.
 *
 *	@param	metadata					The piece of metadata being used to narrow the Yummly search.
 *	@param	metadataType				The type of the metadata that was excluded.
 *
 *	@return	YES if the metadata was added to the table view, NO otherwise.
 */
- (BOOL)metadataExcluded:(NSString *)metadata
				  ofType:(NSString *)metadataType
{
	if ([self checkIfMetadata:metadata ofType:metadataType isInDictionary:self.includedParameters])
	{
		NSUInteger index					= [self.allIncludedMetadata indexOfObject:metadata];
		NSIndexPath *indexPath				= [NSIndexPath indexPathForRow:index inSection:1];
		UITableViewCell *cell				= [self.tableView cellForRowAtIndexPath:indexPath];
		[UIView animateWithDuration:0.2f
						 animations:
		 ^{
			 cell.layer.affineTransform		= CGAffineTransformScale(cell.layer.affineTransform, 1.0f, 1.4f);
		 }
						 completion:^(BOOL finished)
		 {
			 [UIView animateWithDuration:0.2f animations:
			  ^{
				  cell.layer.affineTransform	= CGAffineTransformIdentity;
			  }];
		 }];
		
		return NO;
	}
	
	if ([self addMetadata:metadata ofType:metadataType toDictionary:self.excludedParameters])
	{
		NSUInteger index					= [self.allExcludedMetadata indexOfObject:metadata];
		NSIndexPath *indexPath				= [NSIndexPath indexPathForRow:index inSection:0];
		[self performSelector:@selector(insertIndexPath:) withObject:indexPath afterDelay:0.6f];
		return YES;
	}
	
	else
	{
		NSUInteger index					= [self.allExcludedMetadata indexOfObject:metadata];
		NSIndexPath *indexPath				= [NSIndexPath indexPathForRow:index inSection:0];
		UITableViewCell *cell				= [self.tableView cellForRowAtIndexPath:indexPath];
		[UIView animateWithDuration:0.2f
						 animations:
		^{
			cell.layer.affineTransform		= CGAffineTransformScale(cell.layer.affineTransform, 1.0f, 1.4f);
		}
						 completion:^(BOOL finished)
		{
			[UIView animateWithDuration:0.2f animations:
			^{
				cell.layer.affineTransform	= CGAffineTransformIdentity;
			}];
		}];
		return NO;
	}
}

/**
 *	Sent to the delegate when a piece of metadata has been included in the search.
 *
 *	@param	metadata					The piece of metadata being used to narrow the Yummly search.
 *	@param	metadataType				The type of the metadata that was included.
 *
 *	@return	YES if the metadata was added to the table view, NO otherwise.
 */
- (BOOL)metadataIncluded:(NSString *)metadata
				  ofType:(NSString *)metadataType
{
	if ([self checkIfMetadata:metadata ofType:metadata isInDictionary:self.excludedParameters])
	{
		
		NSUInteger index					= [self.allExcludedMetadata indexOfObject:metadata];
		NSIndexPath *indexPath				= [NSIndexPath indexPathForRow:index inSection:1];
		UITableViewCell *cell				= [self.tableView cellForRowAtIndexPath:indexPath];
		[UIView animateWithDuration:0.2f
						 animations:
		 ^{
			 cell.layer.affineTransform		= CGAffineTransformScale(cell.layer.affineTransform, 1.0f, 1.4f);
		 }
						 completion:^(BOOL finished)
		 {
			 [UIView animateWithDuration:0.2f animations:
			  ^{
				  cell.layer.affineTransform	= CGAffineTransformIdentity;
			  }];
		 }];
		
		return NO;
	}
	
	if ([self addMetadata:metadata ofType:metadataType toDictionary:self.includedParameters])
	{
		NSUInteger index					= [self.allIncludedMetadata indexOfObject:metadata];
		NSIndexPath *indexPath				= [NSIndexPath indexPathForRow:index inSection:1];
		[self performSelector:@selector(insertIndexPath:) withObject:indexPath afterDelay:0.6f];
		
		return YES;
	}
	
	else
	{
		NSUInteger index					= [self.allIncludedMetadata indexOfObject:metadata];
		NSIndexPath *indexPath				= [NSIndexPath indexPathForRow:index inSection:1];
		UITableViewCell *cell				= [self.tableView cellForRowAtIndexPath:indexPath];
		[UIView animateWithDuration:0.2f
						 animations:
		 ^{
			 cell.layer.affineTransform		= CGAffineTransformScale(cell.layer.affineTransform, 1.0f, 1.4f);
		 }
						 completion:^(BOOL finished)
		 {
			 [UIView animateWithDuration:0.2f animations:
			  ^{
				  cell.layer.affineTransform	= CGAffineTransformIdentity;
			  }];
		 }];
		
		return NO;
	}
}

#pragma mark - Setter & Getter Methods

/**
 *	A convenient way to get all of the metadata in the excludedParameters dictionary.
 *
 *	@return	An array of strings for each metadata.
 */
- (NSArray *)allExcludedMetadata
{
	NSMutableArray *allMetadata			= [[NSMutableArray alloc] init];
	
	for (NSString *key in [self sortedKeysForDictionary:self.excludedParameters])
		[allMetadata addObjectsFromArray:self.excludedParameters[key]];
	
	return allMetadata;
}

/**
 *	A convenient way to get all of the metadata in the includedParameters dictionary.
 *
 *	@return	An array of strings for each metadata.
 */
- (NSArray *)allIncludedMetadata
{
	NSMutableArray *allMetadata			= [[NSMutableArray alloc] init];
	
	for (NSString *key in [self sortedKeysForDictionary:self.includedParameters])
		[allMetadata addObjectsFromArray:self.includedParameters[key]];
	
	return allMetadata;
}

/**
 *	A dictionary of excluded parameters iwht the parameters name and it's type.
 *
 *	@return	An initialised mutable dictionary to hold parameters that are to be excluded from the search.
 */
- (NSMutableDictionary *)excludedParameters
{
	if (!_excludedParameters)
		_excludedParameters				= [[NSMutableDictionary alloc] init];
	
	return _excludedParameters;
}

/**
 *	A convenient way to get the total number of metadata dictionaries in the excludedParameters array.
 *
 *	@return	The number of excluded parameters in total.
 */
- (NSUInteger)excludedParametersCount
{
	NSUInteger count					= 0;
	
	for (NSArray *metadataType in self.excludedParameters.allValues)
		count						+= metadataType.count;
	
	return count;
}

/**
 *	A dictionary of included parameters iwht the parameters name and it's type.
 *
 *	@return	An initialised mutable dictionary to hold parameters that are to be included in the search.
 */
- (NSMutableDictionary *)includedParameters
{
	if (!_includedParameters)
		_includedParameters				= [[NSMutableDictionary alloc] init];
	
	return _includedParameters;
}

/**
 *	A convenient way to get the total number of metadata dictionaries in the includedParameters array.
 *
 *	@return	The number of included parameters in total.
 */
- (NSUInteger)includedParametersCount
{
	NSUInteger count					= 0;
	
	for (NSArray *metadataType in self.includedParameters.allValues)
		count						+= metadataType.count;
	
	return count;
}

/**
 *	This view controller represents parameters to choose from for recipe searches.
 *
 *	@return	A fully initialised view controller handling the display of advanced options.
 */
- (RecipeSearchParametersViewController *)recipeParametersController
{
	//	use lazy instantiation to create the view controller and add it as a child of this view controller
	if (!_recipeParametersController)
	{
		_recipeParametersController							= [[RecipeSearchParametersViewController alloc] init];
		_recipeParametersController.delegate				= self;
		_recipeParametersController.view.backgroundColor	= [UIColor whiteColor];
		_recipeParametersController.view.layer.opacity		= 0.9f;
		
		_recipeParametersController.view.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_recipeParametersController.view];
		[self addChildViewController:_recipeParametersController];
		[_recipeParametersController didMoveToParentViewController:self];
		[self.view bringSubviewToFront:_recipeParametersController.view];
	}
	
	return _recipeParametersController;
}

/**
 *	This table view will be used to show the user the selected options.
 *
 *	@return	A fully initialised table view.
 */
- (UITableView *)tableView
{
	//	use lazy instantiation to initialise the table view and set it up for use
	if (!_tableView)
	{
		_tableView						= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.allowsSelection		= YES;
		_tableView.allowsSelectionDuringEditing	= YES;
		_tableView.backgroundColor		= [UIColor whiteColor];
		_tableView.contentInset			= UIEdgeInsetsMake(0.0f, 0.0f, kParametersControllerHeight, 0.0f);
		_tableView.dataSource			= self;
		_tableView.delegate				= self;
		_tableView.separatorStyle		= UITableViewCellSeparatorStyleNone;
		
		[_tableView registerClass:[MetadataCell class] forCellReuseIdentifier:kCellIdentifier];
		
		/*if (isFourInchDevice)
			_tableView.frame			= CGRectMake(50.0f, 0.0f, 270.0f, 508.0f);
		else
			_tableView.frame			= CGRectMake(50.0f, 0.0f, 270.0f, 420.0f);*/
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_tableView];
		[self.view sendSubviewToBack:_tableView];
	}
	
	return _tableView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeParameters"	: self.recipeParametersController.view,
				@"tableView"		: self.tableView};
}

#pragma mark - UITableViewDataSource Methods

/**
 *	Asks the data source to return the number of sections in the table view.
 *
 *	@param	tableView					The number of sections in tableView. The default value is 1.
 *
 *	@return	The number of sections in tableView.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

/**
 *	Asks the data source to verify that the given row is editable.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path locating a row in tableView.
 *
 *	@return	YES if the row indicated by indexPath is editable; otherwise, NO.
 */
- (BOOL)	tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath isEqual:self.selectedCellIndexPath])
		return YES;
	
	return NO;
}

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
	MetadataCell *cell					= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	cell.metadataLabel.text				= [self metadataForItemAtIndexPath:indexPath];
	cell.metadataTypeLabel.alpha		= 0.0f;
	cell.metadataTypeLabel.text			= [self metadataTypeForItemAtIndexPath:indexPath];
	cell.selectionStyle					= UITableViewCellSelectionStyleNone;
	
	[UIView animateWithDuration:1.5f animations:
	^{
		cell.metadataTypeLabel.alpha	= 1.0f;
	}];
	
	return cell;
}

/**
 *	Asks the data source to commit the insertion or deletion of a specified row in the receiver.
 *
 *	@param	tableView					The table-view object requesting the insertion or deletion.
 *	@param	editingStyle				The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath.
 *	@param	indexPath					An index path locating the row in tableView.
 */
- (void) tableView:(UITableView *)				tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)				indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSString *metadataToRemove		= [self metadataForItemAtIndexPath:indexPath];
		NSString *metadataType			= [self metadataTypeForItemAtIndexPath:indexPath];
		BOOL included					= !(indexPath.section == 0);
		self.removeMetadata(metadataToRemove, metadataType, included);
		[self removeMetadata:metadataToRemove ofType:metadataType included:included];
		
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		
		self.selectedCellIndexPath		= nil;
		[self.tableView setEditing:NO animated:NO];
	}
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
	if (section == 0)
		return [self excludedParametersCount];
	else if (section == 1)
		return [self includedParametersCount];
	else
		return 0;
}

/**
 *	Tells the delegate the table view is about to draw a cell for a particular row.
 *
 *	@param	tableView					The table-view object informing the delegate of this impending event.
 *	@param	cell						A table-view cell object that tableView is going to use when drawing the row.
 *	@param	indexPath					An index path locating the row in tableView.
 */
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	background colour has to be set here
	[ThemeManager customiseTableViewCell:cell withTheme:nil];
}

#pragma mark - UITableViewDelegate Methods

/**
 *	Tells the delegate that the specified row is now selected.
 *
 *	@param	tableView					A table-view object informing the delegate about the new row selection.
 *	@param	indexPath					An index path locating the new selected row in tableView.
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.selectedCellIndexPath)
	{
		self.selectedCellIndexPath			= indexPath;
		[tableView setEditing:YES animated:YES];
	}
	
	else
	{
		if (![indexPath isEqual:self.selectedCellIndexPath])
		{
			self.selectedCellIndexPath			= indexPath;
			[tableView setEditing:NO animated:YES];
			[tableView setEditing:YES animated:YES];
		}
		
		else
		{
			self.selectedCellIndexPath			= nil;
			[tableView setEditing:NO animated:YES];
		}
	}
}

/**
 *	Asks the delegate for the height to use for a row in a specified location.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path that locates a row in tableView.
 *
 *	@return	A floating-point value that specifies the height (in points) that row should be.
 */
- (CGFloat)	  tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 25.0f;
}

/**
 *	Asks the delegate for a view object to display in the header of the specified section of the table view.
 *
 *	@param	tableView					The table-view object asking for the view object.
 *	@param	section						An index number identifying a section of tableView .
 *
 *	@return	A view object to be displayed in the header of section.
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{	
	//	get header view object and then just set the title
	UITableViewHeaderFooterView *headerView		= [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
	if (!headerView)
		headerView						= [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderIdentifier];
	headerView.textLabel.text			= section == 0 ? @"Excluded" : @"Required";
	headerView.contentView.backgroundColor	= [[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	headerView.textLabel.textColor			= [UIColor whiteColor];
	
	return headerView;
}

#pragma mark - View Lifecycle

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
}

@end