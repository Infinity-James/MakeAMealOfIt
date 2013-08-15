//
//  IntroductionHeaderView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IntroductionHeaderView.h"

@interface IntroductionHeaderView () {}

#pragma mark - Private Properties

/**	A label to be used in the header view, displaying the header text.	*/
@property (nonatomic, strong)	UILabel						*headerLabel;
/**	An image view to be hold the header image.	*/
@property (nonatomic, strong)	UIImageView					*headerImageView;

@end

#pragma mark - Introduction Header View Implementation

@implementation IntroductionHeaderView {}

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
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerLabel]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerLabel]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerImageView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerImageView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self bringSubviewToFront:self.headerLabel];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	An image view to be hold the header image.
 *
 *	@return	An initialised UIImageView to hold a header image.
 */
- (UIImageView *)headerImageView
{
	if (!_headerImageView)
	{
		_headerImageView				= [[UIImageView alloc] init];
		_headerImageView.contentMode	= UIViewContentModeScaleAspectFit;
		
		_headerImageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_headerImageView];
	}
	
	return _headerImageView;
}

/**
 *	A label to be used in the header view, displaying the header text.
 *
 *	@return	An initialised UILabel to be added to the headerView.
 */
- (UILabel *)headerLabel
{
	if (!_headerLabel)
	{
		_headerLabel					= [[UILabel alloc] init];
		_headerLabel.backgroundColor	= [UIColor clearColor];
		_headerLabel.font				= kYummlyBolderFontWithSize(FontSizeForTextStyle(UIFontTextStyleHeadline) * 1.2f);
		_headerLabel.textAlignment		= NSTextAlignmentCenter;
		_headerLabel.textColor			= [UIColor whiteColor];
		
		_headerLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_headerLabel];
	}
	
	return _headerLabel;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"headerImageView"	: self.headerImageView,
			 @"headerLabel"		: self.headerLabel		};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets the image to be displayed in this header view.
 *
 *	@param	headerView					The desired header view image.
 */
- (void)setHeaderImage:(UIImage *)headerImage
{
	if (_headerImage == headerImage)	return;
	
	_headerImage						= headerImage;
	self.headerImageView.image			= _headerImage;
}

/**
 *	Sets the text to be displayed in this header view.
 *
 *	@param	headerText					The desired header view text.
 */
- (void)setHeaderText:(NSString *)headerText
{
	if (_headerText == headerText)		return;
	
	_headerText							= headerText;
	self.headerLabel.text				= _headerText;
}

@end