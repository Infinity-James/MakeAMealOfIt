//
//  IntroductionPanelView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IntroductionPanelView.h"

#pragma mark - Introduction Panel View Private Class Extension

@interface IntroductionPanelView () {}

#pragma mark - Private Properties

/**	A UITextView to hold the description of the panel.	*/
@property (nonatomic, strong)	UITextView	*descriptionTextView;
/**	A UIImageView to hold the image for this panel.	*/
@property (nonatomic, strong)	UIImageView	*imageView;
/**	A UILabel to hold the title of this panel.	*/
@property (nonatomic, strong)	UILabel		*titleLabel;

@end

#pragma mark - Introduction Panel View Implementation

@implementation IntroductionPanelView {}

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
	
	CGFloat imageHeight					= self.bounds.size.height / 2.5f;
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeCenterX
													multiplier:1.0f
													  constant:0.0f]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]-|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[imageView(==imageHeight)]-(15)-[title]-(10)-[description]-|"
																 options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
																 metrics:@{@"imageHeight"	: @(imageHeight)	}
																   views:self.viewsDictionary]];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	title						The title of this panel.
 *	@param	description					The description of this panel.
 *	@param	image						The image for this panel.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description andImage:(UIImage *)image
{
	if (self = [super init])
	{
		self.description				= description;
		self.image						= image;
		self.title						= title;
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	A UITextView to hold the description of the panel.
 *
 *	@return	An initialised and configured UITextView.
 */
- (UITextView *)descriptionTextView
{
	if (!_descriptionTextView)
	{
		_descriptionTextView					= [[UITextView alloc] init];
		_descriptionTextView.backgroundColor	= [UIColor clearColor];
		_descriptionTextView.editable			= NO;
		_descriptionTextView.font				= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody));
		_descriptionTextView.scrollEnabled		= YES;
		_descriptionTextView.textAlignment		= NSTextAlignmentCenter;
		_descriptionTextView.textColor			= [UIColor whiteColor];
		_descriptionTextView.userInteractionEnabled	= YES;
		
		_descriptionTextView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_descriptionTextView];
	}
	
	return _descriptionTextView;
}

/**
 *	A UIImageView to hold the image for this panel.
 *
 *	@return	An initialised and configured UIImageView.
 */
- (UIImageView *)imageView
{
	if (!_imageView)
	{
		_imageView						= [[UIImageView alloc] init];
		_imageView.backgroundColor		= [UIColor clearColor];
		_imageView.contentMode			= UIViewContentModeScaleAspectFit;
		_imageView.layer.cornerRadius	= 3.0f;
		
		_imageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_imageView];
	}
	
	return _imageView;
}

/**
 *	A UILabel to hold the title of this panel.
 *
 *	@return	An initialised and configured UILabel.
 */
- (UILabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel						= [[UILabel alloc] init];
		_titleLabel.backgroundColor		= [UIColor clearColor];
		_titleLabel.lineBreakMode		= NSLineBreakByWordWrapping;
		_titleLabel.font				= kYummlyBolderFontWithSize(FontSizeForTextStyle(UIFontTextStyleSubheadline));
		_titleLabel.numberOfLines		= 0;
		_titleLabel.textAlignment		= NSTextAlignmentCenter;
		_titleLabel.textColor			= [[UIColor alloc] initWithRed:011.0f / 255.0f green:156.0f / 255.0f blue:218.0f / 255.0f alpha:1.0f];
		
		_titleLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_titleLabel];
	}
	
	return _titleLabel;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"description"		: self.descriptionTextView,
			 @"imageView"		: self.imageView,
			 @"title"			: self.titleLabel			};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets the decription of this panel.
 *
 *	@param	description					The desired description of this panel.
 */
- (void)setDescription:(NSString *)description
{
	if (_description == description)	return;
	
	_description						= description;
	self.descriptionTextView.text		= _description;
}

/**
 *	Sets the image to be displayed in this panel.
 *
 *	@param	image						The desired image to be displayed in this panel.
 */
- (void)setImage:(UIImage *)image
{
	if (_image == image)				return;
	
	_image								= image;
	self.imageView.image				= image;
}

/**
 *	Sets the title of this panel.
 *
 *	@param	title						The desired title of this panel.
 */
- (void)setTitle:(NSString *)title
{
	if (_title == title)				return;
	
	_title								= title;
	self.titleLabel.text				= title;
}

@end