//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "MainViewController.h"
#import "LeftControllerDelegate.h"
#import "RightControllerDelegate.h"
#import "UIView+AlphaControl.h"

@import QuartzCore;

#pragma mark - View Controller Tags

NS_ENUM(NSUInteger, ControllerViewTags)
{
	kCentreViewTag						= 1,
	kLeftViewTag,
	kRightViewTag
};

#pragma mark - Static & Constant Variables

#define kCentreViewFrame				CGRectMake(0.0f, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - 20.0f)
#define kSideViewFrame					CGRectMake(0.0f, 30.0f, self.view.bounds.size.width, self.view.bounds.size.height - 50.0f)

#define PanGestureCleared(panGesture)	abs(panGesture.view.center.x - self.centreViewController.view.bounds.size.width / 2) > \
										(self.centreViewController.view.bounds.size.width / 2)

static CGFloat const kCornerRadius		= 04.00f;
static CGFloat const kShrinkDuration	= 00.50f;
static CGFloat const kSlideTiming		= 00.50f;

static NSString *const kCentreVCKey		= @"Centre";
static NSString *const kLeftVCKey		= @"Left";
static NSString *const kRightVCKey		= @"Right";

#pragma mark - Main View Controller Private Class Extension

@interface MainViewController () <UIGestureRecognizerDelegate> {}

/**	This back button can be set on the centre view controller to manage navigation.	*/
@property (nonatomic, strong)	UIBarButtonItem				*backButton;
/**	This boolean tells us whether we should be the first to adopt pan gestures.	*/
@property (nonatomic, assign)	BOOL						canTrackTouches;
/**	A motion effect deigned for the centre view controller.	*/
@property (nonatomic, strong)	UIMotionEffectGroup			*centreViewParallaxEffect;
/**	A motion effect designed for the side view controllers*/
@property (nonatomic, strong)	UIMotionEffectGroup			*childViewParallaxEffect;
/**	*/
@property (nonatomic, assign)	CGPoint						preVelocity;
/**	*/
@property (nonatomic, assign)	BOOL						showingLeftPanel;
/**	*/
@property (nonatomic, assign)	BOOL						showingRightPanel;
/**	*/
@property (nonatomic, assign)	BOOL						showPanel;

/**	*/
@property (nonatomic, strong)	UIPanGestureRecognizer		*panGestureRecogniser;
/**	*/
@property (nonatomic, strong)	UITapGestureRecognizer		*tapGestureRecogniser;

/**	*/
@property (nonatomic, strong)	UIViewController <CentreViewControllerProtocol>	*centreViewController;
/**	*/
@property (nonatomic, strong)	UIViewController								*leftViewController;
/**	*/
@property (nonatomic, strong)	UIViewController								*rightViewController;

/**	*/
@property (nonatomic, strong)	NSMutableArray									*pastViewControllerDictionaries;

@end

#pragma mark - Main View Controller Implementation

@implementation MainViewController {}

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
	[self.tapGestureRecogniser.view removeGestureRecognizer:self.tapGestureRecogniser];
	
	//	gets the dictionary of view controller we want to transition to
	NSDictionary *desiredVCDictionary	= [self.pastViewControllerDictionaries lastObject];
	[self.pastViewControllerDictionaries removeObjectAtIndex:self.pastViewControllerDictionaries.count - 1];
	
	//	set the new view controllers to the current view controller except for the centre
	UIViewController <CentreViewControllerProtocol> *newCentreVC	= desiredVCDictionary[kCentreVCKey];
	self.leftViewControllerClass		= desiredVCDictionary[kLeftVCKey];
	self.rightViewControllerClass		= desiredVCDictionary[kRightVCKey];
	
	//	animate towards the centre view controller
	[self animateCentreViewControllerTransitionForwards:NO toViewController:newCentreVC withCompletionHandler:^(BOOL success)
	{
		//	when the animation has finished we want to complete the transition
		[self finishTransitionToViewController:newCentreVC];
	}];
}

/**
 *	This is called when a gesture is moving the panel.
 *
 *	@param	gesture						The gesture recogniser calling this method.
 */
- (void)movePanel:(UIPanGestureRecognizer *)gesture
{
	//	stop any animations that may already be occuring in this view
	[gesture.view.layer removeAllAnimations];
	
	[self.centreViewController resignFirstResponder];

	//	get the current velocity of the gesture
	CGPoint velocity					= [gesture velocityInView:gesture.view];
	
	//	handle the gesture depending on what state it is in
	switch (gesture.state)
	{
		case UIGestureRecognizerStateBegan:		[self panGestureBegan:gesture withVelocity:velocity];									break;
		case UIGestureRecognizerStateChanged:	[self panGestureChanged:gesture withVelocity:velocity];									break;
		case UIGestureRecognizerStateEnded:		[self panGestureEnded:gesture withVelocity:velocity];									break;
		default:																														break;
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
 *	Animate the transition from the current centre view controller to a new one.
 *
 *	@param	forwards					Whether this is a transition towards a new controller, or popping back to a previous one.
 *	@param	viewController				The view controller we want to transition to.
 *	@param	completionHandler			Called when the animations have finished.
 */
- (void)animateCentreViewControllerTransitionForwards:(BOOL)forwards
									 toViewController:(UIViewController <CentreViewControllerProtocol>*)viewController
								withCompletionHandler:(void (^)(BOOL success))completionHandler
{
	//	the view controller we're transitioning to is the child view and we add it accordingly
	UIView *childView									= viewController.view;
	if (!childView)										return;
	childView.frame										= kSideViewFrame;
	[self.view addSubview:viewController.view];
	[self.view sendSubviewToBack:childView];
	
	//	we get the centre frame offset to the left and get the default animation duration
	CGRect centreFrame								= kCentreViewFrame;
	centreFrame.origin.x							= self.view.bounds.size.width;
	CGFloat animationDuration						= kSlideTiming;
	
	//	if it is a push...
	if (forwards)
	{
		//	set the frame of the view being pushed off so it is off to the side
		childView.frame								= centreFrame;
		//	make the desired centre frame the size of the side views
		centreFrame									= kSideViewFrame;
		//	change the animation duration for the shrinking of the main view 
		animationDuration							= kShrinkDuration;
	}
		
	
	//	animate the push or pop
	[UIView animateWithDuration:animationDuration
					 animations:
	^{
		//	either slide the controller away for a pop, or shrink it a slighty, ready for a push
		self.centreViewController.view.frame		= centreFrame;
	}
					 completion:^(BOOL finished)
	{
		//	if it is a pop we have done everything we need to do and now call the completion handler
		if (!forwards)
		{
			[self resetMainView];
			[childView removeFromSuperview];
			completionHandler(finished);
		}
		else
		{
			//	bring the view controller we're pushing to the front
			[self.view bringSubviewToFront:childView];
			//	animate the pushing view controller sliding in
			[UIView animateWithDuration:kSlideTiming animations:
			^{
				childView.frame							= kCentreViewFrame;
			}
							 completion:^(BOOL finished)
			{
				//	remove the pushing subview and call the completion handler
				[childView removeFromSuperview];
				completionHandler(finished);
			}];
		}
	}];
}

/**
 *	Moves the centre panel left.
 */
- (void)movePanelLeft
{
	UIView *childView					= self.rightPanelView;
	if (!childView)										return;
	[self.view sendSubviewToBack:childView];
	
	CGRect centreFrame					= kCentreViewFrame;
	
	centreFrame.origin.x				= - self.view.bounds.size.width + kPanelWidth;
	
	[UIView animateWithDuration:kSlideTiming
					 animations:
	^{
		self.centreViewController.view.frame			= centreFrame;
	}
					 completion:^(BOOL finished)
	{
		if (finished)
		{
			[self.centreViewController setRightButtonTag:kButtonInUse];
			[childView addMotionEffect:self.self.childViewParallaxEffect];
		}
	}];
}

/**
 *	Moves the centre panel right.
 */
- (void)movePanelRight
{
	UIView *childView									= self.leftPanelView;
	if (!childView)										return;
	[self.view sendSubviewToBack:childView];
	
	CGRect centreFrame					= kCentreViewFrame;
	
	centreFrame.origin.x				= self.view.bounds.size.width - kPanelWidth;
	
	[UIView animateWithDuration:kSlideTiming
					 animations:
	^{
		self.centreViewController.view.frame			= centreFrame;
	}
					 completion:^(BOOL finished)
	{
		if (finished)
		{
			[self.centreViewController setLeftButtonTag:kButtonInUse];
			[childView addMotionEffect:self.childViewParallaxEffect];
		}
	}];
}

/**
 *	Moves the centre panel back to the original position.
 */
- (void)movePanelToOriginalPosition
{
	[UIView animateWithDuration:kSlideTiming
						  delay:0.0f
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:
	^{
		self.centreViewController.view.frame	= kCentreViewFrame;
	}
					 completion:^(BOOL finished)
	{
		[self resetMainView];
	}];
}

#pragma mark - Convenience & Helper Methods

/**
 *	A pan gesture has just started. 
 *
 *	@param	panGesture					The gesture object representing the gesture.
 *	@param	velocity					The velocity of the gesture in the view.
 */
- (void)panGestureBegan:(UIPanGestureRecognizer *)panGesture withVelocity:(CGPoint)velocity
{
	UIView *childView;
	
	//	if the velocity is right we check if we can show the left panel
	if (velocity.x > 0)
	{
		if (!self.showingRightPanel && self.leftViewControllerClass)
			childView					= self.leftPanelView;
	}
	
	//	otherwise the velocity is left and we check if we can show the right panel
	else
		if (!self.showingLeftPanel && self.rightViewControllerClass)
			childView					= self.rightPanelView;
	
	//	put child view in back and keep centre view in front
	[self.view sendSubviewToBack:childView];
	[panGesture.view bringSubviewToFront:panGesture.view];
	
	[self.centreViewController.view removeMotionEffect:self.centreViewParallaxEffect];
}

/**
 *	A pan gesture has just changed.
 *
 *	@param	panGesture					The gesture object representing the gesture.
 *	@param	velocity					The velocity of the gesture in the view.
 */
- (void)panGestureChanged:(UIPanGestureRecognizer *)panGesture withVelocity:(CGPoint)velocity
{
	CGPoint translation					= [panGesture translationInView:panGesture.view];
	
	//	if the velocity is right we react accordingly and same for left
	if (velocity.x > 0)
	{
		if (!self.leftViewControllerClass && !self.showingRightPanel)
		{
			[self movePanelToOriginalPosition];
			return;
		}
	}
	else
	{
		if (!self.rightViewControllerClass && !self.showingLeftPanel)
		{
			[self movePanelToOriginalPosition];
			return;
		}
	}
	
	//	check if we're now more than half way, and if so we are officially showing the panel
	self.showPanel						= PanGestureCleared(panGesture);
	
	CGPoint dragTranslation				= CGPointMake(panGesture.view.layer.position.x + translation.x, panGesture.view.layer.position.y);
	
	
	//	allow dragging only along the x-axis
	panGesture.view.layer.position		= dragTranslation;
	[panGesture setTranslation:CGPointZero inView:panGesture.view];
	
	//	if velocity's direction is constant
	//	if ((velocity.x * self.preVelocity.x) + (velocity.y * self.preVelocity.y) > 0);
	//	otherwise if the direction has changed
	//	else ;
}

/**
 *	A pan gesture has just ended.
 *
 *	@param	panGesture					The gesture object representing the gesture.
 *	@param	velocity					The velocity of the gesture in the view.
 */
- (void)panGestureEnded:(UIPanGestureRecognizer *)panGesture withVelocity:(CGPoint)velocity
{
	//	if the velocity is right we react accordingly and same for left
	//if (velocity.x > 0);
	//else;
	
	if (!self.showPanel)
		[self movePanelToOriginalPosition];
	else
	{
		if (self.showingLeftPanel)
		{
			[self movePanelRight];
			if (self.pastViewControllerDictionaries.count > 0)
				[self.leftViewController.view addGestureRecognizer:self.tapGestureRecogniser];
		}
		else if (self.showingRightPanel)
			[self movePanelLeft];
	}
	
	[self.centreViewController.view addMotionEffect:self.centreViewParallaxEffect];
}

#pragma mark - Initialisation

/**
 *	Called to initialise a class instance with a centre view controller to adopt.
 *
 *	@param	centreViewController		The view controller to present in the centre.
 */
- (instancetype)initWithCentreViewController:(UIViewController <CentreViewControllerProtocol> *)centreViewController
{
	if (self = [super init])
	{
		self.centreViewController		= centreViewController;
		//	whenever a subview want to control the pan gesture recogniser we honour that
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewTrackingTouch:) name:kSubviewTrackingTouch object:nil];
		self.canTrackTouches			= YES;
		self.backButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_back_yummly"]
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(backButtonPressed)];
		self.pastViewControllerDictionaries	= [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark - Notification Methods

/**
 *	Called when a subview is currently tracking touches.
 *
 *	@param	notification				The notification object paired with this notification.
 */
- (void)subviewTrackingTouch:(NSNotification *)notification
{
	self.canTrackTouches				= ![notification.object boolValue];
}

#pragma mark - Property Accessor Methods

/**
 *	Returns the temporary left controller's view.
 */
- (UIView *)leftPanelView
{
	self.leftViewController.view.frame	= kSideViewFrame;
	
	self.showingLeftPanel				= YES;
	
	//	set up view shadows
	[self showCenterViewWithShadow:YES withOffset:CGSizeMake(-2.0f, -2.0f)];
	
	UIView *view						= self.leftViewController.view;
	return view;
}

/**
 *	Returns the temporary right controller's view.
 */
- (UIView *)rightPanelView
{
	self.rightViewController.view.frame	= kSideViewFrame;
	
	self.showingRightPanel				= YES;
	
	//	set up view shadows
	[self showCenterViewWithShadow:YES withOffset:CGSizeMake(2.0f, -2.0f)];
	
	UIView *view						= self.rightViewController.view;
	return view;
}

#pragma mark - Setter & Getter Methods

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

/**
 *	This is the temporary form of the view controller that slides out form the left.
 *
 *	@return	A pointer to the left view controller that has been adopted by this view controller. 
 */
- (UIViewController *)leftViewController
{
	if (!_leftViewController && self.leftViewControllerClass)
	{
		_leftViewController					= self.leftViewControllerClass;
		
		[self.view addSubview:_leftViewController.view];
		[self addChildViewController:_leftViewController];
		[_leftViewController didMoveToParentViewController:self];
	}
	
	return _leftViewController;
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
		_panGestureRecogniser				= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
		_panGestureRecogniser.minimumNumberOfTouches	= 1;
		_panGestureRecogniser.maximumNumberOfTouches	= 1;
		_panGestureRecogniser.delegate					= self;
	}
	
	return _panGestureRecogniser;
}

/**
 *	This is the temporary form of the view controller that slides out form the right.
 *
 *	@return	A pointer to the right view controller that has been adopted by this view controller.
 */
- (UIViewController *)rightViewController
{
	if (!_rightViewController && self.rightViewControllerClass)
	{
		_rightViewController				= self.rightViewControllerClass;
		
		[self.view addSubview:_rightViewController.view];
		[self addChildViewController:_rightViewController];
		[_rightViewController didMoveToParentViewController:self];
	}
	
	return _rightViewController;
}

/**
 *	This centre view controller is the main controller displayed.
 *
 *	@param	centreViewController		Used to set some basics of the centre view controller.
 */
- (void)setCentreViewController:(UIViewController<CentreViewControllerProtocol> *)centreViewController
{
	if (_centreViewController)
	{
		[_centreViewController.view removeGestureRecognizer:self.panGestureRecogniser];
		[_centreViewController willMoveToParentViewController:nil];
		[_centreViewController.view removeFromSuperview];
		[_centreViewController removeFromParentViewController];
	}
	
	_centreViewController				= centreViewController;
	
	__weak MainViewController *weakSelf	= self;
	
	//	this is how the blog will communicate to us that it should move due to an action in it
	_centreViewController.movingViewBlock	= ^(MoveDestination movingDestination)
	{
		switch (movingDestination)
		{
			case MovingViewLeft:
				[weakSelf movePanelLeft];
				break;
			case MovingViewOriginalPosition:
				[weakSelf movePanelToOriginalPosition];
				break;
			case MovingViewRight:
				[weakSelf movePanelRight];
				break;
			default:
				break;
		}
	};

	_centreViewController.view.tag		= kCentreViewTag;
	
	//	this parallax effect is specific to the centre view
	[_centreViewController.view addMotionEffect:self.centreViewParallaxEffect];
	
	//	animate the setting of the frame
	[UIView animateWithDuration:1.0f animations:
	^{
		_centreViewController.view.frame= kCentreViewFrame;
	}];
	
	//	add the pan gesture recogniser allowing the sliding of the view
	[_centreViewController.view addGestureRecognizer:self.panGestureRecogniser];
	
	//	adopt the view controller and it's view
	[self.view addSubview:_centreViewController.view];
	[self addChildViewController:_centreViewController];
	[_centreViewController didMoveToParentViewController:self];
}

/**
 *	Setting of the temporary left view controller.
 *
 *	@param	leftViewController			A pointer to the permanent view controller.
 */
- (void)setLeftViewController:(UIViewController *)leftViewController
{
	if (_leftViewController)
	{
		[_leftViewController willMoveToParentViewController:nil];
		[_leftViewController.view removeFromSuperview];
		[_leftViewController removeFromParentViewController];
	}
	
	_leftViewController					= leftViewController;
}

/**
 *	Sets the view controller to swiped in from the left.
 *
 *	@param	leftViewControllerClass		The permanent version of the left view controller.
 */
- (void)setLeftViewControllerClass:(UIViewController *)leftViewControllerClass
{
	_leftViewControllerClass			= leftViewControllerClass;
	
	_leftViewControllerClass.view.tag	= kLeftViewTag;
	
	if ([_leftViewControllerClass respondsToSelector:@selector(setLeftDelegate:)] &&
		[self.centreViewController conformsToProtocol:@protocol(LeftControllerDelegate)])
		[_leftViewControllerClass performSelector:@selector(setLeftDelegate:) withObject:self.centreViewController];
}

/**
 *	Setting of the temporary right view controller.
 *
 *	@param	rightViewController			A pointer to the permanent view controller.
 */
- (void)setRightViewController:(UIViewController *)rightViewController
{
	if (_rightViewController)
	{
		[_rightViewController willMoveToParentViewController:nil];
		[_rightViewController.view removeFromSuperview];
		[_rightViewController removeFromParentViewController];
	}
	
	_rightViewController				= rightViewController;
}

/**
 *	Sets the view controller to swiped in from the right.
 *
 *	@param	rightViewControllerClass	The permanent version of the right view controller.
 */
- (void)setRightViewControllerClass:(UIViewController *)rightViewControllerClass
{
	_rightViewControllerClass			= rightViewControllerClass;
	
	_rightViewControllerClass.view.tag	= kRightViewTag;
	
	if ([_rightViewControllerClass respondsToSelector:@selector(setRightDelegate:)] &&
		[self.centreViewController conformsToProtocol:@protocol(RightControllerDelegate)])
		[_rightViewControllerClass performSelector:@selector(setRightDelegate:) withObject:self.centreViewController];
}

/**
 *	This tap gesture recogniser should be added to a previous centre view controller so when tapped on it will return.
 *
 *	@return	A fully initialisd and targeted tap gesture recogniser.
 */
- (UITapGestureRecognizer *)tapGestureRecogniser
{
	if (!_tapGestureRecogniser)
		_tapGestureRecogniser			= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previousViewTapped:)];
	
	return _tapGestureRecogniser;
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
	return YES;//self.canTrackTouches;
}

/**
 *	Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
 *
 *	@param	gestureRecogniser			An instance of a subclass of the abstract base class UIGestureRecognizer and the object sending this message.
 *	@param	otherGestureRecogniser		An instance of a subclass of the abstract base class UIGestureRecognizer.
 *
 *	@return	YES to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously, NO otherwise.
 */
- (BOOL)						 gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return NO;
}

#pragma mark - View Management Methods

/**
 * Handles the completion of transition centre view controllers.
 *
 *	@param	viewController				The view controller to become the new centre view controller.
 */
- (void)finishTransitionToViewController:(UIViewController <CentreViewControllerProtocol>*)viewController
{
	self.centreViewController						= viewController;
	
	//	if there are other view controller behind this one we set a back button
	if (self.pastViewControllerDictionaries.count)
		self.centreViewController.backButton = self.backButton;
}

/**
 *	Resets the main (centre) view.
 */
- (void)resetMainView
{
	//	remove left view and reset variables
	if (self.leftViewController)
	{
		//	set the temporary left view controller to nil to easily remove it from the main view controller
		self.leftViewController			= nil;
		[self.centreViewController setLeftButtonTag:kButtonNotInUse];
		self.showingLeftPanel			= NO;
	}
	
	//	remove right view and reset variables
	if (self.rightViewController)
	{
		self.rightViewController		= nil;
		[self.centreViewController setRightButtonTag:kButtonNotInUse];
		self.showingRightPanel			= NO;
	}
	
	//	remove view shadows
	[self showCenterViewWithShadow:NO withOffset:CGSizeZero];
}

/**
 *	Add or removes a shadow from the centre view controller as it is being shown.
 *
 *	@param	showShadow					Whether to show a shadow or remove it.
 *	@param	offset						The offset of the shadow we're showing or removing.
 */
- (void)showCenterViewWithShadow:(BOOL)showShadow
					  withOffset:(CGSize)offset
{
	if (showShadow)
	{
		self.centreViewController.view.layer.cornerRadius	= kCornerRadius;
		self.centreViewController.view.layer.shadowColor	= [UIColor blackColor].CGColor;
		self.centreViewController.view.layer.shadowOpacity	= 0.8f;
	}
	else
		self.centreViewController.view.layer.cornerRadius	= 0.0f;
	
	self.centreViewController.view.layer.shadowOffset	= offset;
}

/**
 *	Handles the transitioning to a new centre view controller.
 *
 *	@param	viewController				The view controller to be set as the new centre view controller.
 *	@param	rightViewController			The new right view controller to be paired with the new centre view controller.
 */
- (void)transitionCentreToViewController:(UIViewController <CentreViewControllerProtocol>*)viewController
			  withNewRightViewController:(UIViewController *)rightViewController
{
	//	create a dictionary of the current view controllers and add it to our array of them
	NSDictionary *pastVCDictionary		= @{kCentreVCKey: self.centreViewController,
											kLeftVCKey	: self.leftViewControllerClass,
											kRightVCKey	: self.rightViewControllerClass};
	[self.pastViewControllerDictionaries addObject:pastVCDictionary];
	
	//	remove the parallax effect from the centre view controller
	[self.centreViewController.view removeMotionEffect:self.centreViewParallaxEffect];
	//	make the old centre view controller the new left view controller and then animate everything
	self.leftViewControllerClass		= self.centreViewController;
	[self animateCentreViewControllerTransitionForwards:YES toViewController:viewController withCompletionHandler:^(BOOL success)
	{
		//	when the animation has finished we want to complete the transition and set the new right view controller
		[self finishTransitionToViewController:viewController];
		self.rightViewControllerClass	= rightViewController;
	}];
}

@end