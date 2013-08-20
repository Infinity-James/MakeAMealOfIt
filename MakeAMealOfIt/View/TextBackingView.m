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

@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Text Backing View Implementation

@implementation TextBackingView {}

#pragma mark - Synthesise Properties

@synthesize mainLabel					= _mainLabel;

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

#pragma mark - Setter & Getter Methods

/**
 *	the subtitle of this view
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
 *	the main title of this view, it can be multi-line to a certain extent
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
 *	this dictionary is used when laying out constraints
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"mainLabel"		: self.mainLabel,
				@"detailLabel"		: self.detailLabel};
}

#pragma mark - UIView Methods

/**
 *	draws the receiver’s image within the passed-in rectangle
 *
 *	@param	rect						portion of the view’s bounds that needs to be updated
 */
- (void)drawRect:(CGRect)rect
{
	//	get the context
	CGContextRef context				= UIGraphicsGetCurrentContext();
	
	UIColor *endColour					= kDarkGreyColourWithAlpha(0.5f);
	UIColor *startColour				= kLightGreyColourWithAlpha(0.1f);
	
	//	----	fiil the rect with a background colour first of all	----
	
	//	set fill colour and then fill the rect
	[UtilityMethodsCG drawLinearGradientInContext:context withRect:rect startColour:startColour.CGColor andEndColour:endColour.CGColor];
}

#pragma mark - View-Related Observation Methods

/**
 *	tells the view that its superview changed
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	self.backgroundColor				= [UIColor clearColor];
}

@end