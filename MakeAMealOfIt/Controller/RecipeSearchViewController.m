//
//  RecipeSearchViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "RecipeSearchView.h"
#import "RecipeSearchViewController.h"
#import "RecipesViewController.h"
#import "ToolbarLabelYummlyTheme.h"
#import "YummlyAttributionViewController.h"
#import "YummlySearchResult.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier		= @"ChosenIngredientsCellIdentifier";
static NSString *const kHeaderIdentifier	= @"ChosenIngredientsHeaderIdentifier";

enum SectionIndex
{
	kSectionExcludedIndex		= 0,
	kSectionIncludedIndex		= 1
};

#pragma mark - Recipe Search View Controller Private Class Extension

@interface RecipeSearchViewController () <RecipeSearchViewController, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	A button that allows the user to reset the entire search.	*/
@property (nonatomic, strong)	UIButton					*clearSearchButton;
/**	A bool indicating whether this centre view has been slid at least once.	*/
@property (nonatomic, assign)	BOOL						hasBeenSlid;
/**	A dictionary of ingredients to be either included or excluded.	*/
@property (nonatomic, strong)	NSMutableDictionary			*selectedIngredients;
/**	The table view representing the included or excluded ingredients for the recipe search.	*/
@property (nonatomic, strong)	UITableView					*tableView;
/**	A block to call when any left controller sata has been modified in this view controller.	*/
@property (nonatomic, copy)		LeftControllerDataModified	modifiedIngredients;
/**	This is the main view that allows the user to search.	*/
@property (nonatomic, strong)	RecipeSearchView			*recipeSearchView;

@end

#pragma mark - Recipe Search View Controller Implementation

@implementation RecipeSearchViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the button in the toolbar for the left panel is tapped.
 */
- (void)leftButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	[super leftButtonTapped];
}

/**
 *	User has selected the option to reset the search.
 */
- (void)resetSearchTapped
{
	if (self.leftButtonTag == kButtonInUse || self.rightButtonTag == kButtonInUse)
		return;
	
	//	we make sure that they meant to do this
	[[[UIActionSheet alloc] initWithTitle:@"Reset Entire Search?"
								 delegate:self cancelButtonTitle:@"Cancel"
				   destructiveButtonTitle:@"Reset Search"
						otherButtonTitles:nil] showFromRect:self.clearSearchButton.frame inView:self.view animated:YES];
}

/**
 *	Called when the button in the toolbar for the right panel is tapped.
 */
- (void)rightButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	[super rightButtonTapped];
}

/**
 *	Sets the tag of the button to the left of the toolbar.
 *
 *	@param	tag							Should be kButtonInUse for when button has been tapped, and kButtonNotInUse otherwise.
 */
- (void)setLeftButtonTag:(NSUInteger)tag
{
	if (tag == kButtonInUse)
		self.hasBeenSlid				= YES;
	[super setLeftButtonTag:tag];
}

/**
 *	Sets the tag of the button to the right of the toolbar.
 *
 *	@param	tag							Should be kButtonInUse for when button has been tapped, and kButtonNotInUse otherwise.
 */
- (void)setRightButtonTag:(NSUInteger)tag
{
	if (tag == kButtonInUse)
		self.hasBeenSlid				= YES;
	[super setLeftButtonTag:tag];
}

/**
 *	Called when the global Yummly Request object has been reset.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
	dispatch_async(dispatch_queue_create("Ingredients Clearer", NULL),
	^{
		NSUInteger rowCount					= self.selectedIngredients.count;
		NSMutableArray *indexPaths			= [[NSMutableArray alloc] initWithCapacity:rowCount];
		for (NSUInteger index = 0; index < rowCount; index++)
			[indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
		
		[self.selectedIngredients removeAllObjects];
		
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
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
	
	CGFloat toolbarHeight				= self.toolbarHeight;
	
	//	add the table view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[recipeSearchView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:[clearSearchButton]-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(height)][recipeSearchView(==150)]-[tableView]" options:kNilOptions metrics:@{@"height": @(toolbarHeight)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableView]-[clearSearchButton]-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	[self.view bringSubviewToFront:self.toolbar];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Conveniently returns the correcr array for the given section.
 *
 *	@param	section						The section of a table or collection view requesting an array.
 *
 *	@return	An array of ingredients relevant to the section.
 */
- (NSArray *)ingredientsArrayForSection:(NSUInteger)section
{
	if (section == kSectionExcludedIndex)
		return self.selectedIngredients[kExcludedSelections];
	else if (section == kSectionIncludedIndex)
		return self.selectedIngredients[kIncludedSelections];
	return nil;
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yummlyRequestHasBeenReset:) name:kNotificationResetSearch object:nil];
	}
	
	return self;
}

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animate						Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
{
	self.leftButton						= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_hamburger_yummly"]
															   style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonTapped)];
	
	UIBarButtonItem *flexibleSpace		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UILabel *title						= [[UILabel alloc] init];
	title.backgroundColor				= [UIColor clearColor];
	title.text							= @"Make a Meal Of It";
	title.textAlignment					= NSTextAlignmentCenter;
	[ThemeManager customiseLabel:title withTheme:[[ToolbarLabelYummlyTheme alloc] init]];
	[title sizeToFit];
	UIBarButtonItem *titleItem			= [[UIBarButtonItem alloc] initWithCustomView:title];
	
	self.rightButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_selection_yummly"]
															 style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonTapped)];
	
	[self.toolbar setItems:@[self.leftButton, flexibleSpace, titleItem, flexibleSpace, self.rightButton] animated:animate];
}

#pragma mark - Left Controller Delegate Methods

/**
 *	A block sent by the delegate to be executed when data has been modified.
 *
 *	@param	dataModifiedBlack			Intended to be executed with any modified data.
 */
- (void)blockToExecuteWhenDataModified:(LeftControllerDataModified)dataModifiedBlock
{
	//	store the block to execute it later
	self.modifiedIngredients			= dataModifiedBlock;
}

/**
 *	Sent to the delegate when a user has updated any selections in the left view controller.
 *
 *	@param	leftViewController			The left view controller sending this message.
 *	@param	selections					The selections dictionary with all of the selections in the table view.
 */
- (void)leftController:(UIViewController *)leftViewController
 updatedWithSelections:(NSDictionary *)selections
{
	NSDictionary *addedSelections		= selections[kAddedSelections];
	NSDictionary *removedSelections		= selections[kRemovedSelections];
	
	NSMutableArray *excludedIngredients	= [self.selectedIngredients[kExcludedSelections] mutableCopy];
	NSMutableArray *includedIngredients	= [self.selectedIngredients[kIncludedSelections] mutableCopy];
	
	//	asynchronously add the selections to the yummly request and update our array for the table view
	dispatch_async(dispatch_queue_create("Updating Yummly Request", NULL),
	^{
		if (addedSelections)
		{
			NSArray *addedExcluded		= addedSelections[kExcludedSelections];
			NSArray *addedIncluded		= addedSelections[kIncludedSelections];
			
			[excludedIngredients addObjectsFromArray:addedExcluded];
			[includedIngredients addObjectsFromArray:addedIncluded];
			
			for (NSDictionary *ingredientDictionary in addedExcluded)
				[appDelegate.yummlyRequest addExcludedIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
			for (NSDictionary *ingredientDictionary in addedIncluded)
				[appDelegate.yummlyRequest addDesiredIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
		}
		
		if (removedSelections)
		{
			NSArray *removedExcluded	= removedSelections[kExcludedSelections];
			NSArray *removedIncluded	= removedSelections[kIncludedSelections];
			
			[excludedIngredients removeObjectsInArray:removedExcluded];
			[includedIngredients removeObjectsInArray:removedIncluded];
			
			for (NSDictionary *ingredientDictionary in removedExcluded)
				[appDelegate.yummlyRequest removeExcludedIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
			for (NSDictionary *ingredientDictionary in removedIncluded)
				[appDelegate.yummlyRequest removeDesiredIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
		}
		
		self.selectedIngredients[kExcludedSelections]	= excludedIngredients;
		self.selectedIngredients[kIncludedSelections]	= includedIngredients;
		
		//	reload the table view on the main thread
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	});
}

#pragma mark - RecipeSearchViewController Methods

/**
 *	Called when a view controller was added to recipe search view.
 *
 *	@param	viewController				The view controller which was added to the our child view.
 */
- (void)addedViewController:(UIViewController *)viewController
{
	[self addChildViewController:viewController];
	[viewController didMoveToParentViewController:self];
}

/**
 *	Called when a search was executed and returned with the results dictionary.
 *
 *	@param	results						The dictionary of results from the yummly response.
 */
- (void)searchExecutedForResults:(NSDictionary *)results
{
	//	set up the next centre view controller with the recipes it needs to display
	RecipesViewController *recipesVC	= [[RecipesViewController alloc] init];
	recipesVC.recipes					= results[kYummlyMatchesArrayKey];
	recipesVC.searchPhrase				= [results[@"criteria"][@"terms"] lastObject];
	
	//	set up the next right view controller with the attributions it needs to display
	YummlyAttributionViewController *yummlyAttribution	= [[YummlyAttributionViewController alloc] initWithAttributionDictionary:results[kYummlyAttributionDictionaryKey]];
	
	//	present the next set of view controllers
	[appDelegate.slideOutVC showCentreViewController:recipesVC withRightViewController:yummlyAttribution];
}

#pragma mark - Setter & Getter Methods

/**
 *	A button that allows the user to reset the entire search.
 *
 *	@return	A fully initialise button targeted to a method which resets the Yummly Search.
 */
- (UIButton *)clearSearchButton
{
	if (!_clearSearchButton)
	{
		_clearSearchButton							= [[UIButton alloc] init];
		_clearSearchButton.titleLabel.font			= kYummlyBolderFontWithSize(16.0f);
		_clearSearchButton.titleLabel.textAlignment	= NSTextAlignmentCenter;
		[_clearSearchButton setTitle:@"Reset Search" forState:UIControlStateNormal];
		[_clearSearchButton setTitleColor:[UIColor colorWithRed:0.8f green:0.3f blue:0.3f alpha:1.0f] forState:UIControlStateNormal];
		_clearSearchButton.opaque					= YES;
		
		[_clearSearchButton addTarget:self action:@selector(resetSearchTapped) forControlEvents:UIControlEventTouchUpInside];
		
		_clearSearchButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_clearSearchButton];
	}
	
	return _clearSearchButton;
}

/**
 *	The table view representing the chosen ingredients for the recipe search.
 *
 *	@return	An initialised and designed table view for use showing included ingredients.
 */
- (UITableView *)tableView
{
	//	use lazy instantiation to set up the table view
	if (!_tableView)
	{
		_tableView					= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.bounces			= NO;
		_tableView.backgroundColor	= [UIColor whiteColor];
		_tableView.backgroundView	= nil;
		_tableView.opaque			= YES;
		_tableView.separatorColor	= [UIColor clearColor];
		_tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
		
		//	we are in complete control of this table view
		_tableView.dataSource		= self;
		_tableView.delegate			= self;
		
		//	the only type of cell this table view uses is the standard one
		[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_tableView];
	}
	
	return _tableView;
}

/**
 *	This is the main view that allows the user to search.
 *
 *	@return	A fully initiased view with ourselves as the delegate.
 */
- (RecipeSearchView *)recipeSearchView
{
	//	use lazy instantiation to initialise the view
	if (!_recipeSearchView)
	{
		_recipeSearchView				= [[RecipeSearchView alloc] init];
		_recipeSearchView.delegate		= self;
		_recipeSearchView.opaque		= YES;
		
		_recipeSearchView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_recipeSearchView];
	}
	
	return _recipeSearchView;
}

/**
 *	The ingredients selected by the left controller.
 *
 *	@return	An array of ingredients to include in the recipes we search for.
 */
- (NSMutableDictionary *)selectedIngredients
{
	if (!_selectedIngredients)
		_selectedIngredients			= [@{kExcludedSelections: @[],
											 kIncludedSelections: @[]	} mutableCopy];
	
	return _selectedIngredients;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"clearSearchButton": self.clearSearchButton,
				@"recipeSearchView"	: self.recipeSearchView,
				@"tableView"		: self.tableView,
				@"toolbar"			: self.toolbar};
}

#pragma mark - UIActionSheetDelegate

/**
 *	Sent to the delegate before an action sheet is dismissed.
 *
 *	@param	actionSheet					The action sheet that is about to be dismissed.
 *	@param	buttonIndex					The index of the button that was clicked. If this is the cancel button index, the action sheet is canceling.
 */
- (void)	   actionSheet:(UIActionSheet *)actionSheet
willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex)
	{
		[appDelegate.yummlyRequest reset];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationResetSearch object:nil];
	}
	else if (buttonIndex == actionSheet.cancelButtonIndex)
		;
}


#pragma mark - UIResponder Methods

/**
 *	Notifies the receiver that it has been asked to relinquish its status as first responder in its window.
 *
 *	@return	YES - resigning first responder status or NO, refusing to relinquish first responder status.
 */
- (BOOL)resignFirstResponder
{
	[self.recipeSearchView resignFirstResponder];
	return [super resignFirstResponder];
}

#pragma mark - UITableViewDataSource Methods

/**
 *	Asks the data source to return the number of sections in the table view.
 *
 *	@param	tableView					The number of sections in tableView. The default value is 1.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

/**
 *	Asks the data source for a cell to insert in a particular location of the table view.
 *
 *	@param	tableView					A table-view object requesting the cell.
 *	@param	indexPath					An index path locating a row in tableView.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell				= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	NSArray *arrayForSection			= [self ingredientsArrayForSection:indexPath.section];
	NSString *cellText;
	
	if (arrayForSection.count)
		cellText						= [arrayForSection[indexPath.row][kYummlyMetadataDescriptionKey] capitalizedString];
	else if (indexPath.section == kSectionExcludedIndex)
		cellText						= @"← Include / Exclude Ingredients",
		cell.textLabel.textAlignment	= NSTextAlignmentLeft;
	else if (indexPath.section == kSectionIncludedIndex)
		cellText						= @"Allergy & Dietary Requirements + More →",
		cell.textLabel.textAlignment	= NSTextAlignmentRight;
	
	cell.textLabel.text					= cellText;
	
	cell.selectionStyle					= UITableViewCellSelectionStyleNone;
	
	return cell;
}

/**
 *	Tells the data source to return the number of rows in a given section of a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	section						An index number identifying a section in tableView.
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	if (!self.hasBeenSlid)
		return 1;
	
	NSArray *arrayForSection			= [self ingredientsArrayForSection:section];
	
	return arrayForSection.count;
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
}

/**
 *	Asks the delegate for a view object to display in the header of the specified section of the table view.
 *
 *	@param	tableView					The table-view object asking for the view object.
 *	@param	section						An index number identifying a section of tableView .
 *
 *	@return	A view object to be displayed in the header of section.
 */
- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
	//	get header view object and then just set the title
	UITableViewHeaderFooterView *headerView		= [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
	if (!headerView)
		headerView							= [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderIdentifier];
	
	if ([self ingredientsArrayForSection:section].count == 0)
		headerView.backgroundView				= nil,
		headerView.contentView.backgroundColor	= [UIColor clearColor],
		headerView.textLabel.backgroundColor	= [UIColor clearColor];
	else
	{
		headerView.textLabel.text				= section == kSectionExcludedIndex ? @"Excluded" : @"Required";
		headerView.contentView.backgroundColor	= [[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
		headerView.textLabel.textColor			= [UIColor whiteColor];
	}
	
	return headerView;
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

#pragma mark - View Lifecycle

/**
 *	Notifies the view controller that its view is about to layout its subviews.
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
	[self.recipeSearchView setNeedsUpdateConstraints];
}


@end