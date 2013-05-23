//
//  AppDelegate.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SlideOutNavigationController.h"
#import "YummlyRequest.h"

#pragma mark - App Delegate Public Interface

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)	SlideOutNavigationController	*slideOutVC;
@property (strong, nonatomic)	UIWindow						*window;
@property (strong, nonatomic)	YummlyRequest					*yummlyRequest;

@end
