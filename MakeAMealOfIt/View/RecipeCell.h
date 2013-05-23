//
//  RecipeCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Recipe Cell Public Interface

@interface RecipeCell : UITableViewCell {}

#pragma mark - Public Properties

@property (nonatomic, strong)	UILabel			*recipeAuthorLabel;
@property (nonatomic, strong)	UILabel			*recipeNameLabel;
@property (nonatomic, strong)	UIImageView		*thumbnailView;

@end