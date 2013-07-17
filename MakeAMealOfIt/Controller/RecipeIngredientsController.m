//
//  RecipeIngredientsController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeIngredientsController.h"

#pragma mark - Constants & Static Variables

/**	The height for the cells displayed in the table view.	*/
static CGFloat const kCellHeight		= 30.0f;
/**	An ID for cells used by this table view (for use in a reuse pool).	*/
NSString *const kCellIdentifier			= @"RecipeIngredientCellIdentifier";
/**	*/
static NSString *const kHeaderIdentifier= @"RecipeIngredientsHeaderIdentifier";

#pragma mark - Recipe Ingredients Controller Private Class Extension

@interface RecipeIngredientsController () {}

#pragma mark - Private Properties

/**	*/
@property (nonatomic, readwrite, assign)	CGFloat	maximumTableViewHeight;

@end

#pragma mark - Recipe Ingredients Controller Implementation

@implementation RecipeIngredientsController {}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	ingredients					The ingredients that this controller is in charge of managing.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithIngredients:(NSArray *)ingredients
{
	if (self = [super init])
	{
		self.ingredients				= ingredients;
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The preferred height for the table view that we manage.
 *
 *	@return	A calculated value for the height required to show each cell in one view.
 */
- (CGFloat)desiredTableViewHeight
{
	//	add 20 for the header view height
	return (self.ingredients.count * kCellHeight) + 100.0f;
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
	if (self.ingredients)
		return 1;
	else
		return 0;
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
	RecipeDetailsIngredientCell *cell	= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	cell.ingredientLine					= self.ingredients[indexPath.row];
	
	NSLog(@"\nINGREDIENT: %@", cell.ingredientLine);
	
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
	self.maximumTableViewHeight			= 20.0f;
	
	return self.ingredients.count;
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
	cell.textLabel.lineBreakMode		= NSLineBreakByWordWrapping;
	cell.textLabel.numberOfLines		= 0;
	cell.textLabel.font					= [UIFont fontWithName:cell.textLabel.font.fontName size:12.0f];
}

#pragma mark - UITableViewDelegate Methods

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
	CGFloat cellHeight					= [RecipeDetailsIngredientCell heightOfCellWithIngredientLine:self.ingredients[indexPath.row]
																	  withSuperviewWidth:tableView.frame.size.width];
	
	self.maximumTableViewHeight			+= cellHeight;
	
	NSLog(@"CONTROLLER - MAX TABLE VIEW: %f", self.maximumTableViewHeight);
	
	if (indexPath.row + 1 == self.ingredients.count)
		if ([self.delegate respondsToSelector:@selector(tableViewHeightCalculated)])
			[self.delegate tableViewHeightCalculated],
			NSLog(@"SENT HEIGHT: %f", self.maximumTableViewHeight);
	
	return cellHeight;
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
	UITableViewHeaderFooterView *headerView	= [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
	if (!headerView)
		headerView							= [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderIdentifier];
	
	headerView.textLabel.text				= @"Ingredients";
	
	return headerView;
}

@end