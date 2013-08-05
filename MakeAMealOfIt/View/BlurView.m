//
//  BlurView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 05/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "BlurView.h"

#pragma mark - Blur View Private Class Extension

@interface BlurView () {}

/**	A CALayer configured to look slightly translucent.	*/
@property (nonatomic, strong)	CALayer		*blurLayer;
/**	The subview which is responsible for blurring the entirety of this view.	*/
@property (nonatomic, strong)	UIView		*blurView;
/**	The toolbar that will be used purely for it's blur layer.	*/
@property (nonatomic, strong)	UIToolbar	*toolbar;

@end

#pragma mark - Blur View Implementation

@implementation BlurView {}

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
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-1)-[blurView]-(-1)-|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
}

#pragma mark - Initialisation

/**
 *	The initialisation that needs to be done for this blur view.
 */
- (void)basicInitialisation
{
	self.backgroundColor				= [UIColor clearColor];
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
		[self basicInitialisation];
	}
	
	return self;
}

/**
 *	Returns an object initialized from data in a given unarchiver.
 *
 *	@param	aDecoder					An unarchiver object.
 *
 *	@return	self, initialized using the data in decoder.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self basicInitialisation];
	}
	
	return self;
}

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		[self basicInitialisation];
    }
	
    return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The layer to be used blur this view.
 *
 *	@return	A CALayer configured to look slightly translucent.
 */
- (CALayer *)blurLayer
{
	if (!_blurLayer)
	{
		_blurLayer						= self.toolbar.layer;
	}
	
	return _blurLayer;
}

/**
 *	The subview which is responsible for blurring the entirety of this view.
 *
 *	@return	An initialised UIView used to blur this view.
 */
- (UIView *)blurView
{
	if (!_blurView)
	{
		_blurView						= [[UIView alloc] init];
		_blurView.userInteractionEnabled= NO;
		
		[_blurView.layer addSublayer:self.blurLayer];
		
		_blurView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_blurView];
	}
	
	return _blurView;
}

/**
 *	The toolbar that will be used purely for it's blur layer.
 *
 *	@return	An initialised UIToolbar with a frame filling the whole bounds.
 */
- (UIToolbar *)toolbar
{
	if (!_toolbar)
		_toolbar						= [[UIToolbar alloc] initWithFrame:self.bounds];
	
	return _toolbar;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"blurView"		: self.blurView};
}

@end