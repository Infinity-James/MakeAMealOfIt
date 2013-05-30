//
//  Sector.h
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@interface Sector : NSObject

@property (nonatomic, assign)	CGFloat		maxiumValue;
@property (nonatomic, assign)	CGFloat		middleValue;
@property (nonatomic, assign)	CGFloat		minimumValue;
@property (nonatomic, assign)	NSInteger	sectorID;

- (id)initWithMinimumValue:(CGFloat)minValue
			   middleValue:(CGFloat)midValue
			  maximumValue:(CGFloat)maxValue
			   andSectorID:(NSInteger)sectorID;

@end