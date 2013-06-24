//
//  ExtraOptionsViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 22/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ExtraOptionsViewController.h"
#import "RecipeSearchParametersViewController.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"OptionsCellIdentifier";

#pragma mark - Extra Options View Controller Private Class Extension

@interface ExtraOptionsViewController () <UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	A dictionary of excluded parameters iwht the parameters name and it's type.	*/
@property (nonatomic, strong)	NSMutableDictionary						*excludedParameters;
/**	A dictionary of included parameters iwht the parameters name and it's type.	*/
@property (nonatomic, strong)	NSMutableDictionary						*includedParameters;
/**	This view controller represents parameters to choose from for recipe searches.	*/
@property (nonatomic, strong)	RecipeSearchParametersViewController	*recipeParametersController;
/**	This table view will be used to show the user the selected options.	*/
@property (nonatomic, strong)	UITableView								*tableView;
/**	A dictionary to be used for auto layout	*/
@property (nonatomic, strong)	NSDictionary							*viewsDictionary;

@end

#pragma mark - Extra Options View Controller Implementation

@implementation ExtraOptionsViewController {}

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
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Panel)-[tableView]|" options:kNilOptions metrics:@{@"Panel": @(kPanelWidth)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(PanelPlus)-[recipeParameters]-|" options:kNilOptions metrics:@{@"PanelPlus": @(kPanelWidth + 20)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView(==100)]-[recipeParameters]-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Autorotation

/**
 *	Returns a Boolean value indicating whether rotation methods are forwarded to child view controllers.
 *
 *	@param	YES if rotation methods are forwarded or NO if they are not.
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	Returns whether the view controller’s contents should auto rotate.
 *
 *	@param	YES if the content should rotate, otherwise NO.
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

#pragma mark - Setter & Getter Methods

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
 *	This view controller represents parameters to choose from for recipe searches.
 *
 *	@return	A fully initialised view controller handling the display of advanced options.
 */
- (RecipeSearchParametersViewController *)recipeParametersController
{
	//	use lazy instantiation to create the view controller and add it as a child of this view controller
	if (!_recipeParametersController)
	{
		_recipeParametersController		= [[RecipeSearchParametersViewController alloc] init];
		_recipeParametersController.view.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_recipeParametersController.view];
		[self addChildViewController:_recipeParametersController];
		[_recipeParametersController didMoveToParentViewController:self];
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
		_tableView						= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		_tableView.backgroundColor		= [UIColor whiteColor];
		_tableView.dataSource			= self;
		_tableView.delegate				= self;
		[self.view addSubview:_tableView];
		
		[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
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
	
	cell.textLabel.text					= @"Cupboard Food";
	
	[ThemeManager customiseTableViewCell:cell withTheme:nil];
	
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
	return 1;
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
 *	Asks the delegate for the height to use for a row in a specified location.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path that locates a row in tableView.
 */
- (CGFloat)	  tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0f;
}

#pragma mark - View Lifecycle

/**
 *	Sent to the view controller when the app receives a memory warning.
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
}

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

/**
 *	Notifies the view controller that its view is about to layout its subviews.
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
}


@end