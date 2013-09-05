//
//  TextBackingView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 24/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "TextBackingView.h"

#pragma mark - Text Backing View Private Class Extension

@interface TextBackingView () {}

#pragma mark - Private Properties

/**	A largely translucent gradient to be used as tha background of this view.	*/
@property (nonatomic, strong)	CAGradientLayer	*backgroundGradient;

@end

#pragma mark - Text Backing View Implementation

@implementation TextBackingView {}

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
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.mainLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
	[self addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==8)-[mainLabel(>=40)]-(==8)-[detailLabel]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[mainLabel]-(>=20)-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[detailLabel]-(>=20)-|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
}

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		[self.layer insertSublayer:self.backgroundGradient atIndex:0];
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	A largely translucent gradient to be used as tha background of this view.
 *
 *	@return	An initialised CAGradientLayer to be used as the background of this view.
 */
- (CAGradientLayer *)backgroundGradient
{
	if (!_backgroundGradient)
	{
		NSArray *colours				= @[(id)kLightGreyColourWithAlpha(0.1f).CGColor, (id)kDarkGreyColourWithAlpha(0.5f).CGColor];
		NSArray *locations				= @[@(0.0f), @(1.0f)];
		
		_backgroundGradient				= [[CAGradientLayer alloc] init];
		_backgroundGradient.colors		= colours;
		_backgroundGradient.locations	= locations;
	}
	
	return _backgroundGradient;
}

/**
 *	The subtitle of this view.
 *
 *	@return	An initialised UILabel to be used as the subtitle.
 */
- (UILabel *)detailLabel
{
	if (!_detailLabel)
	{
		_detailLabel					= [[UILabel alloc] init];
		_detailLabel.backgroundColor	= [UIColor clearColor];
		_detailLabel.font				= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleCaption2));
		_detailLabel.textAlignment		= NSTextAlignmentCenter;
		_detailLabel.textColor			= [UIColor whiteColor];
		
		_detailLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_detailLabel];
	}
	
	return _detailLabel;
}

/**
 *	The main title of this view, it can be multi-line to a certain extent.
 *
 *	@return	An initialised UILabel to be used as the main title.
 */
- (UILabel *)mainLabel
{
	if (!_mainLabel)
	{
		_mainLabel						= [[UILabel alloc] init];
		_mainLabel.adjustsFontSizeToFitWidth	= NO;
		_mainLabel.backgroundColor		= [UIColor clearColor];
		_mainLabel.font					= kYummlyBolderFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote));
		_mainLabel.lineBreakMode		= NSLineBreakByWordWrapping;
		_mainLabel.numberOfLines		= 0;
		_mainLabel.textAlignment		= NSTextAlignmentCenter;
		_mainLabel.textColor			= [UIColor whiteColor];
		
		_mainLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_mainLabel];
	}
	
	return _mainLabel;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"mainLabel"		: self.mainLabel,
				@"detailLabel"		: self.detailLabel};
}

#pragma mark - UIView Methods

/**
 *	Lays out subviews.
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
	self.backgroundGradient.frame		= self.bounds;
	
}

#pragma mark - View-Related Observation Methods

/**
 *	Tells the view that its superview changed.
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
}

@end