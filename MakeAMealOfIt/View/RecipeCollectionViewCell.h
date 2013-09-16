//
//  RecipeCollectionViewCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 24/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "TextBackingView.h"

#pragma mark - Recipe Collection View Cell Public Interface

@interface RecipeCollectionViewCell : UICollectionViewCell {}

#pragma mark - Public Properties

/**	The URL of the image currently being fetched for this cell.	*/
@property (nonatomic, strong)	NSString		*imageURL;
/**	A view used to display the name and details of the recipe being displayed.	*/
@property (nonatomic, strong)	TextBackingView	*recipeDetails;
/**	Whether this cell is currently being edited.	*/
@property (nonatomic, assign)	BOOL			selectedToEdit;
/**	The image view used to hold a thumbnail of the recipe being displayed.	*/
@property (nonatomic, strong)	UIImageView		*thumbnailView;

#pragma mark - Public Methods

/**
 *	A convenient way to get the correct background colour for a certain index.
 *
 *	@param	index						The index of the cell for which to return the colour.
 */
- (void)setBackgroundColourForIndex:(NSUInteger)index;

@end