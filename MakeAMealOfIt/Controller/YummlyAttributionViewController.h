//
//  YummlyAttributionViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RightControllerDelegate.h"
#import "UIRightViewController.h"

#pragma mark - Yummly Attribution VC Public Interface

@interface YummlyAttributionViewController : UIRightViewController {}

#pragma mark - Public Properties

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	attributionDictionary		A dictionary of things required for a Yummly attribution.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithAttributionDictionary:(NSDictionary *)attributionDictionary;

#pragma mark - Public Methods

/**	The delegate that acknowledges us as it's right view controller.	*/
@property (nonatomic, weak)	id <RightControllerDelegate>	rightDelegate;

@end