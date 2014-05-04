//
//  Sector.m
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Sector.h"

#pragma mark - Sector Implementation

@implementation Sector

#pragma mark - Initialisation

/**
 *	Initialises a new instance of a Sector with the angles and ID provided.
 *
 *	@param	minimumAngle				The minimum angle for this sector in a circle (in radians).
 *	@param	middleAngle					The middle angle for this sector in a circle (in radians).
 *	@param	maximumAngle				The maximum angle for this sector in a circle (in radians).
 *	@param	sectorID					The unique ID for this particular sector in a circle.
 *
 *	@return	An initialized Sector object.
 */
- (instancetype)initWithMinimumAngle:(CGFloat)minimumAngle
						 middleAngle:(CGFloat)middleAngle
						maximumAngle:(CGFloat)maximumAngle
						 andSectorID:(NSInteger)sectorID
{
	if (self = [super init])
	{
		_minimumAngle = minimumAngle;
		_middleAngle = middleAngle;
		_maximumAngle = maximumAngle;
		_sectorID = sectorID;
	}
	
	return self;
}

#pragma mark - NSObject Methods

/**
 *	Returns a string that describes the contents of the receiver.
 *
 *	@return	A string that describes the contents of the receiver.
 */
- (NSString *)description
{
	NSString *description = [[NSString alloc] initWithFormat:@"Sector: %@, Minimum Angle: %@, Middle Angle: %@, Maximum Angle: %@", @(self.sectorID), @(self.minimumAngle), @(self.middleAngle), @(self.maximumAngle)];
	
	return description;
}

@end