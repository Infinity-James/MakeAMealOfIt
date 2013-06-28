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

#pragma mark - Public Methods

/**
 *	Disables the exclude button so the user knows it is not an option.
 */
- (void)deactivateExcludeButton;
/**
 *	Disables the include button so the user knows it is not an option.
 */
- (void)deactivateIncludeButton;
/**
 *	Enables the exclude button, letting the user know it is an option.
 */
- (void)enableExcludeButton;
/**
 *	Enables the include button, letting the user know it is an option.
 */
- (void)enableIncludeButton;
/**
 *	Creates and returns an image view of the current look of the option label.
 *
 *	@return	An image view with a randered snapshot of the option label as the image and is centred correctly.
 */
- (UIImageView *)labelImageView;

#pragma mark - Public Properties

/**	The delegate for this control.	*/
@property (nonatomic, weak)		id <IncludeExcludeDelegate>	delegate;
/**	The text to be displayed in the option label.	*/
@property (nonatomic, strong)	NSString					*optionText;

@end