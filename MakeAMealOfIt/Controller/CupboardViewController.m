//
//  CupboardViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "CupboardViewController.h"
#import "IngredientTableViewCell.h"
#import "YummlyMetadata.h"

@import QuartzCore;

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"CupboardCellIdentifier";
static NSString *const kHeaderIdentifier= @"HeaderViewIdentifier";

#pragma mark - Cupboard View Controller Private Class Extension

@interface CupboardViewController () <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	*/
@property (nonatomic, strong)	NSMutableArray				*filteredIngredients;
/**	*/
@property (nonatomic, strong)	NSArray						*ingredientsArray;
/**	*/
@property (nonatomic, strong)	NSArray						*ingredientsMetadata;
/**	*/
@property (nonatomic, strong)	NSMutableDictionary			*ingredientsForTableView;
/**	A comparator block that sorts letter before numbers and punctuation.	*/
@property (nonatomic, assign)	NSComparator				prioritiseLettersComparator;
/**	This search bar will be used to search the ingredients table view.	*/
@property (nonatomic, strong)	UISearchBar					*searchBar;
/**	The constraints used to set the search bar on top of the table view.	*/
@property (nonatomic, strong)	NSArray						*searchBarConstraints;
/**	*/
@property (nonatomic, strong)	UISearchDisplayController	*searchDisplay;
/**	*/
@property (nonatomic, strong)	NSArray						*sectionTitles;
/**	*/
@property (nonatomic, strong)	NSMutableArray				*selectedIndices;
/**	*/
@property (nonatomic, strong)	UITableView					*tableView;
/**	*/
@property (nonatomic, strong)	NSDictionary				*viewsDictionary;

@end

#pragma mark - Cupboard View Controller Implementation

@implementation CupboardViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the global Yummly Request object has been reset.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
	for (NSIndexPath *selectedIndexPath in self.tableView.indexPathsForSelectedRows)
	{
		[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
		[self tableView:self.tableView didDeselectRowAtIndexPath:selectedIndexPath];
	}
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
	NSLayoutConstraint *constraint;
	
	//	add the table view to cover the whole main view except for the search bar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]-(Panel)-|" options:kNilOptions metrics:@{@"Panel": @(kPanelWidth)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
	[self.view addConstraint:constraint];
	
	self.searchBarConstraints			= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar][tableView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:self.searchBarConstraints];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Returns an index path for a specified ingredient dictionary.
 *
 *	@param	ingredientDictionary		The ingredient dictionary to find the index path for in a table view.
 *	@param	tableView					The table view we want the index path to refer to.
 *
 *	@return	An NSIndexPath with the row and section for the passed in ingredientDictionary.
 */
- (NSIndexPath *)indexPathForIngredientDictionary:(NSDictionary *)ingredientDictionary
									  inTableView:(UITableView *)tableView
{
	NSString *ingredient				= ingredientDictionary[kYummlyMetadataDescriptionKey];
	
	if (tableView == self.tableView)
	{
		for (NSUInteger sectionTitleIndex = 0; sectionTitleIndex < self.sectionTitles.count; sectionTitleIndex++)
			for (NSUInteger ingredientIndex = 0; ingredientIndex < ((NSArray *)self.ingredientsForTableView[self.sectionTitles[sectionTitleIndex]]).count; ingredientIndex++)
				if ([self.ingredientsForTableView[self.sectionTitles[sectionTitleIndex]][ingredientIndex] isEqualToString:ingredient])
					return [NSIndexPath indexPathForRow:ingredientIndex inSection:sectionTitleIndex];
	}
	
	else if (tableView == self.searchDisplay.searchResultsTableView)
		for (NSUInteger index = 0; index < self.filteredIngredients.count; index++)
			if ([self.filteredIngredients[index] isEqualToString:ingredient])
				return [NSIndexPath indexPathForRow:index inSection:1];
	
	return nil;
}

/**
 *	Returns an ingredient dictionary for an index path in a table view.
 *
 *	@param	indexPath					The index path of the item in the table view.
 *	@param	tableView					The table view that the index path refers to.
 *
 *	@return	An NSDictionary with the details of the ingredient at the passed in index path.
 */
- (NSDictionary *)ingredientDictionaryForIndexPath:(NSIndexPath *)indexPath
									   inTableView:(UITableView *)tableView
{
	NSString *ingredient;
	if (tableView == self.tableView)
		ingredient						= self.ingredientsForTableView[self.sectionTitles[indexPath.section]][indexPath.row];
	else if (tableView == self.searchDisplay.searchResultsTableView)
		ingredient						= self.filteredIngredients[indexPath.row];
	
	for (NSDictionary *ingredientDictionary in self.ingredientsMetadata)
		if ([ingredientDictionary[kYummlyMetadataDescriptionKey] isEqualToString:ingredient])
			return ingredientDictionary;
	
	return nil;
}

/**
 *	Filters the contents of the table view according to the search of the user.
 *
 *	@param	searchText					The search phrase.
 *	@param	scope						The scope under which to use the search phrase.
 */
- (void)filterContentForSearchText:(NSString *)searchText inScope:(NSString *)scope
{
	//	first remove all past search results
	[self.filteredIngredients removeAllObjects];
	
	//	define the predicate according to the search of the user
	NSPredicate *predicate				= [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
	self.filteredIngredients			= [[self.ingredientsArray filteredArrayUsingPredicate:predicate] mutableCopy];
}

/**
 *	Sets the the search display controller's table view properties.
 */
- (void)sortOutSearchDisplayControllerTableView
{
	_searchDisplay.searchResultsDataSource	= self;
	_searchDisplay.searchResultsDelegate	= self;
	_searchDisplay.searchResultsTableView.allowsMultipleSelection	= YES;
	[_searchDisplay.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - Initialisation

/**
 *	Asynchronously gets the ingredient dictionaries and then reloads the table view with them.
 */
- (void)getIngredientsDictionaries
{
	dispatch_async(dispatch_queue_create("Ingredients Fetcher", NULL),
	^{
		self.ingredientsMetadata	= [YummlyMetadata allMetadata][kYummlyMetadataIngredients];
		[self setupTableViewIndex];
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	});
}

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yummlyRequestHasBeenReset:) name:kNotificationResetSearch object:nil];
	}
	
	return self;
}

/**
 *	This will be responsible for setting up the sections and the index titles for the table view.
 */
- (void)setupTableViewIndex
{	
	for (NSString *ingredient in self.ingredientsArray)
	{
		NSString *firstCharacter		= [ingredient substringWithRange:NSMakeRange(0, 1)];
		NSMutableArray *ingredients		= self.ingredientsForTableView[firstCharacter];
		
		if (!ingredients)
			ingredients					= [[NSMutableArray alloc] init];
		
		[ingredients addObject:ingredient];
		
		self.ingredientsForTableView[firstCharacter]	= ingredients;
	}
}

#pragma mark - Left Delegate Methods

/**
 *	called when an index path was selected or deselected in a table view
 *
 *	@param	tableView					the table view that the index path is inside of
 *	@param	isSelected					whether the index path item was selected or deselected
 *	@param	indexPath					index path representing the item that was selected or deselected
 */
- (void)tableView:(UITableView *)tableView
		 selected:(BOOL)isSelected
		indexPath:(NSIndexPath *)indexPath
{
	//	asynchronously update the left controller with the selected ingredient dictionary
	dispatch_async(dispatch_queue_create("Updating Selections", NULL),
	^{
		NSDictionary *ingredientDictionary	= [self ingredientDictionaryForIndexPath:indexPath inTableView:tableView];
		[self tableView:tableView selected:isSelected ingredientDictionary:ingredientDictionary];
	});
}

/**
 *	called when a particular ingredient dictionary was selected in the table view
 *
 *	@param	tableView					the table view object wherein the ingredient dictionary was selected
 *	@param	isSelected					whether the ingredient dictionary was selected or deselected
 *	@param	ingredientDictionary		the ingredient dictionary that was either selected or deselected
 */
- (void)   tableView:(UITableView *)tableView
			selected:(BOOL)isSelected
ingredientDictionary:(NSDictionary *)ingredientDictionary
{
	//	first get every selected index path and get the corresponding ingredient dictionary
	NSMutableArray *allSelections		= [[NSMutableArray alloc] init];
	for (NSIndexPath *selectedIndexPath in [tableView indexPathsForSelectedRows])
		[allSelections addObject:[self ingredientDictionaryForIndexPath:selectedIndexPath inTableView:tableView]];
	
	NSArray *update						= @[ingredientDictionary];
	
	NSMutableDictionary *addedSelections		= [@{kExcludedSelections	: @[],
													 kIncludedSelections	: @[]} mutableCopy];
	NSMutableDictionary *removedSelections		= [@{kExcludedSelections	: @[],
													 kIncludedSelections	: @[]} mutableCopy];
	
	
	//	update the array appropriately according to whether it is selected or not
	if (!isSelected)
	{
		removedSelections[kIncludedSelections]	= update;
	}
	else
	{
		addedSelections[kIncludedSelections]	= update;
	}
	
	//	make a dictionary with the updates to send to the left view controller
	NSDictionary *updates				= @{kAddedSelections	: addedSelections,
											kAllSelections		: allSelections,
											kRemovedSelections	: removedSelections};
	
	//	make sure this is performed on the main thread
	dispatch_async(dispatch_get_main_queue(),
	^{
		[self.leftDelegate leftController:self updatedWithSelections:updates];
	});
}

#pragma mark - Setter & Getter Methods

/**
 *	an array of the ingredients filtered according to the search fo the user
 */
- (NSMutableArray *)filteredIngredients
{
	if (!_filteredIngredients)
		_filteredIngredients			= [[NSMutableArray alloc] init];
	
	return _filteredIngredients;
}

/**
 *	this dictionary will hold the sections and the objects pertaining to that section
 */
- (NSMutableDictionary *)ingredientsForTableView
{
	if (!_ingredientsForTableView)
		_ingredientsForTableView		= [[NSMutableDictionary alloc] init];
	
	return _ingredientsForTableView;
}

/**
 *	an array of possible placeholders for the search bar
 */
- (NSArray *)placeholders
{
	return @[@"Apple", @"Chicken", @"Chili Pepper", @"Cream", @"Flour", @"Fusilli", @"Milk Chocolate", @"Peanut Butter", @"Sugar", @"Vanilla", @"Wine"];
}

/**
 *	The getter for the comparator to use when sorting things for the table view.
 *
 *	@return	A comparator block that sorts letter before numbers and punctuation.
 */
- (NSComparator)prioritiseLettersComparator
{
	if (!_prioritiseLettersComparator)
	{
		_prioritiseLettersComparator	= ^NSComparisonResult(NSString *stringA, NSString *stringB)
		{
			//	gets whether either first letter is a number
			BOOL isNumberA				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[stringA characterAtIndex:0]];
			BOOL isNumberB				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[stringB characterAtIndex:0]];
			
			//	we sort the letter over the number
			if (!isNumberA && isNumberB)
				return NSOrderedAscending;
			
			else if (isNumberA && !isNumberB)
				return NSOrderedDescending;
			
			//	if both or neither are numbers we sort normally
			return [stringA compare:stringB options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
		};
	}
	
	return _prioritiseLettersComparator;
}

/**
 *	The getter for the comparator to use when sorting things for the table view.
 *
 *	@return	A comparator block that sorts letter before numbers and punctuation.
 */
- (NSComparator)prioritiseLettersInDictionaryComparator
{
	if (!_prioritiseLettersComparator)
	{
		_prioritiseLettersComparator	= ^NSComparisonResult(NSDictionary *ingredientDictionaryA, NSDictionary *ingredientDictionaryB)
		{
			NSString *ingredientA		= ingredientDictionaryA[kYummlyMetadataDescriptionKey];
			NSString *ingredientB		= ingredientDictionaryB[kYummlyMetadataDescriptionKey];
			
			//	gets whether either first letter is a number
			BOOL isNumberA				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[ingredientA characterAtIndex:0]];
			BOOL isNumberB				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[ingredientB characterAtIndex:0]];
			
			//	we sort the letter over the number
			if (!isNumberA && isNumberB)
				return NSOrderedAscending;
			
			else if (isNumberA && !isNumberB)
				return NSOrderedDescending;
			
			//	if both or neither are numbers we sort normally
			return [ingredientA compare:ingredientB options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
		};
	}
	
	return _prioritiseLettersComparator;
}

/**
 *	This search bar will be used to search the ingredients table view.
 *
 *	@return	A fully initialised and customised seach bar.
 */
- (UISearchBar *)searchBar
{
	if (!_searchBar)
	{
		_searchBar						= [[UISearchBar alloc] init];
		_searchBar.delegate				= self;
		_searchBar.placeholder			= [[NSString alloc] initWithFormat:@"%@...", self.placeholders[arc4random() % self.placeholders.count]];
		_searchBar.showsScopeBar		= NO;
		[ThemeManager customiseSearchBar:_searchBar withTheme:nil];
		
		_searchBar.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_searchBar];
	}
	
	return _searchBar;
}

/**
 *	the search display controller handling the searches of our table view
 */
- (UISearchDisplayController *)searchDisplay
{
	if (!_searchDisplay)
	{
		_searchDisplay					= [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_searchDisplay.delegate			= self;
		[self sortOutSearchDisplayControllerTableView];
	}
	
	return _searchDisplay;
}

/**
 *	this is used to give the ingredients dictionary a convenient way to access the keys is a sorted way
 */
- (NSArray *)sectionTitles
{
	return [self.ingredientsForTableView.allKeys sortedArrayUsingComparator:self.prioritiseLettersComparator];
}

/**
 *	an array holding all of the indices of the selected rows in our table view
 */
- (NSMutableArray *)selectedIndices
{
	if (!_selectedIndices)
		_selectedIndices				= [[NSMutableArray alloc] init];
	
	return _selectedIndices;
}

/**
 *	the setter for the array of ingredient descriptions
 *
 *	@param	ingredientsArray			an unsorted array of ingredient descriptions
 */
- (void)setIngredientsArray:(NSArray *)ingredientsArray
{
	_ingredientsArray					= [ingredientsArray sortedArrayUsingComparator:self.prioritiseLettersComparator];
}

/**
 *	set the array of dictionaries each holding an ingredient object
 *
 *	@param	ingredientsMetadata		the array of ingredient dictionaries
 */
- (void)setIngredientsMetadata:(NSArray *)ingredientsMetadata
{
	_ingredientsMetadata			= ingredientsMetadata;
	
	NSMutableArray *unsortedIngredients	= [[NSMutableArray alloc] init];
	
	for (NSDictionary *ingredientDictionary in _ingredientsMetadata)
		[unsortedIngredients addObject:ingredientDictionary[kYummlyMetadataDescriptionKey]];
	
	self.ingredientsArray			= unsortedIngredients;
}

/**
 *	called when our left controller delegate is set
 *
 *	@param	leftDelegate			an nsobject adhering to our left controller delegate protocol
 */
- (void)setLeftDelegate:(id<LeftControllerDelegate>)leftDelegate
{
	_leftDelegate					= leftDelegate;
	
	//	get a weak pointer to our self to be used in the block
	__weak CupboardViewController *weakSelf	= self;
	
	//	if a valid left delegate was set we send it the block to execute if it modifies any of our data
	if (_leftDelegate)
		[_leftDelegate blockToExecuteWhenDataModified:^(NSDictionary *modifiedIngredient)
		{
			dispatch_async(dispatch_queue_create("Modifying Selections", NULL),
			^{
				NSIndexPath *indexPath		= [weakSelf indexPathForIngredientDictionary:modifiedIngredient inTableView:weakSelf.tableView];
				
				dispatch_async(dispatch_get_main_queue(),
				^{
					[weakSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
					[weakSelf tableView:weakSelf.tableView didDeselectRowAtIndexPath:indexPath];
				});
			});
		}];
}

/**
 *	this is the main table view for this view controller
 */
- (UITableView *)tableView
{
	if (!_tableView)
	{
		_tableView						= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.allowsMultipleSelection	= YES;
		_tableView.dataSource			= self;
		_tableView.delegate				= self;
		[self.view addSubview:_tableView];
		
		[_tableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
	}
	
	return _tableView;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"searchBar"	: self.searchBar,
				@"tableView"	: self.tableView};
}

#pragma mark - UISearchBarDelegate Methods

/**
 *	tells delegate when the user begins editing the search text
 *
 *	@param	searchBar					search bar that is being edited
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar becomeFirstResponder];
	
	[self sortOutSearchDisplayControllerTableView];
}

#pragma mark - UISearchDisplayDelegate Methods

/**
 *	asks the delegate if the table view should be reloaded for a given scope
 *
 *	@param	controller					search display controller for which the receiver is the delegate
 *	@param	searchOption				index of the selected scope button in the search bar
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	return YES;
}

/**
 *	asks the delegate if the table view should be reloaded for a given search string
 *
 *	@param	controller					search display controller for which the receiver is the delegate
 *	@param	searchOption				string in the search bar
 */
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString inScope:nil];
	
	return YES;
}

#pragma mark - UITableViewDataSource Methods

/**
 *	as the data source, we must define how many sections we want the table view to have
 *
 *	@param	tableView					the table view for which are defining the sections number
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return 1;
	
	return self.ingredientsForTableView.count;
}


/**
 *	Asks the data source to return the titles for the sections for a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *
 *	@return	An array of strings that serve as the title of sections in the table view and appear in the index list on the right side of the table view.
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return nil;
	
	NSMutableArray *capitalisedTitles	= [[NSMutableArray alloc] init];
	
	for (NSString *title in self.sectionTitles)
		if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[title characterAtIndex:0]])
		{
			if (![capitalisedTitles containsObject:@"#"])
				[capitalisedTitles addObject:@"#"];
		}
		else
			[capitalisedTitles addObject:[title capitalizedString]];
	
	return capitalisedTitles;
}

/**
 *	create and return the cells for each row of the table view
 *
 *	@param	tableView					the table view for which we are creating cells
 *	@param	indexPath					the index path of the row we are creating a cell for
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell				= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	if (tableView == self.searchDisplay.searchResultsTableView)
		cell.textLabel.text				= [self.filteredIngredients[indexPath.row] capitalizedString];
	else
		cell.textLabel.text				= [self.ingredientsForTableView[self.sectionTitles[indexPath.section]][indexPath.row] capitalizedString];
	
	cell.textLabel.backgroundColor		= [UIColor clearColor];
	cell.selectionStyle					= UITableViewCellSelectionStyleNone;
	
	return cell;
}

/**
 *	define how many rows for each section there are in this table view
 *
 *	@param	tableView					the table view for which we are creating cells
 *	@param	section						the particular section for which we must define the rows
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return self.filteredIngredients.count;
	
	
	
	return ((NSArray *)self.ingredientsForTableView[self.sectionTitles[section]]).count;
}

/**
 *	tells the delegate the table view is about to draw a cell for a particular row
 *
 *	@param	tableView					table-view object informing the delegate of this impending event
 *	@param	cell						table-view cell object that table view is going to use when drawing the row
 *	@param	indexPath					index path locating the row in table view
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
 *	tells the delegate that the specified row is now deselected
 *
 *	@param	tableView					table-view object informing the delegate about the row deselection
 *	@param	indexPath					the index path of the cell that was selected
 */
- (void)		tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell				= [tableView cellForRowAtIndexPath:indexPath];
	
	[UIView animateWithDuration:0.5f animations:
	^{
		[ThemeManager customiseTableViewCell:cell withTheme:nil];
	}];
	
	[self tableView:tableView selected:NO indexPath:indexPath];
}

/**
 *	tells the delegate that the specified row is now selected
 *
 *	@param	tableView					table-view object informing the delegate about the new row selection
 *	@param	indexPath					index path locating the new selected row in table view
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell				= [tableView cellForRowAtIndexPath:indexPath];
	
	[UIView animateWithDuration:0.5f animations:
	^{
		cell.backgroundColor				= kYummlyColourMain;
		cell.textLabel.textColor			= [UIColor whiteColor];
	}];
	
	[self tableView:tableView selected:YES indexPath:indexPath];
}

/**
 *	Asks the delegate for the height to use for a row in a specified location.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path that locates a row in tableView.
 */
- (CGFloat)	  tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 25.0f;
}

/**
 *	asks the delegate for a view object to display in the header of the specified section of the table view
 *
 *	@param	tableView					table-view object asking for the view object
 *	@param	section						index number identifying a section of table view
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return nil;
	
	//	get header view object and then just set the title
	UITableViewHeaderFooterView *headerView		= [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
	if (!headerView)
		headerView						= [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderIdentifier];
	headerView.textLabel.text			= [self.sectionTitles[section] capitalizedString];
	headerView.contentView.backgroundColor	= [[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	headerView.textLabel.textColor			= [UIColor whiteColor];
	
	return headerView;
}

#pragma mark - View Lifecycle

/**
 *	sent to the view controller when the app receives a memory warning
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self getIngredientsDictionaries];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
}

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
}

@end