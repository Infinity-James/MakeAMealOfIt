//
//  IntroductionPanelView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Introduction Panel View Public Interface

@interface IntroductionPanelView : UIView {}

#pragma mark - Public Properties

/**	The description of this panel.	*/
@property (nonatomic, strong)	NSString	*description;
/**	The image to be displayed in this panel.	*/
@property (nonatomic, strong)	UIImage		*image;
/**	The title of this panel.	*/
@property (nonatomic, strong)	NSString	*title;

#pragma mark - Public Methods

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	title						The title of this panel.
 *	@param	description					The description of this panel.
 *	@param	image						The image for this panel.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description andImage:(UIImage *)image;

@end