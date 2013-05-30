//
//  UICentreViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "CentreViewControllerProtocol.h"

#pragma mark - Centre View Controller Public Interface

@interface UICentreViewController : UIViewController <CentreViewControllerProtocol> {}

#pragma mark - Public Properties

@property (nonatomic, strong)	UIBarButtonItem		*leftButton;
@property (nonatomic, strong)	UIBarButtonItem		*rightButton;
@property (nonatomic, strong)	UIToolbar			*toolbar;
@property (nonatomic, assign)	CGFloat				toolbarHeight;
@property (nonatomic, strong)	NSDictionary		*viewsDictionary;

#pragma mark - Public Methods

- (void)addToolbarItemsAnimated:(BOOL)animate;
- (void)leftButtonTapped;
- (void)rightButtonTapped;

@end