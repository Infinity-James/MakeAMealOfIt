//
//  IncludeExcludeControl.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 24/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IncludeExcludeControl.h"

#pragma mark - Include Exclude Control Private Class Extension

@interface IncludeExcludeControl () {}

#pragma mark - Private Properties

/**	Allows user to exclude the option being displayed.	*/
@property (nonatomic, strong)	UIButton	*excludeButton;
/**	Allows user to include the option being displayed.	*/
@property (nonatomic, strong)	UIButton	*includeButton;
/**	DIsplays the option available to be included or excluded.	*/
@property (nonatomic, strong)	UILabel		*optionLabel;
/**	A dictionary to be used for auto layout.	*/
@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Include Exclude Control Implementation

@implementation IncludeExcludeControl {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the exclude button has been tapped.
 */
- (void)excludeButtonTapped
{
	if (!self.excludeButton.enabled)	return;
	self.excludeButton.highlighted		= YES;
	[self.delegate excludeSelected];
	[self.excludeButton performSelector:@selector(setHighlighted:) withObject:@NO afterDelay:0.2f];
}

/**
 *	A method called when a tap falls within this control.
 *
 *	@param	tapGestureRecogniser		The gesture recogniser that registered the tap and called this method.
 */
- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecogniser
{
	//	make the buttons effective frame even bigger
	CGRect excludeButtonBounds			= CGRectInset(self.excludeButton.frame, -20.0f, -20.0f);
	CGRect includeButtonBounds			= CGRectInset(self.includeButton.frame, -20.0f, -20.0f);
	
	//	check whether the tap falls within either button's bounds
	if (CGRectContainsPoint(excludeButtonBounds, [tapGestureRecogniser locationInView:self]))
		[self excludeButtonTapped];
	else if (CGRectContainsPoint(includeButtonBounds, [tapGestureRecogniser locationInView:self]))
		[self includeButtonTapped];
}

/**
 *	Called when the include button has been tapped.
 */
- (void)includeButtonTapped
{
	if (!self.includeButton.enabled)	return;
	self.includeButton.highlighted		= YES;
	[self.delegate includeSelected];
	[self.includeButton performSelector:@selector(setHighlighted:) withObject:@NO afterDelay:0.2f];
}

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
	[self.excludeButton removeConstraints:self.excludeButton.constraints];
	[self.includeButton removeConstraints:self.includeButton.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add everything to fill the bounds
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==6)-[excludeButton]-(==6)-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[excludeButton][optionLabel][includeButton]|"
																options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	
	//	make the exclude and include buttons square
	constraint							= [NSLayoutConstraint constraintWithItem:self.excludeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.excludeButton attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
	[self.excludeButton addConstraint:constraint];
	constraint							= [NSLayoutConstraint constraintWithItem:self.includeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.includeButton attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
	[self.includeButton addConstraint:constraint];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Disables the exclude button so the user knows it is not an option.
 */
- (void)deactivateExcludeButton
{
	self.excludeButton.alpha			= 0.5f;
	self.excludeButton.enabled			= NO;
}

/**
 *	Disables the include button so the user knows it is not an option.
 */
- (void)deactivateIncludeButton
{
	self.includeButton.alpha			= 0.5f;
	self.includeButton.enabled			= NO;
}

/**
 *	Enables the exclude button, letting the user know it is an option.
 */
- (void)enableExcludeButton
{
	self.excludeButton.alpha			= 1.0f;
	self.excludeButton.enabled			= YES;
}

/**
 *	Enables the include button, letting the user know it is an option.
 */
- (void)enableIncludeButton
{
	self.includeButton.alpha			= 1.0f;
	self.includeButton.enabled			= YES;
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
		UITapGestureRecognizer *tapGesture	= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:tapGesture];
		//self.userInteractionEnabled		= NO;
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	A button tapped on to exclude the option represented in the option label.
 *
 *	@return	A fully intialised button, customised and with an added target.
 */
- (UIButton *)excludeButton
{
	//	lazy instantiation to initialise and customise button
	if (!_excludeButton)
	{
		_excludeButton								= [[UIButton alloc] init];
		[_excludeButton setImage:[UIImage imageNamed:@"button_main_normal_exclude_yummly"] forState:UIControlStateNormal];
		[_excludeButton setImage:[UIImage imageNamed:@"button_main_highlighted_exclude_yummly"] forState:UIControlStateHighlighted];
		_excludeButton.contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
		_excludeButton.contentVerticalAlignment		= UIControlContentVerticalAlignmentCenter;
		
		//[ThemeManager customiseButton:_excludeButton withTheme:nil];
		
		//[_excludeButton addTarget:self action:@selector(excludeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		_excludeButton.userInteractionEnabled		= NO;
		
		_excludeButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_excludeButton];
	}
	
	return _excludeButton;
}

/**
 *	A button tapped on to include the option represented in the option label.
 *
 *	@return	A fully intialised button, customised and with an added target.
 */
- (UIButton *)includeButton
{
	//	lazy instantiation to initialise and customise button
	if (!_includeButton)
	{
		_includeButton								= [[UIButton alloc] init];
		[_includeButton setImage:[UIImage imageNamed:@"button_main_normal_include_yummly"] forState:UIControlStateNormal];
		[_includeButton setImage:[UIImage imageNamed:@"button_main_highlighted_include_yummly"] forState:UIControlStateHighlighted];
		_includeButton.contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
		_includeButton.contentVerticalAlignment		= UIControlContentVerticalAlignmentCenter;
		
		//[ThemeManager customiseButton:_includeButton withTheme:nil];
		
		//[_includeButton addTarget:self action:@selector(includeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		_includeButton.userInteractionEnabled		= NO;
		
		_includeButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_includeButton];
	}
	
	return _includeButton;
}

/**
 *	The label representing the option to include or exclude.
 *
 *	@return	An initialised and customised label with the option in it.
 */
- (UILabel *)optionLabel
{
	//	lazy instantiation to initialise and customise label
	if (!_optionLabel)
	{
		_optionLabel					= [[UILabel alloc] init];
		_optionLabel.textAlignment		= NSTextAlignmentCenter;
		_optionLabel.textColor			= kYummlyColourMain;
		_optionLabel.font				= kYummlyFontWithSize(16.0f);
		
		_optionLabel.translatesAutoresizingMaskIntoConstraints		= NO;
		[self addSubview:_optionLabel];
	}
	
	return _optionLabel;
}

/**
 *	Sets the text to be displayed in the option label.
 *
 *	@param	optionText					Desired text for the option label.
 */
- (void)setOptionText:(NSString *)optionText
{
	self.optionLabel.text	= _optionText	= optionText;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"excludeButton"	: self.excludeButton,
				@"includeButton"	: self.includeButton,
				@"optionLabel"		: self.optionLabel		};
}

#pragma mark - UIResponder Methods

/**
 *	Returns the farthest descendant of the receiver in the view hierarchy (including itself) that contains a specified point.
 *
 *	@param	point						A point specified in the receiver’s local coordinate system (bounds).
 *	@param	event						The event that warranted a call to this method.
 *
 *	@return	The view object that is the farthest descendent the current view and contains point.
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSInteger compensationMargin		= -10.0f;
	CGRect largerFrame					= CGRectInset(self.bounds, compensationMargin, compensationMargin);
	return CGRectContainsPoint(largerFrame, point) ? self : nil;
}

#pragma mark - Utility Methods

/**
 *	Creates and returns an image view of the current look of the option label.
 *
 *	@return	An image view with a randered snapshot of the option label as the image and is centred correctly.
 */
- (UIImageView *)labelImageView
{
	UIGraphicsBeginImageContext(self.optionLabel.bounds.size);
	[self.optionLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *labelImage					= UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageView *labelImageView			= [[UIImageView alloc] initWithImage:labelImage];
	CGPoint superCentre					= [self convertPoint:self.optionLabel.center toView:self.superview];
	labelImageView.center				= superCentre;
	
	return labelImageView;
}

@end