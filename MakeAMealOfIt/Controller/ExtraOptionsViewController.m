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

@property (nonatomic, strong)	RecipeSearchParametersViewController	*recipeParametersController;
@property (nonatomic, strong)	UITableView								*tableView;
@property (nonatomic, strong)	NSDictionary							*viewsDictionary;

@end

#pragma mark - Extra Options View Controller Implementation

@implementation ExtraOptionsViewController {}

#pragma mark - Autolayout Methods

/**
 *	called when the view controller’s view needs to update its constraints
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	NSArray *constraints;
	
	//	add the table view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Panel)-[tableView]|" options:kNilOptions metrics:@{@"Panel": @(kPanelWidth)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(PanelPlus)-[recipeParameters]-|" options:kNilOptions metrics:@{@"PanelPlus": @(kPanelWidth + 20)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView(==100)]-[recipeParameters]-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
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

#pragma mark - Setter & Getter Methods

/**
 *	this view controller represents parameters to choose from for recipe searches
 */
- (RecipeSearchParametersViewController *)recipeParametersController
{
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
 *	this is the main table view for this view controller
 */
- (UITableView *)tableView
{
	if (!_tableView)
	{
		_tableView						= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		_tableView.dataSource			= self;
		_tableView.delegate				= self;
		[self.view addSubview:_tableView];
		
		[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
	}
	
	return _tableView;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeParameters"	: self.recipeParametersController.view,
				@"tableView"		: self.tableView};
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
	
	cell.textLabel.text					= @"Cupboard Food";
	
	[ThemeManager customiseTableViewCell:cell withTheme:nil];
	
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
	return 1;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	handle the fact that a cell was just selected
 *
 *	@param	tableView					the table view containing selected cell
 *	@param	indexPath					the index path of the cell that was selected
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

/**
 *	define the height of the cell
 *
 *	@param	tableView					the view which owns the cell for which we need to define the height
 *	@param	indexPath					index path of the cell
 */
- (CGFloat)	  tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0f;
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