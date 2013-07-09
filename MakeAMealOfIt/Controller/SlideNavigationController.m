//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "LeftControllerDelegate.h"
#import "RightControllerDelegate.h"
#import "SlideNavigationController.h"
#import "UICentreViewController.h"
#import "UIView+AlphaControl.h"

@import QuartzCore;

#pragma mark - View Controller Tags

NS_ENUM(NSUInteger, ControllerViewTags)
{
	kCentreViewTag						= 1,
	kLeftViewTag,
	kRightViewTag
};

#pragma mark - Controller States

typedef NS_ENUM(NSUInteger, ControllerPanDirection)
{
	kPanDirectionNone,
	kPanDirectionLeft,
	kPanDirectionRight
};

typedef NS_OPTIONS(NSUInteger, ControllerPanMode)
{
	kPanModeNone					= 1 << 0,							//	disable pan
	kPanModeCentre					= 1 << 1,							//	enable panning of centre view controller
	kPanModeSide					= 1 << 2,							//	enable panning on side view controllers
	kPanModeDefault					= kPanModeCentre | kPanModeSide
};

#pragma mark - Static & Constant Variables

#define kCentreViewFrame			CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 20.0f, \
												self.view.bounds.size.width, self.view.bounds.size.height - 20.0f)
#define kSideViewFrame				CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 30.0f, \
												self.view.bounds.size.width, self.view.bounds.size.height - 40.0f)


/**	The default animation duration for sliding views.	*/
static NSTimeInterval const kDefaultAnimationDuration	= 00.20f;
/**	The maximum time allowed to animate the sliding of a view.	*/
static NSTimeInterval const kMaxAnimationDuration		= 00.40f;
/**	The width of a side view.	*/
static CGFloat const kSideViewWidth						= 270.00f;
/**	By what fraction the velocity of a gesture should be multiplied.	*/
static CGFloat const kVelocityDampening					= 00.35f;

/**	A key to be used when storing a centre view controller into a dictionary.	*/
static NSString *const kCentreVCKey			= @"Centre";
/**	A key to be used when storing a left view controller into a dictionary.	*/
static NSString *const kLeftVCKey			= @"Left";
/**	A key to be used when storing a right view controller into a dictionary.	*/
static NSString *const kRightVCKey			= @"Right";

#pragma mark - Main View Controller Private Class Extension

@interface SlideNavigationController () <UIGestureRecognizerDelegate> {}

/**	This back button can be set on the centre view controller to manage navigation.	*/
@property (nonatomic, strong)				UIBarButtonItem				*backButton;
/**	A motion effect deigned for the centre view controller.	*/
@property (nonatomic, strong)				UIMotionEffectGroup			*centreViewParallaxEffect;
/**	A motion effect designed for the side view controllers*/
@property (nonatomic, strong)				UIMotionEffectGroup			*childViewParallaxEffect;
/**	The current state of if a side view is visible or not.	*/
@property (nonatomic, readwrite, assign)	SideControllerState			controllerState;
/**	This enum is used to store in what direction the centre view controller is being panned.	*/
@property (nonatomic, assign)				ControllerPanDirection		panDirection;
/**	This will be used to keep track of the starting position of any pan gesture.	*/
@property (nonatomic, assign)				CGPoint						panGestureOrigin;
/**	This will be used to track the velocity of a pan gesture.	*/
@property (nonatomic, assign)				CGFloat						panGestureVelocity;
/**	Used to indicate what can be panned.	*/
@property (nonatomic, assign)				ControllerPanMode			panMode;
/**	This will hold the properties of the shadow for the centre view controller.	*/
@property (nonatomic, strong)				NSShadow					*shadow;
/**	The opacity of the shadow used for the centre view controller shadow.	*/
@property (nonatomic, assign)				CGFloat						shadowOpacity;
/**	This view will hold the left and right view controller views.	*/
@property (nonatomic, strong)				UIView						*sideContainerView;

/**	A UITapGestureRecognizer to be applied to the centre view controller.	*/
@property (nonatomic, strong)				UITapGestureRecognizer		*centreTapGestureRecogniser;
/**	A pan gesture recogniser that should be added to the centre view.	*/
@property (nonatomic, strong)				UIPanGestureRecognizer		*panGestureRecogniser;
/**	A UITapGestureRecognizer to be added to a previous centre view controller so when tapped on it will return.	*/
@property (nonatomic, strong)				UITapGestureRecognizer		*previousTapGestureRecogniser;

/**	The view controller centred in this controller.	*/
@property (nonatomic, strong)				UICentreViewController		*centreViewController;
/**	*/
@property (nonatomic, strong)				UIView						*leftView;
/**	*/
@property (nonatomic, strong)				UIView						*rightView;
/**	A dictionary of past left, right and centre view controllers.	*/
@property (nonatomic, strong)				NSMutableArray				*pastViewControllerDictionaries;

@end

#pragma mark - Slide Navigation Controller Implementation

@implementation SlideNavigationController {}

#pragma mark - Synthesise Properties

@synthesize leftViewController			= _leftViewController;
@synthesize rightViewController			= _rightViewController;

#pragma mark - Action & Selector Methods

/**
 *	This is called when the back button is pressed.
 */
- (void)backButtonPressed
{
	//	remove the tap gesture recogniser from the view now that it is not needed
	[self.previousTapGestureRecogniser.view removeGestureRecognizer:self.previousTapGestureRecogniser];
	
	//	gets the dictionary of view controller we want to transition to
	NSDictionary *desiredVCDictionary	= [self.pastViewControllerDictionaries lastObject];
	[self.pastViewControllerDictionaries removeObjectAtIndex:self.pastViewControllerDictionaries.count - 1];
	
	//	set the new view controllers to the current view controller except for the centre
	UIViewController *newCentreVC		= desiredVCDictionary[kCentreVCKey];
	self.leftViewController				= desiredVCDictionary[kLeftVCKey];
	self.rightViewController			= desiredVCDictionary[kRightVCKey];
	
	NSLog(@"New Centre View Controller: %@", newCentreVC);
}

#pragma mark - Animation & Customisation

/**
 *	Animates to a desired controller state.
 *
 *	@param	desiredSideControllerState	Whether to close all side controller, or open one of them.
 *	@param	completionHandler			Called at the end of the animations.
 */
- (void)animateToSideControllerState:(SideControllerState)desiredSideControllerState withCompletionHandler:(void(^)())completionHandler
{
	__weak SlideNavigationController *weakSelf	= self;
	
	switch (desiredSideControllerState)
	{
		//	if the side controllers will be closed we hide the side views and set the offset to 0
		case SlideNavigationSideControllerClosed:
		{
			[self setCentreViewControllerOffset:0.0f
									   animated:YES
						  withCompletionHandler:
			^{
				weakSelf.leftViewController.view.hidden		= YES;
				weakSelf.rightViewController.view.hidden	= YES;
				completionHandler();
			}];
			break;
		}
			
		//	if the left controller wants to be presented we make it visible, bring it to the front and move the centre out of the way
		case SlideNavigationSideControllerLeftOpen:
			if (!self.leftViewController)				return;
			[self prepareLeftViewToShow];
			[self setCentreViewControllerOffset:kSideViewWidth animated:YES withCompletionHandler:completionHandler];
			break;
			
		//	if the right controller wants to be presented we make it visible, bring it to the front and move the centre out of the way
		case SlideNavigationSideControllerRightOpen:
			if (!self.rightViewController)				return;
			[self prepareRightViewToShow];
			[self setCentreViewControllerOffset:-kSideViewWidth animated:YES withCompletionHandler:completionHandler];
			break;
	}
}

/**
 *	Draws the shadow for centre view controller.
 */
- (void)drawShadow
{
	if (self.shadowEnabled)
	{
		[self drawShadowPath];
		self.centreViewController.view.layer.shadowColor		= ((UIColor *)self.shadow.shadowColor).CGColor;
		self.centreViewController.view.layer.shadowOffset		= self.shadow.shadowOffset;
		self.centreViewController.view.layer.shadowOpacity		= 1.0f;
		self.centreViewController.view.layer.shadowRadius		= self.shadow.shadowBlurRadius;
	}
}

/**
 *	Draws the shadow path around the centre view controller.
 */
- (void)drawShadowPath
{
	if (self.shadowEnabled)
	{
		CGRect pathRect					= self.centreViewController.view.bounds;
		self.centreViewController.view.layer.shadowPath	= [UIBezierPath bezierPathWithRect:pathRect].CGPath;
	}
}

#pragma mark - Autorotation

/**
 *	Returns a Boolean value indicating whether rotation methods are forwarded to child view controllers.
 *
 *	@param	YES if rotation methods are forwarded or NO if they are not.
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	Returns whether the view controller’s contents should auto rotate.
 *
 *	@param	YES if the content should rotate, otherwise NO.
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

/**
 *	Sent to the view controller just before the user interface begins rotating.
 *
 *	@param	toInterfaceOrientation		The new orientation for the user interface. The possible values are described in UIInterfaceOrientation.
 *	@param	duration					The duration of the pending rotation, measured in seconds.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Centre View Controller Moving Methods

/**
 *	Sets the centre view's x origin.
 *
 *	@param	offset						The desired new x origin.
 */
- (void)setCentreViewControllerOffset:(CGFloat)offset
{
	//	update the centre frame by adding the offset
	CGRect centreViewFrame				= self.centreViewController.view.frame;
	centreViewFrame.origin.x			= offset;
	self.centreViewController.view.frame= centreViewFrame;
	
	//	if the side views are supposed to slide with the centre view controller
	if (self.simultaneouslySlideSideViews)
	{
		//	if we are going right we should align the left view and close the right one
		if (offset > 0.0f)
		{
			[self alignLeftViewWithCentre];
			[self closeRightView];
		}
		
		//	if we're going left we align the right view and close the left one
		else if (offset < 0.0f)
		{
			[self alignRightViewWithCentre];
			[self closeLeftView];
		}
		
		//	otherwise if we are going to the centre we close both side views
		else
		{
			[self closeLeftView];
			[self closeRightView];
		}
	}
}

/**
 *	Allows the setting of the centre view's x origin in an animated fashion.
 *
 *	@param	offset						The desired new x origin.
 *	@param	animated					Whether to animate the setting of the origin or not.
 *	@param	completionHandler			Called at the end of setting the 'offset'.
 */
- (void)setCentreViewControllerOffset:(CGFloat)offset
							 animated:(BOOL)animated
				withCompletionHandler:(void(^)())completionHandler
{
	[self setCentreViewControllerOffset:offset
							   animated:animated
				  withAdditionalActions:nil
				   andCompletionHandler:completionHandler];
}

/**
 *	Allows the setting of the centre view's x origin in an animated fashion.
 *
 *	@param	offset						The desired new x origin.
 *	@param	animated					Whether to animate the setting of the origin or not.
 *	@param	additionalActions			Any additional actions to perform (will be animated if animated is set to YES).
 *	@param	completionHandler			Called at the end of setting the 'offset'.
 */
- (void)setCentreViewControllerOffset:(CGFloat)offset
							 animated:(BOOL)animated
				withAdditionalActions:(void(^)())additionalActions
				 andCompletionHandler:(void(^)())completionHandler
{
	//	if this offset should be set in an animated fashion we do so
	if (animated)
	{
		CGFloat currentCentreViewX		= ABS(self.centreViewController.view.frame.origin.x);
		NSTimeInterval duration			= [self animationDurationFromStartPosition:currentCentreViewX toEndPosition:offset];
		
		[UIView animateWithDuration:duration
						 animations:
		^{
			//	set the centre view controller offset
			[self setCentreViewControllerOffset:offset];
			
			//	do other animations passed in if there are any
			if (additionalActions)	additionalActions();
		}
						 completion:^(BOOL finished)
		{
			if (completionHandler)
				completionHandler();
		}];
	}
	
	//	if this does not need to be animated we just set it
	else
	{
		//	set the centre view controller offset
		[self setCentreViewControllerOffset:offset];
		
		//	do any other actions in a non-animated way
		if (additionalActions)	additionalActions();
		
		//	perform any requested completion handler
		if (completionHandler)
			completionHandler();
	}
}

#pragma mark - Gesture Handling Callbacks

/**
 *	This is called when centre view controller has been tapped, and will close the centre view if it is not already.
 *
 *	@param	tapGestureRecogniser		The tap gesture recogniser calling this method.
 */
- (void)centreViewTapped:(UITapGestureRecognizer *)tapGestureRecogniser
{
	if (self.controllerState != SlideNavigationSideControllerClosed)
		[self setControllerState:SlideNavigationSideControllerClosed];
}

/**
 *	This is called when a gesture is moving the view.
 *
 *	@param	gestureRecogniser			The gesture recogniser calling this method.
 */
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecogniser
{
	UIView *centreView					= self.centreViewController.view;
	
	//	if the gesture just began we grab the origin of the centre view and set the direction to none
	if (gestureRecogniser.state == UIGestureRecognizerStateBegan)
	{
		self.panGestureOrigin			= centreView.frame.origin;
		self.panDirection				= kPanDirectionNone;
	}
	
	//	if the gesture has no direction yet
	if (self.panDirection == kPanDirectionNone)
	{
		//	get the translation of the gesture in the view
		CGPoint translation				= [gestureRecogniser translationInView:centreView];
		
		//	if the translation implies a right movement
		if (translation.x > 0.0f)
		{
			//	set the direction of the movement
			self.panDirection			= kPanDirectionRight;
			
			//	if no side view is being shown we prepare the left view
			if (self.controllerState == SlideNavigationSideControllerClosed &&
				self.leftViewController)
				[self prepareLeftViewToShow];
		}
		
		//	if the translation implies a left movement
		if (translation.x < 0.0f)
		{
			//	set the direction of the movement
			self.panDirection			= kPanDirectionLeft;
			
			//	if no side view is being shown we prepare the right view
			if (self.controllerState == SlideNavigationSideControllerClosed &&
				self.rightViewController)
				[self prepareRightViewToShow];
		}
	}
	
	//	if the panning has completed we set the direction to none and return
	if ((self.panDirection == kPanDirectionLeft && self.controllerState == SlideNavigationSideControllerRightOpen) ||
		(self.panDirection == kPanDirectionRight && self.controllerState == SlideNavigationSideControllerLeftOpen))
	{
		self.panDirection				= kPanDirectionNone;
		return;
	}
	
	//	if the user wants to pan the view to the left we call the appropriate method
	if (self.panDirection == kPanDirectionLeft)
		[self handlePanLeft:gestureRecogniser];
	
	//	if the user wants to pan the view to the right we call the appropriate method
	else if (self.panDirection == kPanDirectionRight)
		[self handlePanRight:gestureRecogniser];
}

/**
 *	This is called when the user wants to pan the centre view to the left.
 *
 *	@param	gestureRecogniser			The gesture recogniser panning the view.
 */
- (void)handlePanLeft:(UIPanGestureRecognizer *)gestureRecogniser
{
	//	if the pan gesture is to the left whilst closed but there is no right view to show we return
	if (!self.rightViewController && self.controllerState != SlideNavigationSideControllerClosed)
		return;
	
	UIView *centreView					= self.centreViewController.view;
	
	//	get the translation of the gesture in the view
	CGPoint translation					= [gestureRecogniser translationInView:centreView];
	
	//	we will adjust the origin based upon the starting origin
	translation							= CGPointMake(translation.x + self.panGestureOrigin.x, translation.y + self.panGestureOrigin.y);
	
	//	correct the translation so that it does not extend too far
	translation.x						= MAX(translation.x, -kSideViewWidth);
	translation.x						= MIN(translation.x, kSideViewWidth);
	
	//	if the left view is open the gesture can only try to close it
	if (self.controllerState == SlideNavigationSideControllerLeftOpen)
		translation.x					= MAX(translation.x, 0.0f);
	else
		translation.x					= MIN(translation.x, 0.0f);
	
	//	update the centre view offset with the latest translation
	[self setCentreViewControllerOffset:translation.x];
	
	//	if the gesture has ended
	if (gestureRecogniser.state == UIGestureRecognizerStateEnded)
	{
		//	get the velocity of the gesture as it ended and use it to calculate the last x translation
		CGPoint velocity				= [gestureRecogniser velocityInView:centreView];
		CGFloat finalX					= translation.x + (kVelocityDampening * velocity.x);
		CGFloat viewWidth				= centreView.frame.size.width;
		
		//	if the gesture started whilst no side view was present
		if (self.controllerState == SlideNavigationSideControllerClosed)
		{
			//	calculate whether the right view should be shown
			BOOL showRightView			= (finalX < -viewWidth / 2.0f) || (finalX < -kSideViewWidth / 2.0f);
			
			//	if we should show the right view we store the velocity and animate it
			if (showRightView)
			{
				self.panGestureVelocity	= velocity.x;
				[self setControllerState:SlideNavigationSideControllerRightOpen];
			}
			
			//	otherwise if the gesture failed or was canceled we keep the controller closed
			else
			{
				self.panGestureVelocity	= 0.0f;
				[self setCentreViewControllerOffset:0.0f animated:YES withCompletionHandler:nil];
			}
		}
		
		//	if the gesture started whilst the left view was visible
		else if (self.controllerState == SlideNavigationSideControllerLeftOpen)
		{
			//	the right view should be hidden if the user moved the centre view back even slightly
			BOOL hideLeftView			= (finalX < self.panGestureOrigin.x);
			
			//	if we should hide the left view we store the velocity and animate the centre view back
			if (hideLeftView)
			{
				self.panGestureVelocity	= velocity.x;
				[self setControllerState:SlideNavigationSideControllerClosed];
			}
			
			//	otherwise if the user did not want to close the left view we keep it open
			else
			{
				self.panGestureVelocity	= 0.0f;
				[self setCentreViewControllerOffset:self.panGestureOrigin.x animated:YES withCompletionHandler:nil];
			}
		}
	}
}

/**
 *	This is called when the user wants to pan the centre view to the right.
 *
 *	@param	gestureRecogniser			The gesture recogniser panning the view.
 */
- (void)handlePanRight:(UIPanGestureRecognizer *)gestureRecogniser
{
	//	if the pan gesture is to the right whilst closed but there is no left view to show we return
	if (!self.leftViewController && self.controllerState != SlideNavigationSideControllerClosed)
		return;
	
	UIView *centreView					= self.centreViewController.view;
	
	//	get the translation of the gesture in the view
	CGPoint translation					= [gestureRecogniser translationInView:centreView];
	
	//	we will adjust the origin based upon the starting origin
	translation							= CGPointMake(translation.x + self.panGestureOrigin.x, translation.y + self.panGestureOrigin.y);
	
	//	correct the translation so that it does not extend too far
	translation.x						= MAX(translation.x, -kSideViewWidth);
	translation.x						= MIN(translation.x, kSideViewWidth);
	
	//	if the right view is open the gesture can only try to close it
	if (self.controllerState == SlideNavigationSideControllerRightOpen)
		translation.x					= MIN(translation.x, 0.0f);
	else
		translation.x					= MAX(translation.x, 0.0f);
	
	//	update the centre view offset with the latest translation
	[self setCentreViewControllerOffset:translation.x];
	
	//	if the gesture has ended
	if (gestureRecogniser.state == UIGestureRecognizerStateEnded)
	{
		//	get the velocity of the gesture as it ended and use it to calculate the last x translation
		CGPoint velocity				= [gestureRecogniser velocityInView:centreView];
		CGFloat finalX					= translation.x + (kVelocityDampening * velocity.x);
		CGFloat viewWidth				= centreView.frame.size.width;
		
		//	if the gesture started whilst no side view was present
		if (self.controllerState == SlideNavigationSideControllerClosed)
		{
			//	calculate whether the left view should be shown
			BOOL showLeftView			= (finalX > viewWidth / 2.0f) || (finalX > kSideViewWidth / 2.0f);
			
			//	if we should show the left view we store the velocity and animate it
			if (showLeftView)
			{
				self.panGestureVelocity	= velocity.x;
				[self setControllerState:SlideNavigationSideControllerLeftOpen];
			}
			
			//	otherwise if the gesture failed or was canceled we keep the controller closed
			else
			{
				self.panGestureVelocity	= 0.0f;
				[self setCentreViewControllerOffset:0.0f animated:YES withCompletionHandler:nil];
			}
		}
		
		//	if the gesture started whilst the right view was visible
		else if (self.controllerState == SlideNavigationSideControllerRightOpen)
		{
			//	the right view should be hidden if the user moved the centre view back even slightly
			BOOL hideRightView			= (finalX > self.panGestureOrigin.x);
			
			//	if we should hide the right view we store the velocity and animate the centre view back
			if (hideRightView)
			{
				self.panGestureVelocity	= velocity.x;
				[self setControllerState:SlideNavigationSideControllerClosed];
			}
			
			//	otherwise if the user did not want to close the right view we keep it open
			else
			{
				self.panGestureVelocity	= 0.0f;
				[self setCentreViewControllerOffset:self.panGestureOrigin.x animated:YES withCompletionHandler:nil];
			}
		}
	}
}

/**
 *	This is called when a left view controller is representing a previous view and has been tapped.
 *
 *	@param	tapGestureRecogniser		The tap gesture recogniser calling this method.
 */
- (void)previousViewTapped:(UITapGestureRecognizer *)tapGestureRecogniser
{
	//	act as though the user wants to go back to the previous view
	[self backButtonPressed];
}

#pragma mark - Initialisation

/**
 *	Initialises variables and sets up basic stuff for the main view controller.
 */
- (void)basicInitialisation
{	
	//	make sure we have the correct pan direction, and set the default panning
	self.panDirection					= kPanDirectionNone;
	self.panMode						= kPanModeDefault;
	//	set the default shadow opacity and the fact that we want shadows
	self.shadowOpacity					= 0.75f;
	self.shadowEnabled					= YES;
}

/**
 *	Called to initialise a class instance with a centre view controller to adopt.
 *
 *	@param	centreViewController		The view controller to present in the centre.
 */
- (instancetype)initWithCentreViewController:(UICentreViewController *)centreViewController
{
	return [self initWithCentreViewController:centreViewController leftViewController:nil andRightViewController:nil];
}

/**
 *	Called to initialise a class instance with a centre view controller to adopt.
 *
 *	@param	centreViewController		The view controller to present in the centre.
 *	@param	leftViewController			The left view controller to set.
 *	@param	rightViewController			The right view controller to set.
 */
- (instancetype)initWithCentreViewController:(UICentreViewController *)centreViewController
						  leftViewController:(UIViewController *)leftViewController
					  andRightViewController:(UIViewController *)rightViewController
{
	if (self = [super init])
	{
		self.centreViewController		= centreViewController;
		self.leftViewController			= leftViewController;
		self.rightViewController		= rightViewController;
		
		//	does the basic set up for variables
		[self basicInitialisation];
	}
	
	return self;
}

#pragma mark - Navigation

/**
 *	Pushes a new centre view controller with an accompanying right view controller.
 *
 *	@param	pushedCentreViewController	The view controller to be set as the new centre view controller.
 *	@param	rightViewController			The new right view controller to be paired with the new centre view controller.
 *	@param	animated					If YES the centre view controller will be pushed in animated fashion.
 */
- (void)pushCentreViewController:(UICentreViewController *)pushedCentreViewController
		 withRightViewController:(UIViewController *)rightViewController
						animated:(BOOL)animated
{
	CGRect newCentreFrame				= kCentreViewFrame;
	newCentreFrame.origin.x				= self.centreViewController.view.frame.size.width;
	pushedCentreViewController.view.frame	= newCentreFrame;
	
	[self.view addSubview:pushedCentreViewController.view];
	[self addChildViewController:pushedCentreViewController];
	[pushedCentreViewController didMoveToParentViewController:self];
	
	[self.view bringSubviewToFront:pushedCentreViewController.view];
	
	[UIView animateWithDuration:1.0f
					 animations:
	 ^{
		 self.centreViewController.view.frame	= kSideViewFrame;
	 }
					 completion:^(BOOL finished)
	 {
		 [UIView animateWithDuration:1.0f
						  animations:
		  ^{
			  pushedCentreViewController.view.frame	= kCentreViewFrame;
		  }
						  completion:^(BOOL finished)
		  {
			  NSMutableDictionary *pastViewControllers	= [[NSMutableDictionary alloc] init];
			  if (self.centreViewController)
				  pastViewControllers[kCentreVCKey]		= self.centreViewController;
			  if (self.leftViewController)
				  pastViewControllers[kLeftVCKey]			= self.leftViewController;
			  if (self.rightViewController)
				  pastViewControllers[kRightVCKey]		= self.rightViewController;
			  
			  [self.pastViewControllerDictionaries addObject:pastViewControllers];
			  
			  
			  self.centreViewController		= pushedCentreViewController;
			  self.rightViewController		= rightViewController;
		  }];
	 }];
}

#pragma mark - Setter & Getter Methods - Other Properties

/**
 *	This is used to hold the past centre view controllers, left view controllers, and right view controllers.
 *
 *	@return	An initialisied array intended to hold view controller dictionaries.
 */
- (NSMutableArray *)pastViewControllerDictionaries
{
	if (!_pastViewControllerDictionaries)
		_pastViewControllerDictionaries		= [[NSMutableArray alloc] init];
	
	return _pastViewControllerDictionaries;
}

#pragma mark - Setter & Getter Methods - Shadow Properties

/**
 *	This will hold the properties of the shadow for the centre view controller.
 *
 *	@return	An initialised instance with desired properties for a centre view controller shadow.
 */
- (NSShadow *)shadow
{
	if (!_shadow)
	{
		_shadow							= [[NSShadow alloc] init];
		_shadow.shadowBlurRadius		= 5.0f;
		_shadow.shadowColor				= [UIColor blackColor];
		_shadow.shadowOffset			= CGSizeMake(0.0f, 0.0f);
	}
	
	return _shadow;
}

/**
 *	Set whether shadows should be drawn onto the centre view controller.
 *
 *	@param	shadowEnabled				YES to show a shadow, NO otherwise.
 */
- (void)setShadowEnabled:(BOOL)shadowEnabled
{
	_shadowEnabled						= shadowEnabled;
	
	if (_shadowEnabled)
		[self drawShadow];
	else
	{
		self.centreViewController.view.layer.shadowOpacity	= 0.0f;
		self.centreViewController.view.layer.shadowRadius	= 0.0f;
	}
}

#pragma mark - Setter & Getter Methods - State Properties

/**
 *	A convenient way to get whether the centre view controller can be panned.
 *
 *	@return	YES if the centre view controller should respond to panning, NO if not.
 */
- (BOOL)centreViewControllerPanEnabled
{
	return (self.panMode & kPanModeCentre) == kPanModeCentre;
}

/**
 *	A convenient way to get whether the side views can be panned.
 *
 *	@return	YES if the side view should respond to panning, NO if not.
 */
- (BOOL)sideViewPanEnabled
{
	return (self.panMode & kPanModeSide) == kPanModeSide;
}

/**
 *	Set the state of this slide controller, closed, left open or right open.
 *
 *	@param	controllerState				The desired SideControllerState.
 */
- (void)setControllerState:(SideControllerState)controllerState
{
	[self setControllerState:controllerState withCompletionHandler:nil];
}

/**
 *	Set the state of this slide controller, closed, left open or right open.
 *
 *	@param	controllerState				The desired SideControllerState.
 *	@param	completionHandler			The completion handler to be called once the controllerState was set.
 */
- (void) setControllerState:(SideControllerState)controllerState
	  withCompletionHandler:(void (^)())completionHandler
{
	//	create a block to be executed once the views have been moved appropriately
	void (^innerCompletion)()			=
	^{
		_controllerState					= controllerState;
		
		if (completionHandler)
			completionHandler();
	};
	
	[self animateToSideControllerState:controllerState withCompletionHandler:innerCompletion];
}

#pragma mark - Setter & Getter Methods - UIGestureRecognizer Properties

/**
 *	When the centre view has been slid off to the side, it can be tapped upon to return to centre.
 *
 *	@return	An initialised and targeted UITapGestureRecogniser to be applied to the centre view controller.
 */
- (UITapGestureRecognizer *)centreTapGestureRecogniser
{
	if (!_centreTapGestureRecogniser)
	{
		_centreTapGestureRecogniser		= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centreViewTapped:)];
		_centreTapGestureRecogniser.delegate	= self;
	}
	
	return _centreTapGestureRecogniser;
}

/**
 *	The pan gesture recogniser used to pan the centre view left or right.
 *
 *	@return	A pan gesture recogniser that should be added to the centre view.
 */
- (UIPanGestureRecognizer *)panGestureRecogniser
{
	if (!_panGestureRecogniser)
	{
		_panGestureRecogniser				= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		_panGestureRecogniser.minimumNumberOfTouches	= 1;
		_panGestureRecogniser.maximumNumberOfTouches	= 1;
		_panGestureRecogniser.delegate					= self;
	}
	
	return _panGestureRecogniser;
}

/**
 *	This tap gesture recogniser should be added to a previous centre view controller so when tapped on it will return.
 *
 *	@return	A fully initialisd and targeted tap gesture recogniser.
 */
- (UITapGestureRecognizer *)previousTapGestureRecogniser
{
	if (!_previousTapGestureRecogniser)
		_previousTapGestureRecogniser			= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previousViewTapped:)];
	
	return _previousTapGestureRecogniser;
}

#pragma mark - Setter & Getter Methods - UIMotionEffect Properties

/**
 *	The getter for a group of motion effects to be applied to the centre view.
 *
 *	@return	The motion effect group for parallax motion effect to be applied to the centre view.
 */
- (UIMotionEffectGroup *)centreViewParallaxEffect
{
	if (!_centreViewParallaxEffect)
	{
		UIInterpolatingMotionEffect *xAxisEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.position.x"
																								  type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
		UIInterpolatingMotionEffect *yAxisEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.position.y"
																								  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
		
		xAxisEffect.maximumRelativeValue		= yAxisEffect.maximumRelativeValue	= @(8.0f);
		xAxisEffect.minimumRelativeValue		= yAxisEffect.minimumRelativeValue	= @(-8.0f);
		_centreViewParallaxEffect				= [[UIMotionEffectGroup alloc] init];
		_centreViewParallaxEffect.motionEffects	= @[xAxisEffect, yAxisEffect];
	}
	
	return _centreViewParallaxEffect;
}

/**
 *	The getter for a group of motion effects to be applied to child views.
 *
 *	@return	The motion effect group for parallax motion effect to be applied to a child view.
 */
- (UIMotionEffectGroup *)childViewParallaxEffect
{
	if (!_childViewParallaxEffect)
	{
		UIInterpolatingMotionEffect *xAxisEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.position.x"
																								  type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
		UIInterpolatingMotionEffect *yAxisEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.position.y"
																								  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
		
		xAxisEffect.maximumRelativeValue		= yAxisEffect.maximumRelativeValue	= @(-15.0f);
		xAxisEffect.minimumRelativeValue		= yAxisEffect.minimumRelativeValue	= @(15.0f);
		_childViewParallaxEffect				= [[UIMotionEffectGroup alloc] init];
		_childViewParallaxEffect.motionEffects	= @[xAxisEffect, yAxisEffect];
	}
	
	return _childViewParallaxEffect;
}

#pragma mark - Setter & Getter Methods - UIView Properties

/**
 *	A back button used to navigate back down the stack of view controllers.
 *
 *	@return	A fully initiased bar button item to be used for navigation back in the stack.
 */
- (UIBarButtonItem *)backButton
{
	if (!_backButton)
		_backButton						= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_back_yummly"]
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(backButtonPressed)];
	
	return _backButton;
}

/**
 *	Use to contain both the left and right views.
 *
 *	@return	Will never return nil, and will return the current side container view.
 */
- (UIView *)sideContainerView
{
	if (!_sideContainerView)
	{
		_sideContainerView				= [[UIView alloc] init];
		_sideContainerView.frame		= kSideViewFrame;
		_sideContainerView.autoresizingMask	= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		[self.view insertSubview:_sideContainerView atIndex:0];
	}
	
	return _sideContainerView;
}

#pragma mark - Setter & Getter Methods - UIViewController Properties

/**
 *	This centre view controller is the main controller displayed.
 *
 *	@param	centreViewController		Used to set some basics of the centre view controller.
 */
- (void)setCentreViewController:(UICentreViewController *)centreViewController
{
	[_centreViewController.view removeGestureRecognizer:self.panGestureRecogniser];
	[_centreViewController.view removeGestureRecognizer:self.centreTapGestureRecogniser];
	[self removeOurChildViewController:_centreViewController];
	
	_centreViewController				= centreViewController;
	
	if (!_centreViewController)			return;
	
	[self drawShadow];
	
	//	set ourselves as it's slide navigation controller
	_centreViewController.slideNavigationController	= self;
	
	//	set the cnetre view controll tag
	_centreViewController.view.tag		= kCentreViewTag;
	
	//	set the rasterisation scale to be the scale of the creen itself (avoid low resolution bitmap)
	_centreViewController.view.layer.rasterizationScale	= [UIScreen mainScreen].scale;
	
	//	this parallax effect is specific to the centre view
	[_centreViewController.view addMotionEffect:self.centreViewParallaxEffect];
	
	//	animate the setting of the frame
	[UIView animateWithDuration:1.0f animations:
	^{
		 _centreViewController.view.frame= kCentreViewFrame;
	}];
	
	//	add the pan gesture recogniser allowing the sliding of the view
	[_centreViewController.view addGestureRecognizer:self.panGestureRecogniser];
	//	add tap gesture recogniser to easily get back to centre view
	[_centreViewController.view addGestureRecognizer:self.centreTapGestureRecogniser];
	
	//	adopt the view controller and it's view
	[self.view addSubview:_centreViewController.view];
	[self addChildViewController:_centreViewController];
	[_centreViewController didMoveToParentViewController:self];
}

/**
 *	Sets the view controller to swiped in from the left.
 *
 *	@param	leftViewController			The left view controller.
 */
- (void)setLeftViewController:(UIViewController *)leftViewController
{
	[self removeOurChildViewController:_leftViewController];
	
	_leftViewController					= leftViewController;
	
	_leftViewController.view.tag		= kLeftViewTag;
	
	if (!_leftViewController)			return;
	
	_leftViewController.view.frame		= self.sideContainerView.bounds;
	
	if ([_leftViewController respondsToSelector:@selector(setLeftDelegate:)] &&
		[self.centreViewController conformsToProtocol:@protocol(LeftControllerDelegate)])
		[_leftViewController performSelector:@selector(setLeftDelegate:) withObject:self.centreViewController];
	
	[self.sideContainerView addSubview:_leftViewController.view];
	[self addChildViewController:_leftViewController];
	[_leftViewController didMoveToParentViewController:self];
}

/**
 *	Sets the view controller to swiped in from the right.
 *
 *	@param	rightViewController		The right view controller.
 */
- (void)setRightViewController:(UIViewController *)rightViewController
{
	[self removeOurChildViewController:_rightViewController];
	
	_rightViewController				= rightViewController;
	
	_rightViewController.view.tag		= kRightViewTag;
	
	if (!_rightViewController)			return;
	
	_rightViewController.view.frame		= self.sideContainerView.bounds;
	
	if ([_rightViewController respondsToSelector:@selector(setRightDelegate:)] &&
		[self.centreViewController conformsToProtocol:@protocol(RightControllerDelegate)])
		[_rightViewController performSelector:@selector(setRightDelegate:) withObject:self.centreViewController];
	
	[self.sideContainerView addSubview:_rightViewController.view];
	[self addChildViewController:_rightViewController];
	[_rightViewController didMoveToParentViewController:self];
}

#pragma mark - Side View Moving

/**
 *	Aligns the left view with the centre view (regarding the x-axis).
 */
- (void)alignLeftViewWithCentre
{
	if (!self.leftViewController)		return;
	
	CGRect leftViewFrame				= self.leftViewController.view.frame;
	leftViewFrame.size.width			= kSideViewWidth;
	leftViewFrame.origin.x				= self.centreViewController.view.frame.origin.x  - leftViewFrame.size.width;
	self.leftViewController.view.frame	= leftViewFrame;
}

/**
 *	Aligns the right view with the centre view (regarding the x-axis).
 */
- (void)alignRightViewWithCentre
{
	if (!self.rightViewController)		return;
	
	CGRect rightViewFrame				= self.rightViewController.view.frame;
	rightViewFrame.size.width			= kSideViewWidth;
	rightViewFrame.origin.x				= self.centreViewController.view.frame.origin.x  - rightViewFrame.size.width;
	self.rightViewController.view.frame	= rightViewFrame;
}

/**
 *	Sets the left view controller's position to a closed state.
 */
- (void)closeLeftView
{
	if (!self.leftViewController)		return;
	
	CGRect leftViewFrame				= self.leftViewController.view.frame;
	leftViewFrame.size.width			= kSideViewWidth;
	leftViewFrame.origin.x				= self.simultaneouslySlideSideViews ? -leftViewFrame.size.width : 0.0f;
	leftViewFrame.origin.y				= 0.0f;
	self.leftViewController.view.frame	= leftViewFrame;
	self.leftViewController.view.autoresizingMask	= UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
}

/**
 *	Sets the left view controller's position to a closed state.
 */
- (void)closeRightView
{
	if (!self.rightViewController)		return;
	
	CGRect rightViewFrame				= self.rightViewController.view.frame;
	rightViewFrame.size.width			= kSideViewWidth;
	rightViewFrame.origin.x				= self.centreViewController.view.frame.size.width - kSideViewWidth;
	if (self.simultaneouslySlideSideViews)
		rightViewFrame.origin.x			+= kSideViewWidth;
	rightViewFrame.origin.y				= 0.0f;
	self.rightViewController.view.frame	= rightViewFrame;
	self.rightViewController.view.autoresizingMask	= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
}

/**
 *	Prepare the left view controller's view to be shown.
 */
- (void)prepareLeftViewToShow
{
	self.leftViewController.view.hidden			= NO;
	[self.sideContainerView bringSubviewToFront:self.leftViewController.view];
}

/**
 *	Prepare the right view controller's view to be shown.
 */
- (void)prepareRightViewToShow
{
	self.rightViewController.view.hidden			= NO;
	[self.sideContainerView bringSubviewToFront:self.rightViewController.view];
}

#pragma mark - UIGestureRecogniserDelegate Methods

/**
 *	Ask the delegate if a gesture recognizer should receive an object representing a touch.
 *
 *	@param	gestureRecognizer			An instance of a subclass of the abstract base class UIGestureRecognizer.
 *	@param	touch						A UITouch object from the current multi-touch sequence.
 *
 *	@return	YES to allow the gesture recognizer to examine the touch object, NO to prevent the gesture recognizer from seeing this touch object.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	   shouldReceiveTouch:(UITouch *)touch
{
	//	if this is the centre tap gesture recogniser and the centre view controller is not centred we return YES
	if (gestureRecognizer == self.centreTapGestureRecogniser &&
		self.controllerState != SlideNavigationSideControllerClosed)
		return YES;
	
	//	if the previous controller has been tapped on this is fine
	else if (gestureRecognizer == self.previousTapGestureRecogniser)
		return YES;
	
	//	if this is a pan gesture recogniser we check whether the view requesting it is allowed
	else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
	{
		if (gestureRecognizer.view == self.centreViewController.view && self.centreViewControllerPanEnabled)
			return YES;
		else if (gestureRecognizer.view == self.centreViewController.view && self.sideViewPanEnabled)
			return YES;
	}
	
	return NO;
}

/**
 *	Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
 *
 *	@param	gestureRecogniser			A UIGestureRecognizer object sending this message.
 *	@param	otherGestureRecogniser		An instance of a subclass of the abstract base class UIGestureRecognizer.
 *
 *	@return	YES to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously, NO otherwise.
 */
- (BOOL)						 gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return NO;
}

/**
 *	Asks the view if the gesture recognizer should be allowed to continue tracking touch events.
 *
 *	@param	gestureRecognizer			The gesture recognizer that is attempting to transition out of the UIGestureRecognizerStatePossible state.
 *
 *	@return	YES if the gesture recognizer should continue tracking touch events and use them to trigger a gesture, NO otherwise.
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return YES;
}

#pragma mark - Utility Methods - Calculation

/**
 *	Calculates the duration of animation with the given positions.
 *
 *	@param	startPosition				The starting x co-ordinate of th eobject being animated.
 *	@param	endPosition					The desired ending x co-ordinate of th eobject being animated.
 *
 *	@return	An NSTimeInterval for how long the animation between the two given positions should take.
 */
- (NSTimeInterval)animationDurationFromStartPosition:(CGFloat)startPosition
									   toEndPosition:(CGFloat)endPosition
{
	//	calculate the absolute difference between the two positions
	CGFloat animationPositionDelta		= ABS(endPosition - startPosition);
	
	NSTimeInterval duration;
	
	//	if the the pan gesture is the reason for this animation we try to continue at the speed of the pan
	if (ABS(self.panGestureVelocity) > 1.0f)
		duration						= animationPositionDelta / ABS(self.panGestureVelocity);
	
	//	otherwise if this was simply due to a button press we calculate accordingly
	else
	{
		CGFloat animationPercent		=  animationPositionDelta == 0.0f ? 0.0f : kSideViewWidth / animationPositionDelta;
		duration						= kDefaultAnimationDuration * animationPercent;
	}
		
	//	return either the duration, or the maximum length if calculated duration is too long
	return MIN(duration, kMaxAnimationDuration);
}

#pragma mark - View Controller Containment

/**
 *	Convenience method for removing a child view controller and it's view.
 *
 *	@param	childViewController			The child view controller to remove.
 */
- (void)removeOurChildViewController:(UIViewController *)childViewController
{
	if (!childViewController)			return;
	
	[childViewController willMoveToParentViewController:nil];
	[childViewController.view removeFromSuperview];
	[childViewController removeFromParentViewController];
}

@end