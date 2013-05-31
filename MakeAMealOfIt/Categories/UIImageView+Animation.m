//
//  UIImageView+Animation.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIImageView+Animation.h"

@implementation UIImageView (Animation)

#pragma mark - Image Animation

/**
 *	animates the setting of an image in this image view
 *
 *	@param	image						the image we want to animate into the image view
 *	@param	animated					whether to set the image in an animated way or not
 */
- (void)setImage:(UIImage *)image animated:(BOOL)animate
{
	[self setImage:image];
		
	if (animate)
	{
		[self.layer removeAllAnimations];
		CATransition *transition		= [CATransition animation];
		transition.duration				= 0.5f;
		transition.timingFunction		= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		transition.type					= kCATransitionFade;
		
		[self.layer addAnimation:transition forKey:nil];
	}
}

#pragma mark - Shadows

/**
 *	adds a shadow to this image view
 */
- (void)addShadow
{
	self.layer.shadowColor				= kShadowColour.CGColor;
	self.layer.shadowOffset				= kShadowOffset;
	self.layer.shadowOpacity			= 1.0f;
	self.layer.shadowRadius				= kShadowBlur;
	self.clipsToBounds					= NO;
}

@end