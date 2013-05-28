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

@property (nonatomic, strong)	TextBackingView	*recipeDetails;
@property (nonatomic, strong)	UIImageView		*thumbnailView;

@end