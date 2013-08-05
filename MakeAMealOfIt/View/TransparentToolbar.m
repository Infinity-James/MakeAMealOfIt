//
//  TransparentToolbar.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 05/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "TransparentToolbar.h"

@implementation TransparentToolbar

#pragma mark - Initialisation

/**
 *
 */
- (void)basicInitialisation
{
	self.backgroundColor				= [UIColor clearColor];
	self.opaque							= NO;
	self.tintColor						= [UIColor clearColor];
	self.translucent					= YES;
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
		
    }
	
    return self;
}

#pragma mark - UIView Methods

/**
 *	Draws the receiver’s image within the passed-in rectangle.
 *
 *	@param	rect						The portion of the view’s bounds that needs to be updated.
 */
- (void)drawRect:(CGRect)rect
{
}

@end
