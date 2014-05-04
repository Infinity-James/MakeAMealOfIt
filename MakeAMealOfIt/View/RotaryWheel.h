//
//  RotaryWheel.h
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RotaryWheelDataSource.h"
#import "RotaryWheelDelegate.h"

#pragma mark - Rotary Wheel Public Interface

@interface RotaryWheel : UIControl {}

#pragma mark - Public Properties

/**	An object which will provide the required data for this wheel.	*/
@property (nonatomic, weak)		id <RotaryWheelDataSource>	dataSource;
/**	The object that will receive updates on the state of this wheel.	*/
@property (nonatomic, weak)		id <RotaryWheelDelegate>	delegate;
@property (nonatomic, assign)	BOOL				drawnWheel;
@property (nonatomic, assign)	NSInteger			numberOfSegments;
@property (nonatomic, strong)	NSArray				*segmentTitles;

#pragma mark - Private Method Declarations

/**
 *	Initialises an instance of this rotary wheel with the amount of sections it should have as well as the delegate.
 *
 *	@param	delegate					The delegate wanting to receive notifications from this wheel.
 *	@param	sectionsNumber				The number of sections that this wheel should have.
 */
- (id)initWithDelegate:(id<RotaryWheelDelegate>)delegate
		  withSections:(NSInteger)sectionsNumber;
/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						Frame rectangle for the view, measured in points.
 *	@param	delegate					Delegate for the rotary protocol.
 *	@param	sectionsNumber				Number of sections for the rotary wheel control.
 */
- (id)initWithFrame:(CGRect)frame
		andDelegate:(id<RotaryWheelDelegate>)delegate
	   withSections:(NSInteger)sectionsNumber;

@end