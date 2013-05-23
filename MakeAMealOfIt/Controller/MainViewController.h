//
//  MainViewController.h
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "CentreViewControllerProtocol.h"

#pragma mark - Main View Controller Public Interface

@interface MainViewController : UIViewController {}

#pragma mark - Public Properties

@property (nonatomic, strong)	UIViewController	*leftViewControllerClass;
@property (nonatomic, strong)	UIViewController	*rightViewControllerClass;

#pragma mark - Public Methods

- (instancetype)initWithCentreViewController:(UIViewController <CentreViewControllerProtocol> *)centreViewController;
- (void)transitionCentreToViewController:(UIViewController *)viewController;

@end