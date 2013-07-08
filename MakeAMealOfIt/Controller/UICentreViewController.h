//
//  UICentreViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationController.h"

#pragma mark - Centre View Controller Public Interface

@interface UICentreViewController : UIViewController {}

#pragma mark - Public Properties

/**	The left toolbar button used to slide in the left view.	*/
@property (nonatomic, strong)	UIBarButtonItem				*leftButton;
/**	The right toolbar button used to slide in the right view	*/
@property (nonatomic, strong)	UIBarButtonItem				*rightButton;
/**	The toolbar holding the buttons that allow the sliding in of side views.	*/
@property (nonatomic, strong)	UIToolbar					*toolbar;
/**	Returns the correct height for a toolbar, depending on the orientation.	*/
@property (nonatomic, assign)	CGFloat						toolbarHeight;
/**	*/
@property (nonatomic, weak)		SlideNavigationController	*slideNavigationController;


#pragma mark - Public Methods

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animate						Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animate;

@end