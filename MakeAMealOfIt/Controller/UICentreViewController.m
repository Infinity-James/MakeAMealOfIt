//
//  UICentreViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UICentreViewController.h"

#pragma mark - Centre View Controller Private Class Extension

@interface UICentreViewController () {}

@end

#pragma mark - Centre View Controller Implementation

@implementation UICentreViewController {}

#pragma mark - Synthesise Properties

@synthesize backButton					= _backButton;
@synthesize movingViewBlock				= _movingViewBlock;

#pragma mark - Action & Selector Methods

/**
 *	called when the button in the toolbar for the left panel is tapped
 */
- (void)leftButtonTapped
{
	if (!self.movingViewBlock)			return;
	
	switch (self.leftButtonTag)
	{
		case kButtonInUse:		self.movingViewBlock(MovingViewOriginalPosition);	break;
		case kButtonNotInUse:	self.movingViewBlock(MovingViewRight);				break;
		default:																	break;
	}
}

/**
 *	called when the button in the toolbar for the right panel is tapped
 */
- (void)rightButtonTapped
{
	if (!self.movingViewBlock)			return;
	
	switch (self.rightButtonTag)
	{
		case kButtonInUse:		self.movingViewBlock(MovingViewOriginalPosition);	break;
		case kButtonNotInUse:	self.movingViewBlock(MovingViewLeft);				break;
		default:																	break;
	}
}

#pragma mark - CentreViewControllerProtocol Methods

/**
 *	returns the left button tag
 */
- (NSUInteger)leftButtonTag
{
	return self.leftButton.tag;
}

/**
 *	returns right button tag
 */
- (NSUInteger)rightButtonTag
{
	return self.rightButton.tag;
}

/**
 *	sets the tag of the button to the left of the toolbar
 */
- (void)setLeftButtonTag:(NSUInteger)tag
{
	self.leftButton.tag					= tag;
}

/**
 *	sets the tag of the button to the right of the toolbar
 */
- (void)setRightButtonTag:(NSUInteger)tag
{
	self.rightButton.tag				= tag;
}

#pragma mark - Initialisation
	
/**
 *	adds toolbar items to our toolbar
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
{
}

#pragma mark - Setter & Getter Methods
	
/**
 *	the setter for the back button declared by the centre view protocol and used to transition to previous controller
 *
 *	@param	backButton					back button which would have been set by
 */
- (void)setBackButton:(UIBarButtonItem *)backButton
{
	_backButton							= backButton;
	[self addToolbarItemsAnimated:YES];
}

/**
 *	a toolbar to keep at the top of the view
 */
- (UIToolbar *)toolbar
{
	if (!_toolbar)
	{
		_toolbar						= [[UIToolbar alloc] init];
		_toolbar.clipsToBounds			= NO;
		_toolbar.translatesAutoresizingMaskIntoConstraints		= NO;
		_toolbar.translucent			= YES;
		[self.view addSubview:_toolbar];
		[self.view bringSubviewToFront:_toolbar];
	}
	
	return _toolbar;
}

/**
 *	returns the toolbar height according to the orientation and device
 */
- (CGFloat)toolbarHeight
{	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		return 32.0f;
	
	return 44.0f;
}

#pragma mark - View Lifecycle

/**
 *	sent to the view controller when the app receives a memory warning
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor	= [UIColor whiteColor];
	[self addToolbarItemsAnimated:NO];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
}

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
}

@end