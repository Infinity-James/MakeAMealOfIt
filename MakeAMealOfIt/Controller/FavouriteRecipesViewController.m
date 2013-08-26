//
//  FavouriteRecipeViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ArrayDataSource.h"
#import "FavouriteRecipesStore.h"
#import "FavouriteRecipesViewController.h"
#import "RecipeCollectionViewCell.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"FavouriteRecipeCell";

#pragma mark - Favourite Recipes View Controller Private Class Extension

@interface FavouriteRecipesViewController () <UICollectionViewDelegate> {}

#pragma mark - Private Properties

/**	The convenient data source to be used for the collectionView.	*/
@property (nonatomic, strong)	ArrayDataSource		*arrayDataSource;
/**	The collection view that displays the favourite recipes.	*/
@property (nonatomic, strong)	UICollectionView	*collectionView;
/**	The array of recipes that have been favourited by the user.	*/
@property (nonatomic, strong)	NSMutableArray		*favouriteRecipes;

@end

#pragma mark - Favourite Recipes View Controller Implementation

@implementation FavouriteRecipesViewController {}

#pragma mark - Autolayout Methods

/**
 *	Called when the view controller’s view needs to update its constraints.
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
																	  options:kNilOptions
																	  metrics:nil views:self.viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
																	  options:kNilOptions
																	  metrics:nil views:self.viewsDictionary]];
}

#pragma mark - Initialisation

/**
 *	The basic intialisation required for this object.
 */
- (void)basicInitialisation
{
	dispatch_async(dispatch_queue_create("Fetch Favourites", NULL),
	^{
		self.favouriteRecipes			= [[NSMutableArray alloc] initWithArray:[FavouriteRecipesStore favouriteRecipes]];
		
		dispatch_async(dispatch_get_main_queue(),
		^{
			self.collectionView.dataSource	= self.arrayDataSource;
			self.collectionView.delegate	= self;
		});
	});
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
		[self basicInitialisation];
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The convenient data source to be used for the collectionView.
 *
 *	@return	The array data source to be used for the collectionView.
 */
- (ArrayDataSource *)arrayDataSource
{
	if (!_arrayDataSource)
		_arrayDataSource				= [[ArrayDataSource alloc] initWithItems:self.favouriteRecipes
													  cellIdentifier:kCellIdentifier
											   andConfigureCellBlock:^(RecipeCollectionViewCell *cell, Recipe *recipe)
		{
			cell.recipeDetails.mainLabel.text	= recipe.recipeName;
			cell.recipeDetails.detailLabel.text	= recipe.sourceDictionary[kYummlyRecipeSourceDisplayNameKey];
			[cell setBackgroundColourForIndex:[self.favouriteRecipes indexOfObject:recipe]];
			
			dispatch_async(dispatch_queue_create("Recipe Image Fetcher", NULL),
			^{
				UIImage *recipeImage	= recipe.recipeImage;
				
				dispatch_async(dispatch_get_main_queue(),
				^{
					cell.thumbnailView	= [[UIImageView alloc] initWithImage:recipeImage];
				});
			});
		}];
	
	return _arrayDataSource;
}

/**
 *	The collection view that displays the favourite recipes.
 *
 *	@return	The collection view that displays the favourite recipes.
 */
- (UICollectionView *)collectionView
{
	if (!_collectionView)
	{
		//	create a layout and set the insets appropriately
		UICollectionViewFlowLayout *layout	= [[UICollectionViewFlowLayout alloc] init];
		layout.sectionInset					= UIEdgeInsetsMake(60.0f, 20.0f, 20.0f, 20.0f);
		//	inialised the collection view, sets this controller as it's datasource and delegate and sets a white background colour
		_collectionView						= [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		_collectionView.backgroundColor		= [UIColor whiteColor];
		
		//	registers collection view cell classes that will be used in our collection view
		[_collectionView registerClass:[RecipeCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
		
		//	adds the collection view to the main view set up for use in autolayout
		_collectionView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_collectionView];
		[self.view sendSubviewToBack:_collectionView];
	}
	
	return _collectionView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"collectionView"	: self.collectionView};
}

@end