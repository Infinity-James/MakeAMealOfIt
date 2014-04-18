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
 *	The basic and fundamental initialisation required for this class.
 */
- (void)basicInitialisation
{
    //	if we don't clip to bounds the toolbar draws a thin shadow on top
	self.clipsToBounds = YES;
    
    if (!self.toolbar) {
		
        self.toolbar = [[UIToolbar alloc] initWithFrame:[self bounds]];
		self.toolbar.translucent = YES;
        self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:[self toolbar] atIndex:0];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toolbar]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
    }
}

/**
 *	The tint colour of this blurred view. Set it to nil to reset.
 *
 *	@param	blurTintColor				The tint colour of this blurred view. Set it to nil to reset.
 */
- (void)setBlurTintColor:(UIColor *)blurTintColor
{
	self.toolbar.barTintColor = blurTintColor;
	self.toolbar.translucent = YES;
}

@end