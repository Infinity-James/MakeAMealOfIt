//
//  RecipesViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "RecipeCollectionViewCell.h"
#import "RecipeDetailsViewController.h"
#import "RecipesViewController.h"
#import "ResultManagementCell.h"
#import "UIImageView+Animation.h"
#import "WebViewController.h"
#import "YummlyAttributionViewController.h"
#import "YummlyRequest.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier			= @"RecipeCellIdentifier";
static NSString *const kSpecialCellIdentifier	= @"ResultManagementCellIdentifier";

#pragma mark - Recipes View Controller Private Class Extension

@interface RecipesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {}

#pragma mark - Private Properties

/**	Whether there are more results available to be loaded or not.*/
@property (nonatomic, assign)	BOOL					moreResultsAvailable;
/**	The main view that will show the recipes in an elegant way.	*/
@property (nonatomic, strong)	UICollectionView		*recipesCollectionView;
/**	The right slide navigation bar button used to slide in the right view.	*/
@property (nonatomic, strong)	UIBarButtonItem			*rightButton;
/**	The cache used to store thumbnail images for the recipes.	*/
@property (nonatomic, strong)	NSCache					*thumbnailCache;

@end

#pragma mark - Recipes View Controller Implementation

@implementation RecipesViewController {}

#pragma mark - Synthesise Properties

@synthesize searchPhrase				= _searchPhrase;

#pragma mark - Action & Selector Methods

/**
 *	Called when the button in the toolbar for the right panel is tapped.
 */
- (void)rightButtonTapped
{
	if (self.slideNavigationController.controllerState == SlideNavigationSideControllerClosed)
		[self.slideNavigationController setControllerState:SlideNavigationSideControllerRightOpen withCompletionHandler:nil];
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
	
	//	add the collection view to cover the whole main view underlapping the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animated					Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animated
{
	[self.slideNavigationItem setTitle:self.searchPhrase animated:animated];
	[self.slideNavigationItem setRightBarButtonItem:self.rightButton animated:animated];
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
		self.moreResultsAvailable		= YES;
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
		NSArray *moreRecipes			= results[kYummlyMatchesArrayKey];
		
		if (!success || moreRecipes.count == 0)
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				self.moreResultsAvailable	= NO;
				[self.recipesCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.recipes.count inSection:0]]];
				return;
			});
		}
		
		//	adds the newly fetched results to the recipe array
		NSUInteger recipesCount			= weakSelf.recipes.count;
		NSMutableArray *allRecipes		= [weakSelf.recipes mutableCopy];
		[allRecipes addObjectsFromArray:moreRecipes];
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

#pragma mark - RightControllerDelegate Methods

/**
 *	Instructs the centre view controller to open a URL in a web view of some sort.
 *
 *	@param	url							An NSURL to open in some sort of web view.
 *	@param	rightViewController			The new right view controller to present alongside the URL in a web view of some sort.
 */
- (void)openURL:(NSURL *)url withRightViewController:(UIViewController *)rightViewController
{
	WebViewController *webViewController= [[WebViewController alloc] initWithURL:url];
	
	//[self.slideNavigationController pushCentreViewController:webViewController withRightViewController:rightViewController animated:YES];
	[self.slideNavigationController setControllerState:SlideNavigationSideControllerClosed withCompletionHandler:
	^{
		[self presentViewController:webViewController animated:YES completion:nil];
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
		layout.sectionInset						= UIEdgeInsetsMake(60.0f, 20.0f, 20.0f, 20.0f);
		//	inialised the collection view, sets this controller as it's datasource and delegate and sets a white background colour
		_recipesCollectionView					= [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		_recipesCollectionView.backgroundColor	= [UIColor whiteColor];
		_recipesCollectionView.dataSource		= self;
		_recipesCollectionView.delegate			= self;
		
		//	registers collection view cell classes that will be used in our collection view
		[_recipesCollectionView registerClass:[ResultManagementCell class] forCellWithReuseIdentifier:kSpecialCellIdentifier];
		[_recipesCollectionView registerClass:[RecipeCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
		
		//	adds the collection view to the main view set up for use in autolayout
		_recipesCollectionView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_recipesCollectionView];
		[self.view sendSubviewToBack:_recipesCollectionView];
	}
	
	return _recipesCollectionView;
}

/**
 *	The right slide navigation bar button used to slide in the right view.
 *
 *	@return	An initialised and targeted UIBarButtonItem to be used as the right bar button item.
 */
- (UIBarButtonItem *)rightButton
{
	if (!_rightButton)
	{
		UIImage *rightButtonImage		= [UIImage imageNamed:@"barbuttonitem_main_normal_attribution_yummly"];
		
		_rightButton					= [[UIBarButtonItem alloc] initWithImage:rightButtonImage
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(rightButtonTapped)];
	}
	
	return _rightButton;
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
	return @{	@"collectionView"	: self.recipesCollectionView	};
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
			[resultCell setInstructionLabelText:NSLocalizedString(@"No Results Were Found", @"no results found for a search")];
		//	if we are at the end of the results 
		else
			[resultCell startLoading],
			[self loadMoreRecipes];
		
		return resultCell;
	}
	
	RecipeCollectionViewCell *cell		= [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	[cell setBackgroundColourForIndex:indexPath.item];
	cell.recipeDetails.mainLabel.text	= self.recipes[indexPath.row][kYummlyMatchRecipeNameKey];
	cell.recipeDetails.detailLabel.text	= self.recipes[indexPath.row][kYummlyMatchSourceDisplayNameKey];
	
	
	[self fetchImageForCell:cell atIndexPath:indexPath];
	
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
	if (!self.moreResultsAvailable && self.recipes.count != 0)
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
 *	Tells the delegate that the item at the specified index path was selected.
 *
 *	@param	collectionview				The collection view object that is notifying you of the selection change.
 *	@param	indexPath					The index path of the cell that was selected.
 */
- (void)  collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.internetConnectionExists)
	{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Connect to the Internet", @"internet is missing")
									message:NSLocalizedString(@"Unfortunately you do not have the internet access required to view this recipe.", @"recipe can't be viewed because there is no internet")
								   delegate:self
						  cancelButtonTitle:NSLocalizedString(@"Understood", @"okay")
						  otherButtonTitles:nil] show];
		return;
	}
	
	RecipeDetailsViewController *recipeVC	= [[RecipeDetailsViewController alloc] initWithRecipeID:self.recipes[indexPath.row][kYummlyMatchIDKey]
																					  andRecipeName:self.recipes[indexPath.row][kYummlyMatchRecipeNameKey]];
	
	YummlyAttributionViewController *attributionVC	= [[YummlyAttributionViewController alloc] init];
	
	[self.slideNavigationController pushCentreViewController:recipeVC
									 withRightViewController:attributionVC
													animated:YES];
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
	return CGSizeMake(280.0f, 280.0f);
	
	if (isFourInchDevice)
		return CGSizeMake(250.0f, 250.0f);
	else
		return CGSizeMake(210.0f, 210.0f);
}

#pragma mark - Utility Methods

/**
 *	Fetches the recipe thumbnail for a given cell at a specific index path.
 *
 *	@param	recipeCell					This is the cell for which we are fetching the image.
 *	@param	indexPath					The index path of the cell which we are getting an image for.
 */
- (void)fetchImageForCell:(RecipeCollectionViewCell *)recipeCell
			  atIndexPath:(NSIndexPath *)indexPath
{
	//	if there is an image set for this cell we nil it out because it has been reused
	recipeCell.thumbnailView.image		= nil;
	[recipeCell.thumbnailView stopAnimating];
	
	BOOL imageBySizeUsed				= NO;
	
	NSDictionary *recipe				= self.recipes[indexPath.row];
	
	NSString *smallThumbnailURLString	= ((NSArray *)recipe[kYummlyMatchSmallImageURLsArrayKey]).lastObject;
	
	if ([smallThumbnailURLString isKindOfClass:[NSNull class]] || !smallThumbnailURLString)
	{
		NSDictionary *images			= recipe[kYummlyMatchImagesBySize];
		smallThumbnailURLString			= [images allValues][0];
		imageBySizeUsed					= YES;
	}
	
	UIImage *cachedThumbnail			= [self.thumbnailCache objectForKey:smallThumbnailURLString];
	
	//	set the url for the cell so we can check it later before setting it
	recipeCell.imageURL					= smallThumbnailURLString;
	
	if (!cachedThumbnail)
	{
		//	on a separate asynchronous thread we get the url for the image for this recipeCell
		dispatch_async(dispatch_queue_create("Thumbnail URL Fetcher", NULL),
		^{
			//	if the image url for this cell has changed since we started fetching it we return
			if (![recipeCell.imageURL isEqualToString:smallThumbnailURLString])
				return;
			
			NSString *thumbnailURLString;
			
			if (!imageBySizeUsed)
				thumbnailURLString		= [smallThumbnailURLString stringByReplacingOccurrencesOfString:@".s." withString:@".l."];
			else
				thumbnailURLString		= [smallThumbnailURLString stringByReplacingOccurrencesOfString:@"s90-c" withString:@"s480-c"];
			
			NSURL *thumbnailURL			= [[NSURL alloc] initWithString:thumbnailURLString];
			
			if (!thumbnailURL)
			{
				thumbnailURLString			= [thumbnailURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				thumbnailURL				= [[NSURL alloc] initWithString:thumbnailURLString];
			}
						   
			__block NSData *thumbnailData;
						   
			//	on a separate thread we synchronously (for chronology) use the url to get the image data and then create an image with it
			dispatch_sync(dispatch_queue_create("Thumbnail Data Fetcher", NULL),
			^{
				//	if the image url for this cell has changed since we started fetching it we return
				if (![recipeCell.imageURL isEqualToString:smallThumbnailURLString])
					return;
				
				thumbnailData			= [[NSData alloc] initWithContentsOfURL:thumbnailURL];
				UIImage *thumbnail		= [[UIImage alloc] initWithData:thumbnailData];
				if (thumbnail)
					[self.thumbnailCache setObject:thumbnail forKey:smallThumbnailURLString];
				
										
				//	synchronously update imgae views on main thread so it happens chronologically
				dispatch_sync(dispatch_get_main_queue(),
				^{
					if ([recipeCell.imageURL isEqualToString:smallThumbnailURLString])
						[recipeCell.thumbnailView setImage:thumbnail animated:YES];
				});
			});
		});
	}
	
	else
		[recipeCell.thumbnailView setImage:cachedThumbnail animated:YES];
}

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