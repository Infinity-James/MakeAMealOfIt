//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "MainViewController.h"
#import "LeftControllerDelegate.h"
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

static CGFloat const kCornerRadius		= 04.00f;
static CGFloat const kSlideTiming		= 00.50f;

static NSString *const kCentreVCKey		= @"Centre";
static NSString *const kLeftVCKey		= @"Left";
static NSString *const kRightVCKey		= @"Right";

#pragma mark - Main View Controller Private Class Extension

@interface MainViewController () <UIGestureRecognizerDelegate> {}

@property (nonatomic, strong)	UIBarButtonItem				*backButton;
@property (nonatomic, assign)	BOOL						canTrackTouches;
@property (nonatomic, strong)	UIMotionEffectGroup			*centreViewParallaxEffect;
@property (nonatomic, strong)	UIMotionEffectGroup			*childViewParallaxEffect;
@property (nonatomic, assign)	CGPoint						preVelocity;
@property (nonatomic, assign)	BOOL						showingLeftPanel;
@property (nonatomic, assign)	BOOL						showingRightPanel;
@property (nonatomic, assign)	BOOL						showPanel;

@property (nonatomic, strong)	UIPanGestureRecognizer		*panGestureRecogniser;
@property (nonatomic, strong)	UITapGestureRecognizer		*tapGestureRecogniser;

@property (nonatomic, strong)	UIViewController <CentreViewControllerProtocol>	*centreViewController;
@property (nonatomic, strong)	UIViewController								*leftViewController;
@property (nonatomic, strong)	UIViewController								*rightViewController;

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
 *	returns a boolean value indicating whether rotation methods are forwarded to child view controllers
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	returns whether the view controller’s contents should auto rotate
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

/**
 *	sent to the view controller just before the user interface begins rotating
 *
 *	@param	toInterfaceOrientation		new orientation for the user interface
 *	@param	duration					duration of the pending rotation, measured in seconds
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	[self movePanelToOriginalPosition];
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
		animationDuration							= 0.5f;
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
	self.showPanel						= abs(panGesture.view.center.x - self.centreViewController.view.bounds.size.width / 2) >
												(self.centreViewController.view.bounds.size.width / 2);
	
	//	allow dragging only along the x-axis
	panGesture.view.layer.position		= CGPointMake(panGesture.view.layer.position.x + translation.x, panGesture.view.layer.position.y);
	[panGesture setTranslation:CGPointZero inView:panGesture.view];
	
	//	check for change in direction
	//	if ((velocity.x * self.preVelocity.x) + (velocity.y * self.preVelocity.y) > 0);
	//	else;
	
	self.preVelocity					= velocity;
}

/**
 *	a pan gesture has just ended
 *
 *	@param	panGesture					the gesture object representing the gesture
 *	@param	velocity					the velocity of the gesture in the view
 */
- (void)panGestureEnded:(UIPanGestureRecognizer *)panGesture withVelocity:(CGPoint)velocity
{
	//	if the velocity is right we react accordingly and same for left
	if (velocity.x > 0);
	else;
	
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
 *
 *
 *	@param
 */
- (void)subviewTrackingTouch:(NSNotification *)notification
{
	self.canTrackTouches				= ![notification.object boolValue];
}

#pragma mark - Property Accessor Methods

/**
 *	returns the left controller's view
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
 *	returns the right controller's view
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
 *	this is the controller that slides out form the left
 */
- (UIViewController *)leftViewController
{
	if (!_leftViewController && self.leftViewControllerClass)
	{
		_leftViewController					= self.leftViewControllerClass;
		
		_leftViewController.view.tag		= kLeftViewTag;
		
		if ([_leftViewController respondsToSelector:@selector(setLeftDelegate:)] &&
			[self.centreViewController conformsToProtocol:@protocol(LeftControllerDelegate)])
			[_leftViewController performSelector:@selector(setLeftDelegate:) withObject:self.centreViewController];
		
		[self.view addSubview:_leftViewController.view];
		[self addChildViewController:_leftViewController];
		[_leftViewController didMoveToParentViewController:self];
	}
	
	return _leftViewController;
}

/**
 *	the pan gesture recogniser used to pan the centre view left or right
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
 *	this is the controller that slides out from the right
 */
- (UIViewController *)rightViewController
{
	if (!_rightViewController && self.rightViewControllerClass)
	{
		_rightViewController				= self.rightViewControllerClass;
		
		_rightViewController.view.tag		= kRightViewTag;
		
		[self.view addSubview:_rightViewController.view];
		[self addChildViewController:_rightViewController];
		[_rightViewController didMoveToParentViewController:self];
	}
	
	return _rightViewController;
}

/**
 *	this centre view controller is the main controller displayed
 *
 *	@param	centreViewController		used to set some basics of the centre view controller
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
	[_centreViewController.view addMotionEffect:self.centreViewParallaxEffect];
	
	[UIView beginAnimations:nil context:NULL];
	_centreViewController.view.frame	= kCentreViewFrame;
	[UIView commitAnimations];
	
	[_centreViewController.view addGestureRecognizer:self.panGestureRecogniser];
	
	[self.view addSubview:_centreViewController.view];
	[self addChildViewController:_centreViewController];
	[_centreViewController didMoveToParentViewController:self];
}

/**
 *
 *
 *	@param
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
 *
 *
 *	@param
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
 *
 */
- (UITapGestureRecognizer *)tapGestureRecogniser
{
	if (!_tapGestureRecogniser)
		_tapGestureRecogniser			= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previousViewTapped:)];
	
	return _tapGestureRecogniser;
}

#pragma mark - View Lifecycle

/**
 *	prepares the receiver for service after it has been loaded from an interface builder archive, or nib file
 */
- (void)awakeFromNib
{
	[super awakeFromNib];
}

/**
 *	sent to the view controller when the app receives a memory warning
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/**
 *	notifies the view controller that its view was added to a view hierarchy
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

/**
 *	notifies the view controller that its view was removed from a view hierarchy
 */
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

/**
 *	notifies the view controller that its view is about to be removed from the view hierarchy
 *
 *	@param	animated					whether the view needs to be removed from the window with an animation
 */
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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
 */
- (void)transitionCentreToViewController:(UIViewController <CentreViewControllerProtocol>*)viewController
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
		//	when the animation has finished we want to complete the transition
		[self finishTransitionToViewController:viewController];
	}];
}

@end