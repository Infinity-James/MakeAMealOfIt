//
//  RecipeSearchHelpView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeSearchHelpView.h"

#pragma mark - Recipe Search Help View Private Class Extension

@interface RecipeSearchHelpView () {}

#pragma mark - Private Properties

/**	The string of text to help the user.	*/
@property (nonatomic, strong)	NSString		*helpText;
/**	The text views that will hold the block of text which helps the user.	*/
@property (nonatomic, strong)	UITextView		*helpTextView;

@end

#pragma mark - Recipe Search Help View Implementation

@implementation RecipeSearchHelpView

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
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[helpText]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[helpText]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The string of text to help the user.
 *
 *	@return	An initialised NSString holding the block of text to help.
 */
- (NSString *)helpText
{
	if (!_helpText)
	{
		_helpText					= @"Remember to swipe right for ingredients, or left to filter with allergies, diets, or more.";
	}
	
	return _helpText;
}

/**
 *	The text views that will hold the block of text which helps the user.
 *
 *	@return	An initialised, formatted and filled UITextView.
 */
- (UITextView *)helpTextView
{
	if (!_helpTextView)
	{
		_helpTextView					= [[UITextView alloc] init];
		_helpTextView.backgroundColor	= [UIColor clearColor];
		_helpTextView.editable			= NO;
		_helpTextView.font				= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote));
		_helpTextView.text				= self.helpText;
		_helpTextView.textAlignment		= NSTextAlignmentCenter;
		_helpTextView.textColor			= kYummlyColourMain;
		
		_helpTextView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_helpTextView];
	}
	
	return _helpTextView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"helpText"	: self.helpTextView	};
}

#pragma mark - UIView Methods

/**
 *	Returns the natural size for the receiving view, considering only properties of the view itself.
 *
 *	@return	A size indicating the natural size for the receiving view based on its intrinsic properties.
 */
- (CGSize)intrinsicContentSize
{
	CGSize textViewContraints				= CGSizeMake(160.0f, 500.0f);
	
	NSStringDrawingContext *context		= [[NSStringDrawingContext alloc] init];
	
	UIFont *font						= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote));
	
	CGRect helpViewRect					= [self.helpText boundingRectWithSize:textViewContraints
														options:NSStringDrawingUsesLineFragmentOrigin
													 attributes:@{NSFontAttributeName: font}
														context:context];
	
	return helpViewRect.size;
}

@end