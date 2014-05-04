//
//  RotaryWheelDataSource.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 04/05/2014.
//  Copyright (c) 2014 &Beyond. All rights reserved.
//

@class RotaryWheel;
@class SegmentView;

#pragma mark - Rotary Wheel Data Source

@protocol RotaryWheelDataSource <NSObject>

#pragma mark - Required Methods

@required

/**
 *	Sent to the data source to ascertain the number of segments in the wheel.
 *
 *	@param	rotaryWheel					The RotaryWheel object sending this message.
 *
 *	@return	The number of segments for the RotaryWheel sending this message.
 */
- (NSUInteger)rotaryWheelNumberOfSegments:(RotaryWheel *)rotaryWheel;
/**
 *	Sent to the data source to get the segment view at a given index.
 *
 *	@param	rotaryWheel					The RotaryWheel object sending this message.
 *	@param	segmentIndex				The index locating the segment in the wheel.
 *
 *	@return	An object inheriting from SegmentView that the RotaryWheel can use for the specified segment.
 */
- (SegmentView *)rotaryWheel:(RotaryWheel *)rotaryWheel segmentViewForSegmentAtIndex:(NSUInteger)segmentIndex;

@end