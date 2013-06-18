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
#import "YummlyAPI.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"ChosenIngredientsCellIdentifier";

#pragma mark - Recipe Search View Controller Private Class Extension

@interface RecipeSearchViewController () <RecipeSearchViewController, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UITableView					*ingredientsTableView;
@property (nonatomic, copy)		LeftControllerDataModified	modifiedIngredients;
@property (nonatomic, strong)	RecipeSearchView			*recipeSearchView;
@property (nonatomic, strong)	NSMutableArray				*selectedIngredients;
@property (nonatomic, strong)	NSDictionary				*viewsDictionary;

@end

#pragma mark - Recipe Search View Controller Implementation

@implementation RecipeSearchViewController {}

#pragma mark - Action & Selector Methods

/**
 *	called when the button in the toolbar for the left panel is tapped
 */
- (void)leftButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	[super leftButtonTapped];
}

/**
 *	called when the button in the toolbar for the right panel is tapped
 */
- (void)rightButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	[super rightButtonTapped];
}

#pragma mark - Autolayout Methods

/**
 *	adds the constraints for the table view and the toolbar
 */
- (void)addConstraintsForMainView
{
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
}

/**
 *	called when the view controller’s view needs to update its constraints
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	[self addConstraintsForMainView];
	
	[self.view bringSubviewToFront:self.toolbar];
}

#pragma mark - Autorotation

/**
 *	returns a boolean value indicating whether rotation methods are forwarded to child view controllers
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	returns whether the view controller’s contents should auto rotate
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

#pragma mark - Initialisation

/**
 *	adds toolbar items to our toolbar
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
	//self.rightButton.selectedImage		= [UIImage imageNamed:@"barbuttonitem_main_selected_selection_yummly"];
	
	[self.toolbar setItems:@[self.leftButton, flexibleSpace, titleItem, flexibleSpace, self.rightButton] animated:animate];
}

#pragma mark - Left Controller Delegate Methods

/**
 * a block sent by the delegate to be executed when data has been modified
 *
 *	@param	dataModifiedBlack			to be executed with modified data
 */
- (void)blockToExecuteWhenDataModified:(LeftControllerDataModified)dataModifiedBlock
{
	//	store the block to execute it later
	self.modifiedIngredients			= dataModifiedBlock;
}

/**
 *	sent to the delegate when a user has updated any selections in the left view controller
 *
 *	@param	leftViewController			the left view controller sending this message
 *	@param	selections					the selections dictionary with all of the selections in the table view
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
 *	called when a view controller was added to recipe search view
 *
 *	@param	viewController				the view controller which was added to the view
 */
- (void)addedViewController:(UIViewController *)viewController
{
	[self addChildViewController:viewController];
	[viewController didMoveToParentViewController:self];
}

/**
 *	called when a search was executed and returned with the results dictionary
 *
 *	@param	results						the dictionary of results from the yummly response
 */
- (void)searchExecutedForResults:(NSDictionary *)results
{
	RecipesViewController *recipesVC	= [[RecipesViewController alloc] init];
	recipesVC.recipes					= results[kYummlyMatchesArrayKey];
	recipesVC.searchPhrase				= [results[@"criteria"][@"terms"] lastObject];
	NSLog(@"%@", recipesVC.searchPhrase);
	[appDelegate.slideOutVC showCentreViewController:recipesVC withRightViewController:[[RecipesViewController alloc] init]];
	
}

#pragma mark - Setter & Getter Methods

/**
 *	the table view representing the chosen ingredients for the recipe search
 */
- (UITableView *)ingredientsTableView
{
	if (!_ingredientsTableView)
	{
		_ingredientsTableView			= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		_ingredientsTableView.bounces	= NO;
		_ingredientsTableView.backgroundColor	= [UIColor whiteColor];
		_ingredientsTableView.backgroundView	= nil;
		_ingredientsTableView.dataSource= self;
		_ingredientsTableView.delegate	= self;
		[_ingredientsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_ingredientsTableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_ingredientsTableView];
	}
	
	return _ingredientsTableView;
}

/**
 *	this is the main view that holds all the stuff
 */
- (RecipeSearchView *)recipeSearchView
{
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
 *	the ingredients selected by the left controller
 */
- (NSMutableArray *)selectedIngredients
{
	if (!_selectedIngredients)
		_selectedIngredients			= [[NSMutableArray alloc] init];
	
	return _selectedIngredients;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeSearchView"	: self.recipeSearchView,
				@"tableView"		: self.ingredientsTableView,
				@"toolbar"			: self.toolbar};
}

#pragma mark - UITableViewDataSource Methods

/**
 *	as the data source, we must define how many sections we want the table view to have
 *
 *	@param	tableView					the table view for which are defining the sections number
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
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
	
	cell.textLabel.text					= [self.selectedIngredients[indexPath.row][kYummlyMetadataDescriptionKey] capitalizedString];
	cell.selectionStyle					= UITableViewCellSelectionStyleNone;
	
	return cell;
}

/**
 *	called to commit the insertion or deletion of a specified row in the receiver
 *
 *	@param	tableView					table view object requesting the insertion or deletion
 *	@param	editingStyle				cell editing style corresponding to a insertion or deletion
 *	@param	indexPath					index path of row requesting editing
 */
- (void) tableView:(UITableView *)				tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)				indexPath
{
	
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
	return self.selectedIngredients.count;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	tells the delegate that the specified row is now selected
 *
 *	@param	tableView					table-view object informing the delegate about the new row selection
 *	@param	indexPath					index path locating the new selected row in table view
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.modifiedIngredients(self.selectedIngredients[indexPath.row]);
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

#pragma mark - View Lifecycle

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
	[self.recipeSearchView setNeedsUpdateConstraints];
}


@end