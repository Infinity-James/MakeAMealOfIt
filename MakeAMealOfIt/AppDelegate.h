//
//  AppDelegate.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyRequest.h"

#pragma mark - App Delegate Public Interface

@interface AppDelegate : UIResponder <UIApplicationDelegate>

/**	Keeps track of whether there is an internet connection or not.	*/
@property (nonatomic, readonly, assign)	BOOL				internetConnectionExists;
/**	This property contains the window used to present the app’s visual content on the device’s main screen.	*/
@property (strong, nonatomic)			UIWindow			*window;
/**	The global YummlyRequest used for the main search of the app.	*/
@property (strong, nonatomic)			YummlyRequest		*yummlyRequest;

@end