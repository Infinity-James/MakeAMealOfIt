//
//  RecipesViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RecipeCollectionViewCell.h"
#import "RecipesViewController.h"
#import "YummlyAPI.h"
#import "YummlyRequest.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"RecipeCellIdentifier";

#pragma mark - Recipes View Controller Private Class Extension

@interface RecipesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UIBarButtonItem			*leftButton;
@property (nonatomic, strong)	UICollectionView		*recipesCollectionView;
@property (nonatomic, strong)	UIBarButtonItem			*rightButton;
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
 *	called when the button in the toolbar for the left panel is tapped
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
 *	called when the button in the toolbar for the right panel is tapped
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
	
	CGFloat toolbarHeight				= 44.0f;
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		toolbarHeight					= 32.0f;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(height)][collectionView]|" options:kNilOptions metrics:@{@"height": @(toolbarHeight)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
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

/**
 *	sets the tag of the left bar button item
 */
- (void)setLeftButtonTag:(NSUInteger)tag
{
	self.leftButton.tag					= tag;
}

/**
 *	sets the tag of the right bar button item
 */
- (void)setRightButtonTag:(NSUInteger)tag
{
	self.rightButton.tag				= tag;
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
 *	the setter for the back button declared by the centre view protocol and used to transition to previous controller
 *
 *	@param	backButton					back button which would have been set by 
 */
- (void)setBackButton:(UIBarButtonItem *)backButton
{
	_backButton							= backButton;
	[self addToolbarItemsAnimated:YES];
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
	
	//	on a separate asynchronous thread we get the url for the image for this cell
	dispatch_async(dispatch_queue_create("Thumbnail URL Fetcher", NULL),
	^{
		NSString *thumbnailURLString	= ((NSArray *)self.recipes[indexPath.row][kYummlyMatchSmallImageURLsArrayKey]).lastObject;
		thumbnailURLString				= [thumbnailURLString stringByReplacingOccurrencesOfString:@".s." withString:@".l."];
		NSURL *thumbnailURL				= [[NSURL alloc] initWithString:thumbnailURLString];
					   
		__block NSData *thumbnailData;
					  
		//	on a separate thread we synchronously (for chronology) use the url to get the image data and then create an image with it 
		dispatch_sync(dispatch_queue_create("Thumbnail Data Fetcher", NULL),
		^{
			thumbnailData				= [[NSData alloc] initWithContentsOfURL:thumbnailURL];
			UIImage *thumbnail			= [[UIImage alloc] initWithData:thumbnailData];
										 
			//	synchronously update imgae views on main thread so it happens chronologically
			dispatch_sync(dispatch_get_main_queue(),
			^{
				//	only update the cell if it is visible
				if ([collectionView.visibleCells containsObject:cell])
				{
					[cell.thumbnailView.layer removeAllAnimations];
					[RecipesViewController animateSettingImageView:cell.thumbnailView withImage:thumbnail];
				}
			});
		});
	});
	
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
	
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

/**
 *
 *
 *	@param
 *	@param
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

#pragma mark - Utility Methods

/**
 *	animates the setting of an image in an image view
 *
 *	@param	imageView					the image view whose image we will set and animate
 *	@param	image						the image we want to animate into the image view
 */
+ (void)animateSettingImageView:(UIImageView *)imageView
					  withImage:(UIImage *)image
{
	imageView.image						= image;
	
	CATransition *transition			= [CATransition animation];
	transition.duration					= 0.3f;
	transition.timingFunction			= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type						= kCATransitionFade;
	
	[imageView.layer addAnimation:transition forKey:nil];
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
	self.view.backgroundColor	= [UIColor whiteColor];
	[self addToolbarItemsAnimated:NO];
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