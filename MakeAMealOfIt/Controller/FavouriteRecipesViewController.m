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
#import "Recipe+FavouriteState.h"
#import "RecipeCollectionViewCell.h"
#import "RecipeDetailsViewController.h"
#import "UIImageView+Animation.h"
#import "YummlyAttributionViewController.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"FavouriteRecipeCell";

static CGFloat const kEditModeSelectedAlpha		= 01.00f;
static CGFloat const kEditModeUnselectedAlpha	= 00.50f;

#pragma mark - Favourite Recipes View Controller Private Class Extension

@interface FavouriteRecipesViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {}

#pragma mark - Private Properties

/**	The convenient data source to be used for the collectionView.	*/
@property (nonatomic, strong)	ArrayDataSource		*arrayDataSource;
/**	Cancels out of edit mode.	*/
@property (nonatomic, strong)	UIBarButtonItem		*cancelButton;
/**	The collection view that displays the favourite recipes.	*/
@property (nonatomic, strong)	UICollectionView	*collectionView;
/**	Tapped on to allow the user to edit the current favourites.	*/
@property (nonatomic, strong)	UIBarButtonItem		*editButton;
/**	The buttons fisplayed whilst a user is editing their favourites.	*/
@property (nonatomic, strong)	NSArray				*editingToolButtons;
/**	When in edit mode the user can select favourited recipes and remove them.	*/
@property (nonatomic, assign)	BOOL				editMode;
/**	The array of recipes that have been favourited by the user.	*/
@property (nonatomic, strong)	NSMutableArray		*favouriteRecipes;
/**	The index of a recipe to be removed from the view.	*/
@property (nonatomic, assign)	NSUInteger			indexOfRemovedRecipe;
/**	An array of selected index paths.	*/
@property (nonatomic, strong)	NSMutableSet		*indexPathsOfSelectedItems;
/**	The cache used to store thumbnail images for the recipes.	*/
@property (nonatomic, strong)	NSCache				*thumbnailCache;
/**	A button used to unfavourite any selected recipes.	*/
@property (nonatomic, strong)	UIBarButtonItem		*unfavouriteButton;

@end

#pragma mark - Favourite Recipes View Controller Implementation

@implementation FavouriteRecipesViewController {}

#pragma mark - Action & Selector Methods

/**
 *	The user has switched into or out of the edit mode.
 */
- (void)editModeChanged
{
	if (self.editMode)
		[self.slideNavigationItem setRightBarButtonItems:@[self.editButton] animated:YES];
	else
		[self.slideNavigationItem setRightBarButtonItems:self.editingToolButtons animated:YES];
	
	self.editMode						= !self.editMode;
}

/**
 *	Called when a recipe has been added as a favourite.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)recipeAdded:(NSNotification *)notification
{
	self.indexOfRemovedRecipe			= NSUIntegerMax;
}

/**
 *	Called when a recipe has been removed as a favourite.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)recipeRemoved:(NSNotification *)notification
{
	dispatch_async(dispatch_queue_create("Calculate Recipe Removal", NULL),
	^{
		Recipe *recipe					= (Recipe *)notification.object;
		
		self.indexOfRemovedRecipe		= [self.favouriteRecipes indexOfObject:recipe];
	});
}

/**
 *	Unfavourites all currently selected recipes.
 */
- (void)unfavouriteSelectedRecipes
{
	//	if we're not in edit mode this method shouldn't have been called
	NSAssert(self.editMode, @"Unfavouriting recipes called when not in edit mode.");
	
	for (NSIndexPath *indexPath in self.indexPathsOfSelectedItems)
	{
		Recipe *recipe					= self.favouriteRecipes[indexPath.item];
		[recipe unfavourite];
		[self.favouriteRecipes removeObjectAtIndex:indexPath.item];
		[self.arrayDataSource updateWithItems:self.favouriteRecipes];
	}
	
	[self.collectionView deleteItemsAtIndexPaths:self.indexPathsOfSelectedItems.allObjects];
	
	[self.collectionView.visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger index, BOOL *stop)
	{
		cell.alpha						= kEditModeUnselectedAlpha;
	}];
	
	[self.indexPathsOfSelectedItems removeAllObjects];
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
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
																	  options:kNilOptions
																	  metrics:nil views:self.viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
																	  options:kNilOptions
																	  metrics:nil views:self.viewsDictionary]];
}

#pragma mark - Initialisation

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animated					Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animated
{
	[self.slideNavigationItem setRightBarButtonItem:self.editButton];
}

/**
 *	The basic intialisation required for this object.
 */
- (void)basicInitialisation
{
	self.slideNavigationItem.title		= @"Favourites";
	self.indexOfRemovedRecipe			= NSUIntegerMax;
	[self registerForNotifications];
	
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

/**
 *	Adds this view controller as an observer of the appropriate notifications.
 */
- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(recipeAdded:)
												 name:FavouriteRecipesStoreNotificationFavouriteRecipeAdded
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(recipeRemoved:)
												 name:FavouriteRecipesStoreNotificationFavouriteRecipeRemoved
											   object:nil];
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
	{
		__weak FavouriteRecipesViewController *weakSelf	= self;
		
		_arrayDataSource				= [[ArrayDataSource alloc] initWithItems:self.favouriteRecipes
													  cellIdentifier:kCellIdentifier
											   andConfigureCellBlock:^(RecipeCollectionViewCell *cell, Recipe *recipe, NSIndexPath *indexPath)
		{
			if (weakSelf.editMode)
			{
				if ([self.indexPathsOfSelectedItems containsObject:indexPath])
					cell.alpha			= kEditModeSelectedAlpha,
					cell.highlighted	= YES;
				else
					cell.alpha			= kEditModeUnselectedAlpha,
					cell.highlighted	= NO;
			}
			else
				cell.alpha				= 1.0f;
			
			if (!weakSelf.editMode)
			{
				cell.recipeDetails.detailLabel		= nil;
				cell.recipeDetails.mainLabel		= nil;
				cell.recipeDetails.detailLabel.text	= recipe.sourceDictionary[kYummlyRecipeSourceDisplayNameKey];
			}
			else
			{
				cell.recipeDetails.mainLabel.font	= [UIFont fontWithName:cell.recipeDetails.mainLabel.font.fontName size:8.0f];
			}
			cell.recipeDetails.mainLabel.text	= recipe.recipeName;
			
			[cell setBackgroundColourForIndex:indexPath.item];
			
			UIImage *cachedImage		= [self.thumbnailCache objectForKey:recipe.recipeID];
			
			if (cachedImage)
			{
				[cell.thumbnailView setImage:cachedImage animated:YES];
				return;
			}
			
			dispatch_async(dispatch_queue_create("Recipe Image Fetcher", NULL),
			^{
				UIImage *recipeImage	= recipe.recipeImage;
				
				if (!recipeImage)		return;
				dispatch_async(dispatch_get_main_queue(),
				^{
					[cell.thumbnailView setImage:recipeImage animated:YES];
					[weakSelf.thumbnailCache setObject:recipeImage forKey:recipe.recipeID];
					
				});
			});
		}];
	}
	
	return _arrayDataSource;
}

/**
 *	A button that allows a user to cancel out of edit mode.
 *
 *	@return	An intialised UIBarButtonItem that allows the user to enter edit mode.
 */
- (UIBarButtonItem *)cancelButton
{
	if (!_cancelButton)
		_cancelButton						= [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
															  style:UIBarButtonItemStylePlain
															 target:self
															 action:@selector(editModeChanged)];
	
	return _cancelButton;
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
		layout.sectionInset					= UIEdgeInsetsMake(70.0f, 20.0f, 20.0f, 20.0f);
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
 *	A button that allows a user to edit their favourite recipes.
 *
 *	@return	An intialised UIBarButtonItem that allows the user to enter edit mode.
 */
- (UIBarButtonItem *)editButton
{
	if (!_editButton)
		_editButton							= [[UIBarButtonItem alloc] initWithTitle:@"Edit"
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(editModeChanged)];
	
	return _editButton;
}

/**
 *	The buttons fisplayed whilst a user is editing their favourites.
 *
 *	@return	An NSArray with unfavourite and cancel UIBarButtonItems.
 */
- (NSArray *)editingToolButtons
{
	if (!_editingToolButtons)
		_editingToolButtons					= @[self.unfavouriteButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.cancelButton];
	
	return _editingToolButtons;
}

/**
 *	An array of selected index paths.
 *
 *	@return	An array of selected index paths.
 */
- (NSMutableSet *)indexPathsOfSelectedItems
{
	if (!_indexPathsOfSelectedItems)
		_indexPathsOfSelectedItems			= [[NSMutableSet alloc] init];
	
	return _indexPathsOfSelectedItems;
}

/**
 *	The cache used to store thumbnail images for the recipes.
 *
 *	@return	A cache to be used to store and retrieve thumbnails.
 */
- (NSCache *)thumbnailCache
{
	if (!_thumbnailCache)
		_thumbnailCache						= [[NSCache alloc] init];
	
	
	return _thumbnailCache;
}

/**
 *	A button used to unfavourite any selected recipes.
 *
 *	@return	An initialised UIBarButtonItem allowing the user to unfavourite recipes.
 */
- (UIBarButtonItem *)unfavouriteButton
{
	if (!_unfavouriteButton)
		_unfavouriteButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_unfavourite_yummly"] style:UIBarButtonItemStylePlain target:self action:@selector(unfavouriteSelectedRecipes)];
	
	return _unfavouriteButton;
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

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets whether the user can edit the favourited recipes.
 *
 *	@param	editMode					If YES the user can select favourited recipes and remove them.
 */
- (void)setEditMode:(BOOL)editMode
{
	if (_editMode == editMode)			return;
	
	_editMode							= editMode;
	
	[UIView animateWithDuration:0.5f
					 animations:
	^{
		[self.collectionView.collectionViewLayout invalidateLayout];
	}
					 completion:^(BOOL finished)
	{
		[self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
	}];
	
	
	
	if (_editMode)
	{
		self.collectionView.allowsMultipleSelection	= YES;
		
		for (UICollectionViewCell *cell in self.collectionView.visibleCells)
			cell.alpha					= kEditModeUnselectedAlpha;
	}
	else
	{
		self.collectionView.allowsMultipleSelection	= NO;
		self.collectionView.allowsSelection			= YES;
		
		[self.indexPathsOfSelectedItems removeAllObjects];
		
		for (UICollectionViewCell *cell in self.collectionView.visibleCells)
			cell.alpha					= 1.0f;
	}
}

#pragma mark - Slide Navigation Controller Lifecycle

/**
 *	Notifies the view controller that the parent slideNavigationController did close all side views.
 */
- (void)slideNavigationControllerDidClose
{
	if (self.indexOfRemovedRecipe != NSUIntegerMax)
	{
		dispatch_async(dispatch_queue_create("Fetch Favourites", NULL),
		^{
			self.favouriteRecipes			= [[NSMutableArray alloc] initWithArray:[FavouriteRecipesStore favouriteRecipes]];
			[self.arrayDataSource updateWithItems:self.favouriteRecipes];
			NSIndexPath *indexPath			= [NSIndexPath indexPathForItem:self.indexOfRemovedRecipe inSection:0];
			self.indexOfRemovedRecipe		= NSUIntegerMax;
						   
			dispatch_async(dispatch_get_main_queue(),
			^{
				[self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
			});
		});
	}
}

#pragma mark - UICollectionViewDelegate Methods

/**
 *	Tells the delegate that the item at the specified path was deselected.
 *
 *	@param	collectionView			The collection view object that is notifying you of the selection change.
 *	@param	indexPath				The index path of the cell that was deselected.
 */
- (void)	collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.indexPathsOfSelectedItems removeObject:indexPath];
	UICollectionViewCell *cell		= [collectionView cellForItemAtIndexPath:indexPath];
	cell.alpha						= kEditModeUnselectedAlpha;
	cell.highlighted				= NO;
}

/**
 *	Tells the delegate that the item at the specified index path was selected.
 *
 *	@param	collectionview			The collection view object that is notifying you of the selection change.
 *	@param	indexPath				The index path of the cell that was selected.
 */
- (void)  collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.editMode)
	{
		[self.indexPathsOfSelectedItems addObject:indexPath];
		UICollectionViewCell *cell	= [collectionView cellForItemAtIndexPath:indexPath];
		cell.alpha					= kEditModeSelectedAlpha;
		cell.highlighted			= YES;
	}
	
	else
	{
		[collectionView deselectItemAtIndexPath:indexPath animated:NO];
		
		RecipeDetailsViewController *recipeVC	= [[RecipeDetailsViewController alloc] initWithRecipe:self.favouriteRecipes[indexPath.row]];
		
		YummlyAttributionViewController *attributionVC	= [[YummlyAttributionViewController alloc] init];
		
		[self.slideNavigationController pushCentreViewController:recipeVC
										 withRightViewController:attributionVC
														animated:YES];
	}
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
	if (self.editMode)
		return CGSizeMake(120.0f, 120.0f);
	
	return CGSizeMake(280.0f, 280.0f);
	
	if (isFourInchDevice)
		return CGSizeMake(250.0f, 250.0f);
	else
		return CGSizeMake(210.0f, 210.0f);
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

@end