//
//  RecipesViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeCell.h"
#import "RecipesViewController.h"
#import "YummlyAPI.h"
#import "YummlyRequest.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"RecipeCellIdentifier";

#pragma mark - Recipes View Controller Private Class Extension

@interface RecipesViewController () <UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UIBarButtonItem			*leftButton;
@property (nonatomic, strong)	UIBarButtonItem			*rightButton;
@property (nonatomic, strong)	UITableView				*tableView;
@property (nonatomic, strong)	UIToolbar				*toolbar;
@property (nonatomic, strong)	NSDictionary			*viewsDictionary;

@end

#pragma mark - Recipes View Controller Implementation

@implementation RecipesViewController {}

#pragma mark - Synthesis Properties

@synthesize backButton					= _backButton;
@synthesize movingViewBlock				= _movingViewBlock;

#pragma mark - Action & Selector Methods

/**
 *
 */
- (void)leftButtonTapped
{
	if (!self.movingViewBlock)			return;
	
	switch (self.leftButtonTag)
	{
		case kButtonInUse:		self.movingViewBlock(MovingViewOriginalPosition);	break;
		case kButtonNotInUse:	self.movingViewBlock(MovingViewRight);				break;
		default:																	break;
	}
}

/**
 *
 */
- (void)rightButtonTapped
{
	if (!self.movingViewBlock)			return;
	
	switch (self.rightButtonTag)
	{
		case kButtonInUse:		self.movingViewBlock(MovingViewOriginalPosition);	break;
		case kButtonNotInUse:	self.movingViewBlock(MovingViewLeft);				break;
		default:																	break;
	}
}

#pragma mark - CentreViewControllerProtocol Methods

/**
 *	returns the left button tag
 */
- (NSUInteger)leftButtonTag
{
	return self.leftButton.tag;
}

/**
 *	returns right button tag
 */
- (NSUInteger)rightButtonTag
{
	return self.rightButton.tag;
}

- (void)setLeftButtonTag:(NSUInteger)tag
{
	self.leftButton.tag					= tag;
}

- (void)setRightButtonTag:(NSUInteger)tag
{
	self.rightButton.tag				= tag;
}

#pragma mark - Convenience & Helper Methods

#pragma mark - Initialisation

/**
 *	adds toolbar items to our toolbar
 */
- (void)addToolbarItems
{
	if (self.backButton)
		self.leftButton					= self.backButton;
	else
		self.leftButton					= [[UIBarButtonItem alloc] initWithTitle:@"Cupboard" style:UIBarButtonItemStyleBordered target:self action:@selector(leftButtonTapped)];
	
	UIBarButtonItem *flexibleSpace		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	self.rightButton					= [[UIBarButtonItem alloc] initWithTitle:@"Fridge" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonTapped)];
	
	self.toolbar.items					= @[self.leftButton, flexibleSpace, self.rightButton];
}

/**
 *	called to initialise a class instance
 */
- (id)init
{
	if (self = [super init])
	{
		
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *
 *
 *	@param
 */
- (void)setBackButton:(UIBarButtonItem *)backButton
{
	_backButton							= backButton;
	[self addToolbarItems];
}

/**
 *
 *
 *	@param
 */
- (void)setRecipes:(NSArray *)recipes
{
	_recipes							= recipes;
	[self.tableView reloadData];
	NSLog(@"Recipes: %@", recipes);
}
/**
 *	this is hte main table view for this view controller
 */
- (UITableView *)tableView
{
	if (!_tableView)
	{
		_tableView						= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.dataSource			= self;
		_tableView.delegate				= self;
		[self.view addSubview:_tableView];
		
		[_tableView registerClass:[RecipeCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
	}
	
	return _tableView;
}

/**
 *	a toolbar to keep at the top of the view
 */
- (UIToolbar *)toolbar
{
	if (!_toolbar)
	{
		_toolbar						= [[UIToolbar alloc] init];
		_toolbar.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_toolbar];
	}
	
	return _toolbar;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"tableView"	: self.tableView,
				@"toolbar"		: self.toolbar};
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
	RecipeCell *cell					= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	cell.recipeNameLabel.text			= self.recipes[indexPath.row][kYummlyMatchRecipeNameKey];
	cell.recipeNameLabel.font			= [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
	cell.recipeAuthorLabel.text			= self.recipes[indexPath.row][kYummlyMatchSourceDisplayNameKey];
	cell.recipeAuthorLabel.font			= [UIFont fontWithName:@"AvenirNext-Medium" size:10.0f];
	
	cell.accessoryType					= UITableViewCellAccessoryDisclosureIndicator;
	
	//	on separate thread we pull the image for this cell
	dispatch_async(dispatch_queue_create("Thumbnail URL Fetcher", NULL),
	^{
		NSString *thumbnailURLString	= ((NSArray *)self.recipes[indexPath.row][kYummlyMatchSmallImageURLsArrayKey]).lastObject;
		NSURL *thumbnailURL				= [[NSURL alloc] initWithString:thumbnailURLString];
		
		__block NSData *thumbnailData;
		
		dispatch_sync(dispatch_queue_create("Thumbnail Data Fetcher", NULL),
		^{
			thumbnailData				= [[NSData alloc] initWithContentsOfURL:thumbnailURL];
			UIImage *thumbnail			= [[UIImage alloc] initWithData:thumbnailData];
			
			dispatch_sync(dispatch_get_main_queue(),
			^{
				cell.thumbnailView.image= thumbnail;
			});
		});
	});
	
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
	return self.recipes.count;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	asks data source to commit the insertion or deletion of a specified row in the receiver
 *
 *	@param	tableView					table view object requesting the insertion or deletion
 *	@param	editingStyle				cell editing style corresponding to a insertion or deletion requested
 *	@param	indexPath					index path locating the row in tableview requesting edit
 */
-  (void)tableView:(UITableView *)				tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)				indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

/**
 *	handle the fact that a cell was just selected
 *
 *	@param	tableView					the table view containing selected cell
 *	@param	indexPath					the index path of the cell that was selected
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	return 80.0f;
}

#pragma mark - NSLayoutConstraint Methods

/**
 *	adds the constraints for the table view and the toolbar
 */
- (void)addConstraintsForTableView
{
	NSArray *constraints;
	
	//	add the table view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(==44)][tableView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
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
	
	[self addConstraintsForTableView];
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
	[self addToolbarItems];
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