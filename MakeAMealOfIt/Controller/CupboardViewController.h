//
//  CupboardViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "LeftControllerDelegate.h"

#pragma mark - Cupboard View Controller Public Interface

@interface CupboardViewController : UIViewController {}

#pragma mark - Public Properties

/**	An NSObject adhering to our LeftControllerDelegate protocol interested in our updates.	*/
@property (nonatomic, weak)		id <LeftControllerDelegate>		leftDelegate;

@end