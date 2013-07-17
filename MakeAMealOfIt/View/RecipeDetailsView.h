//
//  RecipeDetailsView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Recipe.h"

#pragma mark - 

@protocol RecipeDetailsViewDelegate <NSObject>

- (void)updatedIntrinsicContentSize;

@end

#pragma mark - Recipe Details View Public Interface

@interface RecipeDetailsView : UIView  {}

#pragma mark - Public Properties

@property (nonatomic, readonly, strong)	Recipe	*recipe;

#pragma mark - Public Methods

- (instancetype)initWithRecipe:(Recipe *)recipe;
- (void)recipeDictionaryHasLoaded;

@end