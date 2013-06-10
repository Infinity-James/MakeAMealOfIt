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
#import "UIImageView+Animation.h"
#import "YummlyAPI.h"
#import "YummlyRequest.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"RecipeCellIdentifier";

#pragma mark - Recipes View Controller Private Class Extension

@interface RecipesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UICollectionView		*recipesCollectionView;
@property (nonatomic, strong)	NSCache					*thumbnailCache;
@property (nonatomic, strong)	UIToolbar				*toolbar;
@property (nonatomic, strong)	NSDictionary			*viewsDictionary;

@end

#pragma mark - Recipes View Controller Implementation

@implementation RecipesViewController {}

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
	
	//	add the collection view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	CGFloat toolbarHeight				= self.toolbarHeight;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(height)][collectionView]|" options:kNilOptions metrics:@{@"height": @(toolbarHeight)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	adds toolbar items to our toolbar
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
{
	if (self.backButton)
		self.leftButton					= self.backButton;
	else
		self.leftButton					= [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(leftButtonTapped)];
	
	UIBarButtonItem *flexibleSpace		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	self.rightButton					= [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonTapped)];
	
	[self.toolbar setItems:@[self.leftButton, flexibleSpace, self.rightButton] animated:animate];
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
 *	the main view that will show the recipes in an elegant way
 */
- (UICollectionView *)recipesCollectionView
{
	if (!_recipesCollectionView)
	{
		UICollectionViewFlowLayout *layout	= [[UICollectionViewFlowLayout alloc] init];
		layout.sectionInset				= UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f);
		_recipesCollectionView			= [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		_recipesCollectionView.backgroundColor	= [UIColor whiteColor];
		_recipesCollectionView.dataSource		= self;
		_recipesCollectionView.delegate	= self;
		
		[_recipesCollectionView registerClass:[RecipeCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
		
		_recipesCollectionView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_recipesCollectionView];
	}
	
	return _recipesCollectionView;
}

/**
 *	sets the recipes array that we are displaying
 *
 *	@param	recipes						the returned array of recipes from a search
 */
- (void)setRecipes:(NSArray *)recipes
{
	_recipes							= recipes;
	[self.recipesCollectionView reloadData];
}

/**
 *	the cache used to store thumbnail images for the recipes
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
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"collectionView"	: self.recipesCollectionView,
				@"toolbar"			: self.toolbar};
}

#pragma mark - UICollectionViewDataSource Methods

/**
 *	as the data source we return the cell that corresponds to the specified item in the collection view
 *
 *	@param	collectionView				object representing the collection view requesting this information
 *	@param	indexPath					index path that specifies the location of the item
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	RecipeCollectionViewCell *cell		= [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	if (!self.recipes.count)
	{
		cell.recipeDetails.mainLabel.text	= @"No Results Found";
		return cell;
	}
	
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
 *	as the data source we return number of items in the specified section
 *
 *	@param	collectionView				object representing the collection view requesting this information
 *	@param	section						index identifying section in collection view
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section
{
	if (self.recipes.count)
		return self.recipes.count;
	
	//	if there are no recipes we want to use a cell to the the user that there were no results
	return 1;
}

/**
 *	returns number of sections in collection view
 *
 *	@param	collectionView				object representing the collection view requesting this information
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

#pragma mark - UICollectionViewDelegate Methods



/**
 *	called when the item at the specified index path was deselected
 *
 *	@param	collectionview				collection view object that is notifying us of the selection change
 *	@param	indexPath					index path of the cell that was deselected
 */
- (void)	collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	
}


/**
 *	called when the item at the specified index path was selected
 *
 *	@param	collectionview				collection view object that is notifying us of the selection change
 *	@param	indexPath					index path of the cell that was selected
 */
- (void)  collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	RecipeDetailsViewController *recipeVC	= [[RecipeDetailsViewController alloc] initWithRecipeID:self.recipes[indexPath.row][kYummlyMatchIDKey]
																					  andRecipeName:self.recipes[indexPath.row][kYummlyMatchRecipeNameKey]];
	[appDelegate.slideOutVC showCentreViewController:recipeVC withRightViewController:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

/**
 *	asks the delegate for the spacing between successive items in the rows or columns of a section
 *
 *	@param	collectionView				collection view object displaying the flow layout
 *	@param	collectionViewLayout		layout object requesting the information
 *	@param	section						index number of the section whose inter-item spacing is needed
 */
- (CGFloat)				  collectionView:(UICollectionView *)collectionView
								  layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 5.0f;
}

/**
 *	returns the size of the specified item’s cell
 *
 *	@param	collectionView				collection view object displaying the flow layout
 *	@param	collectionViewLayout		layout object requesting the information
 *	@param	indexPath					index path of the item
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
 *	tells delegate when the user scrolls the content view within the receiver
 *
 *	@param	scrollView					scroll-view object in which the scrolling occurred
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint offset						= scrollView.contentOffset;
    CGRect bounds						= scrollView.bounds;
    CGSize size							= scrollView.contentSize;
    UIEdgeInsets inset					= scrollView.contentInset;
    CGFloat y							= offset.y + bounds.size.height - inset.bottom;
    CGFloat h							= size.height;
	
    CGFloat reloadDistance				= 10;
	
    if(y > h + reloadDistance)
        NSLog(@"load more rows");
}

@end