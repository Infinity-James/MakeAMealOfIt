//
//  Sector.h
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Sector Public Interface

@interface Sector : NSObject

#pragma mark - Public Properties

/**	The maximum angle for this sector in a circle (in radians).	*/
@property (nonatomic, assign)	CGFloat		maximumAngle;
/**	The middle angle for this sector in a circle (in radians).	*/
@property (nonatomic, assign)	CGFloat		middleAngle;
/**	The minimum angle for this sector in a circle (in radians).	*/
@property (nonatomic, assign)	CGFloat		minimumAngle;
/**	The unique ID for this particular sector in a circle.	*/
@property (nonatomic, assign)	NSInteger	sectorID;

#pragma mark - Public Methods

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
						 andSectorID:(NSInteger)sectorID;

@end