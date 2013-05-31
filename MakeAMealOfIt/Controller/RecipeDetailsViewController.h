//
//  RecipeDetailsViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UICentreViewController.h"

#pragma mark - Recipe Details VC Public Interface

@interface RecipeDetailsViewController : UICentreViewController{}

#pragma mark - Public Properties

- (instancetype)initWithRecipeID:(NSString *)recipeID;

@end