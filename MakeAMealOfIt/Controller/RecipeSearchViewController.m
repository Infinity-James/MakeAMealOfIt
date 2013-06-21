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

static NSString *const kCellIdentifier	= @"ChosenIngredientsCellIdentifier";

#pragma mark - Recipe Search View Controller Private Class Extension

@interface RecipeSearchViewController () <RecipeSearchViewController, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	The table view representing the chosen ingredients for the recipe search.	*/
@property (nonatomic, strong)	UITableView					*ingredientsTableView;
/**	A block to call when any left controller sata has been modified in this view controller.	*/
@property (nonatomic, copy)		LeftControllerDataModified	modifiedIngredients;
/**	This is the main view that allows the user to search.	*/
@property (nonatomic, strong)	RecipeSearchView			*recipeSearchView;
/**	An array of ingredients to include in the recipes we search for.	*/
@property (nonatomic, strong)	NSMutableArray				*selectedIngredients;

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
 *	cClled when the button in the toolbar for the right panel is tapped.
 */
- (void)rightButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	[super rightButtonTapped];
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
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(height)][recipeSearchView(==150)]-[tableView]|" options:kNilOptions metrics:@{@"height": @(toolbarHeight)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	[self.view bringSubviewToFront:self.toolbar];
}

#pragma mark - Initialisation

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
	
	self.rightButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_selected_selection_yummly"]
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
	NSArray *addedSelections			= selections[kAddedSelections];
	NSArray *removedSelections			= selections[kRemovedSelections];
	
	//	asynchronously add the selections to the yummly request and update our array for the table view
	dispatch_async(dispatch_queue_create("Updating Yummly Request", NULL),
	^{
		if (addedSelections)
		{
			[self.selectedIngredients addObjectsFromArray:addedSelections];
			for (NSDictionary *ingredientDictionary in addedSelections)
				[appDelegate.yummlyRequest addDesiredIngredient:ingredientDictionary[kYummlyMetadataSearchValueKey]];
		}
		if (removedSelections)
		{
			[self.selectedIngredients removeObjectsInArray:removedSelections];
			for (NSDictionary *ingredientDictionary in removedSelections)
				[appDelegate.yummlyRequest removeDesiredIngredient:ingredientDictionary[kYummlyMetadataSearchValueKey]];
		}
		
		//	reload the table view on the main thread
		[self.ingredientsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
 *	The table view representing the chosen ingredients for the recipe search.
 *
 *	@return	An initialised and designed table view for use showing included ingredients.
 */
- (UITableView *)ingredientsTableView
{
	//	use lazy instantiation to set up the table view
	if (!_ingredientsTableView)
	{
		_ingredientsTableView					= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		_ingredientsTableView.bounces			= NO;
		_ingredientsTableView.backgroundColor	= [UIColor whiteColor];
		_ingredientsTableView.backgroundView	= nil;
		
		//	we are in complete control of this table view
		_ingredientsTableView.dataSource		= self;
		_ingredientsTableView.delegate			= self;
		
		//	the only type of cell this table view uses is the standard one
		[_ingredientsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_ingredientsTableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_ingredientsTableView];
	}
	
	return _ingredientsTableView;
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
- (NSMutableArray *)selectedIngredients
{
	if (!_selectedIngredients)
		_selectedIngredients			= [[NSMutableArray alloc] init];
	
	return _selectedIngredients;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeSearchView"	: self.recipeSearchView,
				@"tableView"		: self.ingredientsTableView,
				@"toolbar"			: self.toolbar};
}

#pragma mark - UITableViewDataSource Methods

/**
 *	Asks the data source to return the number of sections in the table view.
 *
 *	@param	tableView					The number of sections in tableView. The default value is 1.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
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
	
	cell.textLabel.text					= [self.selectedIngredients[indexPath.row][kYummlyMetadataDescriptionKey] capitalizedString];
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
	return self.selectedIngredients.count;
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
	self.modifiedIngredients(self.selectedIngredients[indexPath.row]);
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