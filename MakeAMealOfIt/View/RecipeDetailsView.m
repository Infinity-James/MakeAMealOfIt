//
//  RecipeDetailsView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsView.h"

#pragma mark - Recipe Details View Private Class Extension

@interface RecipeDetailsView () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UIImageView				*recipeImageView;

@end

#pragma mark - Recipe Details View Implementation

@implementation RecipeDetailsView {}

#pragma mark - Initialisation
/**
 *	called to initialise a class instance
 */
- (instancetype)initWithRecipeDictionary:(NSDictionary *)recipeDictionary
{
	if (self = [super init])
	{
		
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	the image view holding the main image for the recipe being represented
 */
- (UIImageView *)recipeImageView
{
	if (!_recipeImageView)
	{
		_recipeImageView				= [[UIImageView alloc] init];
		_recipeImageView.contentMode	= UIViewContentModeScaleToFill;
		
		_recipeImageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_recipeImageView];
	}
	
	return _recipeImageView;
}

@end