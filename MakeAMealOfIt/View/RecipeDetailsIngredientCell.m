//
//  RecipeDetailsIngredientCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 17/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsIngredientCell.h"

#pragma mark - Recipe Details Ingredient Cell Private Class Extension

@interface RecipeDetailsIngredientCell () {}

#pragma mark - Private Properties

/**	The main label used to display the ingredient line represent by this cell.	*/
@property (nonatomic, strong)	UILabel		*ingredientLabel;

@end

#pragma mark - Recipe Details Ingredient Cell Implementation

@implementation RecipeDetailsIngredientCell

#pragma mark - Auto Layout Methods

/**
 *	Returns whether the receiver depends on the constraint-based layout system.
 *
 *	@return	YES if the view must be in a window using constraint-based layout to function properly, NO otherwise.
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	Update constraints for the view.
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self removeConstraints:self.constraints];
	[self.contentView removeConstraints:self.constraints];
	
	NSArray *constraints				= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==4)-[ingredientLabel]-(>=20)-|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ingredientLabel]|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The main label used to display the ingredient line represent by this cell.
 *
 *	@return	An initialised and customised UILabel.
 */
- (UILabel *)ingredientLabel
{
	if (!_ingredientLabel)
	{
		_ingredientLabel				= [[UILabel alloc] init];
		_ingredientLabel.font			= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote));
		_ingredientLabel.lineBreakMode	= NSLineBreakByWordWrapping;
		_ingredientLabel.numberOfLines	= 0;
		_ingredientLabel.textAlignment	= NSTextAlignmentLeft;
		_ingredientLabel.textColor		= kDarkGreyColour;
		
		_ingredientLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_ingredientLabel];
	}
	
	return _ingredientLabel;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{ @"ingredientLabel"	: self.ingredientLabel	};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	The setter for the ingredient line to be displayed in the main label of this cell.
 *
 *	@param	An ingredient and it's quantity for a recipe.
 */
- (void)setIngredientLine:(NSString *)ingredientLine
{
	_ingredientLine						= ingredientLine;
	self.ingredientLabel.text			= _ingredientLine;
}

#pragma mark - Utility Methods

/**
 *	Dynamiaclly calculates the desired height of the cell based on the ingredient it will display.
 *
 *	@param	ingredientLine				The ingredient that will be displayed in the main label of this cell.
 *	@param	superviewWidth				The width of the superview holding this cell.
 *
 *	@return	A CGFloat for the desired height of this cell displaying the ingredient (108.0f is the maximum).
 */
+ (CGFloat)heightOfCellWithIngredientLine:(NSString *)ingredientLine
					   withSuperviewWidth:(CGFloat)superviewWidth
{
	CGFloat labelWidth					= superviewWidth - 24.0f;
	CGSize labelContraints				= CGSizeMake(labelWidth, 100.0f);
	
	NSStringDrawingContext *context		= [[NSStringDrawingContext alloc] init];
	
	UIFont *font						= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote));
	
	CGRect labelRect					= [ingredientLine boundingRectWithSize:labelContraints
														options:NSStringDrawingUsesLineFragmentOrigin
													 attributes:@{NSFontAttributeName: font}
														context:context];
	
	return labelRect.size.height + 8.0f;
}

@end