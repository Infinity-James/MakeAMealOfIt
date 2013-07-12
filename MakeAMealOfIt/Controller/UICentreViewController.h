//
//  UICentreViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "SlideNavigationItem.h"

#pragma mark - Centre View Controller Public Interface

@interface UICentreViewController : UIViewController {}

#pragma mark - Public Properties

/**	The nearest ancestor in the view controller hierarchy that's a slide navigation controller.	*/
@property (nonatomic, weak)		SlideNavigationController	*slideNavigationController;
/** The slide navigation item used to represent the view controller in a parent’s toolbar.	*/
@property (nonatomic, strong)	SlideNavigationItem			*slideNavigationItem;

@end