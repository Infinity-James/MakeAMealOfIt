//
//  RecipeCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeCell.h"

#pragma mark - Recipe Cell Private Class Extension

@interface RecipeCell () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Recipe Cell Implementation

@implementation RecipeCell {}

#pragma mark - Auto Layout Methods

/**
 *	returns whether the receiver depends on the constraint-based layout system
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	update constraints for the view
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self.contentView removeConstraints:self.contentView.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the image view
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==10)-[thumbnailView]-(==10)-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.thumbnailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.thumbnailView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
	[self.thumbnailView addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==10)-[thumbnailView]-(==10)-[recipeName]" options:NSLayoutFormatAlignAllTop metrics:nil views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeNameLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-10.0f];
	[self.contentView addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[recipeName]-(==10)-[recipeAuthor]" options:NSLayoutFormatAlignAllLeading metrics:nil views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
}

#pragma mark - Setter & Getter Methods

/**
 *
 */
- (UILabel *)recipeAuthorLabel
{
	if (!_recipeAuthorLabel)
	{
		_recipeAuthorLabel				= [[UILabel alloc] init];
		[_recipeAuthorLabel sizeToFit];
		_recipeAuthorLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_recipeAuthorLabel];
	}
	
	return _recipeAuthorLabel;
}

/**
 *
 */
- (UILabel *)recipeNameLabel
{
	if (!_recipeNameLabel)
	{
		_recipeNameLabel				= [[UILabel alloc] init];
		[_recipeNameLabel sizeToFit];
		_recipeNameLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_recipeNameLabel]; 
	}
	
	return _recipeNameLabel;
}

/**
 *	this thumbnail view will display a small image of the recipe
 */
- (UIImageView *)thumbnailView
{
	if (!_thumbnailView)
	{
		_thumbnailView					= [[UIImageView alloc] init];
		_thumbnailView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_thumbnailView];
	}
	
	return _thumbnailView;
}

/**
 *
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"thumbnailView"	: self.thumbnailView,
				@"recipeName"		: self.recipeNameLabel,
				@"recipeAuthor"		: self.recipeAuthorLabel};
}

#pragma mark - UIView Methods

/**
 *	returns the class used to create the layer for instances of this class
 */
+ (Class)layerClass
{
	return [[ThemeManager sharedTheme] gradientLayer];
}

/**
 *	lays out subviews
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
}

#pragma mark - View-Related Observation Methods

/**
 *	tells the view that its superview changed
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
}

@end