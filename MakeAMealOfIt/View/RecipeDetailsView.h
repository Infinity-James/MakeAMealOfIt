//
//  RecipeDetailsView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Recipe.h"

#pragma mark - Recipe Details View Public Interface

@interface RecipeDetailsView : UIView  <RecipeDelegate> {}

#pragma mark - Public Properties

@property (nonatomic, readonly, strong)	Recipe	*recipe;

#pragma mark - Public Methods

- (instancetype)initWithRecipe:(Recipe *)recipe;

@end