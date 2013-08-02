//
//  SlideNavigationToolbar.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 09/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SlideNavigationBar.h"

#define kCorrectFrame				CGRectMake(self.superview.bounds.origin.x, self.superview.bounds.origin.y,	\
												self.superview.bounds.size.width, self.barHeight);

#pragma mark - Slide Navigation Bar Private Class Extension

@interface SlideNavigationBar () {}

@property (nonatomic, strong)	UIBarButtonItem	*flexibleSpace;

@end

#pragma mark - Slide Navigation Bar Implementation

@implementation SlideNavigationBar {}

#pragma mark - Setter & Getter Methods

/**
 *	Returns the correct height for a toolbar, depending on the orientation.
 *
 *	@return	A smaller height for landscape and taller for portrait.
 */
- (CGFloat)barHeight
{
#ifdef FULLSCREENCENTRE
	
	if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
		return 52.0f;
	
	return 64.0f;
	
#endif
	
	if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
		return 32.0f;
	
	return 44.0f;
}

#pragma mark - UIView Methods

/**
 *	Lays out subviews.
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.frame							= kCorrectFrame;
}

#pragma mark - View-Related Observation Methods

/**
 *	Tells the view that its superview changed.
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	//	re-calculate frame for new superview
	self.frame							= kCorrectFrame;
}

@end