//
//  RotaryWheel.h
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - RotaryProtocol Declaration

@protocol RotaryProtocol <NSObject>

#pragma mark - Required Methods

@required

/**
 *	The rotary wheel's value has changed.
 *
 *	@param	newValue					The selected value in the wheel.
 */
- (void)wheelDidChangeValue:(NSString *)newValue;

@end

#pragma mark - RotaryWheel Public Interface

@interface RotaryWheel : UIControl {}

#pragma mark - Public Properties

@property (nonatomic, weak)		id <RotaryProtocol>	delegate;
@property (nonatomic, assign)	BOOL				drawnWheel;
@property (nonatomic, assign)	NSInteger			numberOfSections;
@property (nonatomic, strong)	NSArray				*segmentTitles;

#pragma mark - Private Method Declarations

/**
 *	Initialises an instance of this rotary wheel with the amount of sections it should have as well as the delegate.
 *
 *	@param	delegate					The delegate wanting to receive notifications from this wheel.
 *	@param	sectionsNumber				The number of sections that this wheel should have.
 */
- (id)initWithDelegate:(id<RotaryProtocol>)delegate
		  withSections:(NSInteger)sectionsNumber;
/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						Frame rectangle for the view, measured in points.
 *	@param	delegate					Delegate for the rotary protocol.
 *	@param	sectionsNumber				Number of sections for the rotary wheel control.
 */
- (id)initWithFrame:(CGRect)frame
		andDelegate:(id<RotaryProtocol>)delegate
	   withSections:(NSInteger)sectionsNumber;

@end