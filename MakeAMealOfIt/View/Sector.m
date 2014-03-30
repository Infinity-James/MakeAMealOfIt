//
//  Sector.m
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "Sector.h"

@implementation Sector

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (id)initWithMinimumValue:(CGFloat)minValue
			   middleValue:(CGFloat)midValue
			  maximumValue:(CGFloat)maxValue
			   andSectorID:(NSInteger)sectorID
{
	if (self = [super init])
	{
		self.minimumValue				= minValue;
		self.middleValue				= midValue;
		self.maxiumValue				= maxValue;
		self.sectorID					= sectorID;
	}
	
	return self;
}

#pragma mark - NSObject Methods

/**
 *	returns a string that describes the contents of the receiver
 */
- (NSString *)description
{
	return [NSString stringWithFormat:@"Sector %@: Min(%@), Mid(%@), Max(%@)",
			@(self.sectorID), @(self.minimumValue), @(self.middleValue), @(self.maxiumValue)];
}

@end