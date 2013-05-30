//
//  RotaryWheel.h
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - RotaryProtocol Declaration

@protocol RotaryProtocol <NSObject>

#pragma mark - Reuired Methods

@required

- (void)wheelDidChangeValue:(NSString *)newValue;

@end

#pragma mark - RotaryWheel Public Interface

@interface RotaryWheel : UIControl {}

#pragma mark - Public Properties

@property (nonatomic, weak)		id <RotaryProtocol>	delegate;
@property (nonatomic, assign)	BOOL				drawnWheel;
@property (nonatomic, assign)	NSInteger			numberOfSections;

#pragma mark - Private Method Declarations

- (id)initWithDelegate:(id<RotaryProtocol>)delegate
		  withSections:(NSInteger)sectionsNumber;
- (id)initWithFrame:(CGRect)frame
		andDelegate:(id<RotaryProtocol>)delegate
	   withSections:(NSInteger)sectionsNumber;

@end