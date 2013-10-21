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

#pragma mark - Initialisation

/**
 *	The initialisation that needs to be done for this blur view.
 */
- (void)basicInitialisation
{
	self.backgroundColor				= [UIColor clearColor];
	self.clipsToBounds					= YES;
	[self.layer insertSublayer:self.toolbar.layer atIndex:0];
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
 *	The toolbar that will be used purely for it's blur layer.
 *
 *	@return	An initialised UIToolbar with a frame filling the whole bounds.
 */
- (UIToolbar *)toolbar
{
	if (!_toolbar)
	{
		_toolbar						= [[UIToolbar alloc] initWithFrame:self.bounds];
		_toolbar.barTintColor			= kYummlyColourMain;
	}
	
	return _toolbar;
}

#pragma mark - Property Accessor Methods - Setters

/**
 *
 *
 *	@param
 */
- (void)setBlurTintColour:(UIColor *)blurTintColour
{
	if (_blurTintColour == blurTintColour)
		return;
	
	_blurTintColour				= blurTintColour;
	
	self.toolbar.barTintColor	= _blurTintColour;
}

/**
 *
 *
 *	@param
 */
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self updateFrame];
}

#pragma mark - Size Updating

/**
 *	Update the frame.
 */
- (void)updateFrame
{
	self.toolbar				= nil;
	[self basicInitialisation];
}

@end