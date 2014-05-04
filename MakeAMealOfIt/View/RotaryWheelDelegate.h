//
//  RotaryWheelDelegate.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 04/05/2014.
//  Copyright (c) 2014 &Beyond. All rights reserved.
//

@class RotaryWheel;

#pragma mark - Rotary Wheel Delegate Declaration

@protocol RotaryWheelDelegate <NSObject>

#pragma mark - Required Methods

@required

/**
 *	Sent to the delegate when a new segment has been selected.
 *
 *	@param	rotaryWheel					The RotaryWheel object sending this message.
 *	@param	index						The new index of the selected segment.
 */
- (void)rotaryWheel:(RotaryWheel *)rotaryWheel didSelectSegmentAtIndex:(NSUInteger)index;

@end