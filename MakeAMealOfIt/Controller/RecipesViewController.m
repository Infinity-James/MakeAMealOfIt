//
//  RecipesViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "ResultManagementCell.h"
#import "RecipeCollectionViewCell.h"
#import "RecipeDetailsViewController.h"
#import "RecipesViewController.h"
#import "ToolbarLabelYummlyTheme.h"
#import "UIImageView+Animation.h"
#import "YummlyAttributionViewController.h"
#import "YummlyRequest.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier			= @"RecipeCellIdentifier";
static NSString *const kSpecialCellIdentifier	= @"ResultManagementCellIdentifier";

#pragma mark - Recipes View Controller Private Class Extension

@interface RecipesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {}

#pragma mark - Private Properties

/**	*/
@property (nonatomic, assign)	BOOL					internetAccess;
/**	The main view that will show the recipes in an elegant way.	*/
@property (nonatomic, strong)	UICollectionView		*recipesCollectionView;
/**	The cache used to store thumbnail images for the recipes.	*/
@property (nonatomic, strong)	NSCache					*thumbnailCache;
/**	A dictionary to used when creating visual constraints for this view controller.	*/
@property (nonatomic, strong)	NSDictionary			*viewsDictionary;

@end

#pragma mark - Recipes View Controller Implementation

@implementation RecipesViewController {}

#pragma mark - Synthesise Properties

@synthesize searchPhrase				= _searchPhrase;

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
	
	//	get the correct height of the toolbar
	CGFloat toolbarHeight				= self.toolbarHeight;
	
	//	add the collection view to cover the whole main view underlapping the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(height)]" options:kNilOptions metrics:@{@"height": @(toolbarHeight)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animate						Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
{
	//	if our back button property is set we use that, otherwise we just use a blank bar button item
	self.leftButton					= [[UIBarButtonItem alloc] init];
	
	//	this flexible space neatly separates the bar button items
	UIBarButtonItem *flexibleSpace		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	//	this label will be used as the title in the toolbar
	UILabel *title						= [[UILabel alloc] init];
	title.backgroundColor				= [UIColor clearColor];
	
	//	we use the search phrase for the title and calculate the maximum number of character able to be displayed in the title
	NSString *searchTitle				= self.searchPhrase;
	NSUInteger maximumCharacters		= (self.view.bounds.size.width / 10) - 10;
	
	//	limit the title using the calculated number of character
	if (searchTitle.length > maximumCharacters)
	{
		NSRange unneccesaryCharacters	= NSMakeRange(maximumCharacters, searchTitle.length - maximumCharacters);
		searchTitle						= [searchTitle stringByReplacingCharactersInRange:unneccesaryCharacters withString:@""];
	}
	//	use the title in the label, customise it, and then make a bar button item with it
	title.text							= searchTitle;
	title.textAlignment					= NSTextAlignmentCenter;
	[ThemeManager customiseLabel:title withTheme:[[ToolbarLabelYummlyTheme alloc] init]];
	[title sizeToFit];
	UIBarButtonItem *titleItem			= [[UIBarButtonItem alloc] initWithCustomView:title];
	
	//	the right button for this controller will be used to open an attribution view controller
	self.rightButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_attribution_yummly"]
															style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonTapped)];
	
	[self.toolbar setItems:@[self.leftButton, flexibleSpace, titleItem, flexibleSpace, self.rightButton] animated:animate];
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
		self.internetAccess				= YES;
	}
	
	return self;
}

#pragma mark - Recipe Management

/**
 *	Loads more recipes for the collection view.
 */
- (void)loadMoreRecipes
{
	//	make sure the block doesn't have  a strong pointer to us
	__weak RecipesViewController *weakSelf	= self;
	
	//	uses the global yummly request to get more results for out view
	[appDelegate.yummlyRequest getMoreResults:^(BOOL success, NSDictionary *results)
	{
		if (!success)
		{
			self.internetAccess			= NO;
			[self.recipesCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.recipes.count inSection:0]]];
		}
		
		//	adds the newly fetched results to the recipe array
		NSUInteger recipesCount			= weakSelf.recipes.count;
		NSMutableArray *allRecipes		= [weakSelf.recipes mutableCopy];
		[allRecipes addObjectsFromArray:results[kYummlyMatchesArrayKey]];
		weakSelf.recipes				= allRecipes;
		
		//	get an array of index paths to 'insert' into the collection view
		NSMutableArray *indexPaths		= [[NSMutableArray alloc] init];
		
		for (NSUInteger itemIndex = recipesCount; itemIndex < weakSelf.recipes.count; itemIndex++)
			[indexPaths addObject:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
		
		//	on the main thread we insert the new items into the collection view
		dispatch_async(dispatch_get_main_queue(),
		^{
			[weakSelf.recipesCollectionView insertItemsAtIndexPaths:indexPaths];
		});
	}];
}

#pragma mark - Setter & Getter Methods

/**
 *	The main view that will show the recipes in an elegant way.
 *
 *	@return	The collection view showing the recipe thumbnails.
 */
- (UICollectionView *)recipesCollectionView
{
	//	using lazy instantiation to make sure a fully set up collection view is returned
	if (!_recipesCollectionView)
	{
		//	create a layout and set the insets appropriately
		UICollectionViewFlowLayout *layout		= [[UICollectionViewFlowLayout alloc] init];
		layout.sectionInset						= UIEdgeInsetsMake(40.0f, 20.0f, 20.0f, 20.0f);
		//	inialised the collection view, sets this controller as it's datasource and delegate and sets a white background colour
		_recipesCollectionView					= [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		_recipesCollectionView.backgroundColor	= [UIColor whiteColor];
		_recipesCollectionView.dataSource		= self;
		_recipesCollectionView.delegate			= self;
		
		//	registers collection view cell classes that will be used in our collection view
		[_recipesCollectionView registerClass:[RecipeCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
		[_recipesCollectionView registerClass:[ResultManagementCell class] forCellWithReuseIdentifier:kSpecialCellIdentifier];
		
		//	adds the collection view to the main view set up for use in autolayout
		_recipesCollectionView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_recipesCollectionView];
		[self.view sendSubviewToBack:_recipesCollectionView];
	}
	
	return _recipesCollectionView;
}

/**
 *	The search phrase pertaining to the array of recipes to display.
 *
 *	@return	Either a valid search phrase or an empty string, but never a nil object.
 */
- (NSString *)searchPhrase
{
	//	use lazy instantiation to make sure we don't return a nil object
	if (!_searchPhrase)
		_searchPhrase					= [[NSString alloc] init];
	
	return _searchPhrase;
}

/**
 *	Sets the recipes array that we are displaying.
 *
 *	@param	recipes						The returned array of recipes from a search.
 */
- (void)setRecipes:(NSArray *)recipes
{
	NSArray *oldRecipes					= _recipes;
	_recipes							= recipes;
	
	if (!oldRecipes)
		[self.recipesCollectionView reloadData];
}

/**
 *	This is the phrase used when getting the results we are presenting.
 *
 *	@param	searchPhrase				The phrase used in a Yummly recipe search.
 */
- (void)setSearchPhrase:(NSString *)searchPhrase
{
	_searchPhrase						= [searchPhrase capitalizedString];
	
	[self addToolbarItemsAnimated:NO];
}

/**
 *	The cache used to store thumbnail images for the recipes.
 *
 *	@return	A cache to be used to store and retrieve thumbnails.
 */
- (NSCache *)thumbnailCache
{
	if (!_thumbnailCache)
	{
		_thumbnailCache					= [[NSCache alloc] init];
	}
	
	return _thumbnailCache;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"collectionView"	: self.recipesCollectionView,
				@"toolbar"			: self.toolbar};
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
	//	figure out if we are at the end of the collection view content, or if there are no results
	if (!self.recipes.count || indexPath.item == self.recipes.count)
	{
		//	this cell is used to tell the user something special about the results
		ResultManagementCell *resultCell= [collectionView dequeueReusableCellWithReuseIdentifier:kSpecialCellIdentifier forIndexPath:indexPath];
		
		//	if there were no results found, we tell the user
		if (!self.recipes.count)
			[resultCell setInstructionLabelText:@"No Results Were Found"];
		//	if we are at the end of the results 
		else
			[resultCell startLoading],
			[self loadMoreRecipes];
		
		return resultCell;
	}
	
	RecipeCollectionViewCell *cell		= [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	cell.recipeDetails.mainLabel.text	= self.recipes[indexPath.row][kYummlyMatchRecipeNameKey];
	cell.recipeDetails.detailLabel.text	= self.recipes[indexPath.row][kYummlyMatchSourceDisplayNameKey];
	cell.thumbnailView.image			= nil;
	[cell.thumbnailView stopAnimating];
	
	NSString *smallThumbnailURLString	= ((NSArray *)self.recipes[indexPath.row][kYummlyMatchSmallImageURLsArrayKey]).lastObject;
	UIImage *cachedThumbnail				= [self.thumbnailCache objectForKey:smallThumbnailURLString];
	
	if (!cachedThumbnail)
	{
		//	on a separate asynchronous thread we get the url for the image for this cell
		dispatch_async(dispatch_queue_create("Thumbnail URL Fetcher", NULL),
		^{
			NSString *thumbnailURLString= [smallThumbnailURLString stringByReplacingOccurrencesOfString:@".s." withString:@".l."];
			NSURL *thumbnailURL			= [[NSURL alloc] initWithString:thumbnailURLString];
			
			__block NSData *thumbnailData;
						  
			//	on a separate thread we synchronously (for chronology) use the url to get the image data and then create an image with it 
			dispatch_sync(dispatch_queue_create("Thumbnail Data Fetcher", NULL),
			^{
				thumbnailData			= [[NSData alloc] initWithContentsOfURL:thumbnailURL];
				UIImage *thumbnail		= [[UIImage alloc] initWithData:thumbnailData];
				if (thumbnail)
					[self.thumbnailCache setObject:thumbnail forKey:smallThumbnailURLString];
											 
				//	synchronously update imgae views on main thread so it happens chronologically
				dispatch_sync(dispatch_get_main_queue(),
				^{
					[cell.thumbnailView setImage:thumbnail animated:YES];
				});
			});
		});
	}
	
	else
		[cell.thumbnailView setImage:cachedThumbnail animated:YES];
	
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
	//	if there are results being shown, but no internet access, we don't show a 'loading more results' cells
	if (!self.internetAccess && self.recipes.count != 0)
		return self.recipes.count;
	
	//	if there's either no results, or results left to load, we show a loading more results cell or no results cell
	return self.recipes.count + 1;
}

/**
 *	Asks the data source for the number of sections in the collection view.
 *
 *	@param	collectionView				An object representing the collection view requesting this information.
 *
 *	@return	The number of sections in collectionView.
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

#pragma mark - UICollectionViewDelegate Methods

/**
 *	Tells the delegate that the item at the specified path was deselected.
 *
 *	@param	collectionview				The collection view object that is notifying you of the selection change.
 *	@param	indexPath					The index path of the cell that was deselected.
 */
- (void)	collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	
}

/**
 *	Tells the delegate that the item at the specified index path was selected.
 *
 *	@param	collectionview				The collection view object that is notifying you of the selection change.
 *	@param	indexPath					The index path of the cell that was selected.
 */
- (void)  collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	RecipeDetailsViewController *recipeVC	= [[RecipeDetailsViewController alloc] initWithRecipeID:self.recipes[indexPath.row][kYummlyMatchIDKey]
																					  andRecipeName:self.recipes[indexPath.row][kYummlyMatchRecipeNameKey]];
	
	YummlyAttributionViewController *attributionVC	= [[YummlyAttributionViewController alloc] init];
	
	//[appDelegate.slideOutVC showCentreViewController:recipeVC withRightViewController:attributionVC];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

/**
 *	Asks the delegate for the spacing between successive items in the rows or columns of a section.
 *
 *	@param	collectionView				The collection view object displaying the flow layout.
 *	@param	collectionViewLayout		The layout object requesting the information.
 *	@param	section						The index number of the section whose inter-item spacing is needed.
 *
 *	@return	The minimum space (measured in points) to apply between successive items in the lines of a section.
 */
- (CGFloat)				  collectionView:(UICollectionView *)collectionView
								  layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 5.0f;
}

/**
 *	Asks the delegate for the size of the specified item’s cell.
 *
 *	@param	collectionView				The collection view object displaying the flow layout.
 *	@param	collectionViewLayout		The layout object requesting the information.
 *	@param	indexPath					The index path of the item.
 *
 *	@return	The width and height of the specified item. Both values must be greater than 0.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (isFiveInchDevice)
		return CGSizeMake(250.0f, 250.0f);
	else
		return CGSizeMake(210.0f, 210.0f);
}

#pragma mark - UIScrollViewDelegate Methods

/**
 *	Tells the delegate when the user scrolls the content view within the receiver.
 *
 *	@param	scrollView					The scroll-view object in which the scrolling occurred.
 *
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint offset						= scrollView.contentOffset;
    CGRect bounds						= scrollView.bounds;
    CGSize size							= scrollView.contentSize;
    UIEdgeInsets inset					= scrollView.contentInset;
    CGFloat y							= offset.y + bounds.size.height - inset.bottom;
    CGFloat height							= size.height;
	
    CGFloat reloadDistance				= 10;
	
    if (y > height + reloadDistance)
        ;
}*/

#pragma mark - View Lifecycle

/**
 *	Sent to the view controller when the app receives a memory warning.
 */
- (void)didReceiveMemoryWarning
{
	if (!self.view.window)
	{
		
	}
	
	self.thumbnailCache				= nil;
	
	[super didReceiveMemoryWarning];
}

/**
 *	Notifies the view controller that its view is about to layout its subviews.
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self addToolbarItemsAnimated:NO];
}

@end