//
//  IncludeExcludeControl.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 24/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - IncludeExcludeDelegate Protocol

@protocol IncludeExcludeDelegate <NSObject>

#pragma mark - Required Methods

@required

/**
 *	Sent to the delegate when the exclude button was tapped.
 */
- (void)excludeSelected;
/**
 *	Sent to the delegate when the include button was tapped.
 */
- (void)includeSelected;

@end

#pragma mark - Include Exclude Control Public Interface

@interface IncludeExcludeControl : UIControl

#pragma mark - Public Properties

/**	The delegate for this control.	*/
@property (nonatomic, weak)		id <IncludeExcludeDelegate>	delegate;
/**	The text to be displayed in the option label.	*/
@property (nonatomic, strong)	NSString					*optionText;

@end