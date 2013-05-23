//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"

#pragma mark - View Controller Tags

NS_ENUM(NSUInteger, ControllerViewTags)
{
	kCentreViewTag						= 1,
	kLeftViewTag,
	kRightViewTag
};

#pragma mark - Static & Constant Variables

static CGFloat const kCornerRadius		= 04.00f;
//static CGFloat const kPanelWidth		= 60.00f;
static CGFloat const kSlideTiming		= 00.25f;

static NSString *const kCentreVCKey		= @"Centre";
static NSString *const kLeftVCKey		= @"Left";
static NSString *const kRightVCKey		= @"Right";

#pragma mark - Main View Controller Private Class Extension

@interface MainViewController () <UIGestureRecognizerDelegate> {}

@property (nonatomic, strong)	UIBarButtonItem				*backButton;
@property (nonatomic, assign)	BOOL						canTrackTouches;
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
 *	this is called when the back button is pressed
 */
- (void)backButtonPressed
{
	//	remove the tap gesture recogniser from the view now that it is not needed
	[self.tapGestureRecogniser.view removeGestureRecognizer:self.tapGestureRecogniser];
	
	//	gets the dictionary of view controller we want to transition to
	NSDictionary *desiredVCDictionary	= [self.pastViewControllerDictionaries lastObject];
	[self.pastViewControllerDictionaries removeObjectAtIndex:self.pastViewControllerDictionaries.count - 1];
	
	UIViewController <CentreViewControllerProtocol> *newCentreVC	= desiredVCDictionary[kCentreVCKey];
	self.leftViewControllerClass		= desiredVCDictionary[kLeftVCKey];
	self.rightViewControllerClass		= desiredVCDictionary[kRightVCKey];
	
	[self animateCentreViewControllerTransitionForwards:NO toViewController:newCentreVC];
}

/**
 *	this is called when a gesture is moving the panel
 *
 *	@param	gesture						the gesture recogniser calling this method
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
 *	this is called when a left view controller is representing a previous view and has been tapped
 *
 *	@param	tapGestureRecogniser		the tap gesture recogniser calling this methods
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
 *	animate the transition from the current centre view controller to a new one
 *
 *	@param	forwards					whether are trasition towards a new controller or back to a previosuly displayed one
 *	@param	viewController				the view controller we want to transition to
 */
- (void)animateCentreViewControllerTransitionForwards:(BOOL)forwards
									 toViewController:(UIViewController <CentreViewControllerProtocol>*)viewController
{
	UIView *childView									= viewController.view;
	if (!childView)										return;
	childView.frame										= self.view.bounds;
	[self.view addSubview:viewController.view];
	[self.view sendSubviewToBack:childView];
	
	[UIView animateWithDuration:kSlideTiming
					 animations:
	^{
		if (forwards)
			self.centreViewController.view.frame		= CGRectMake(-self.view.bounds.size.width, 0.0f,
																	 self.view.bounds.size.width, self.view.bounds.size.height);
		else
		{
			self.centreViewController.view.frame		= CGRectMake(self.view.bounds.size.width, 0.0f,
																	 self.view.bounds.size.width, self.view.bounds.size.height);
			//[self resetMainView];
		}
	}
					 completion:^(BOOL finished)
	{
		if (!forwards)
			[self resetMainView];
		[childView removeFromSuperview];
		self.centreViewController						= viewController;
		if (forwards)									self.centreViewController.backButton = self.backButton;
		NSLog(@"Left Controller: %@\nRight Controller: %@\nCentre Controller: %@", self.leftViewControllerClass, self.rightViewControllerClass, self.centreViewController);
	}];
}

/**
 *	moves the centre panel left
 */
- (void)movePanelLeft
{
	UIView *childView									= self.rightPanelView;
	if (!childView)										return;
	[self.view sendSubviewToBack:childView];
	
	[UIView animateWithDuration:kSlideTiming
					 animations:
	^{
		self.centreViewController.view.frame			= CGRectMake(-self.view.bounds.size.width + kPanelWidth, 0.0f,
																 self.view.bounds.size.width, self.view.bounds.size.height);
	}
					 completion:^(BOOL finished)
	{
		if (finished)
			[self.centreViewController setRightButtonTag:kButtonInUse];
	}];
}

/**
 *	moves the centre panel right
 */
- (void)movePanelRight
{
	UIView *childView									= self.leftPanelView;
	if (!childView)										return;
	[self.view sendSubviewToBack:childView];
	
	[UIView animateWithDuration:kSlideTiming
					 animations:
	^{
		self.centreViewController.view.frame			= CGRectMake(self.view.bounds.size.width - kPanelWidth, 0.0f,
																 self.view.bounds.size.width, self.view.bounds.size.height);
	}
					 completion:^(BOOL finished)
	{
		if (finished)
			[self.centreViewController setLeftButtonTag:kButtonInUse];
	}];
}

/**
 *	moves the centre panel back to the original position
 */
- (void)movePanelToOriginalPosition
{
	[UIView animateWithDuration:kSlideTiming
						  delay:0.0f
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:
	^{
		self.centreViewController.view.frame	= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
	}
					 completion:^(BOOL finished)
	{
		[self resetMainView];
	}];
}

#pragma mark - Convenience & Helper Methods

/**
 *	a pan gesture has just started 
 *
 *	@param	panGesture					the gesture object representing the gesture
 *	@param	velocity					the velocity of the gesture in the view
 */
- (void)panGestureBegan:(UIPanGestureRecognizer *)panGesture withVelocity:(CGPoint)velocity
{
	UIView *childView;
	
	//	if the velocity is right we check if we can show the left panel
	if (velocity.x > 0)
	{
		if (!self.showingRightPanel)
			childView					= self.leftPanelView;
	}
	
	//	otherwise the velocity is left and we check if we can show the right panel
	else
		if (!self.showingLeftPanel)
			childView					= self.rightPanelView;
	
	//	put child view in back and keep centre view in front
	[self.view sendSubviewToBack:childView];
	[panGesture.view bringSubviewToFront:panGesture.view];
}

/**
 *	a pan gesture has just changed
 *
 *	@param	panGesture					the gesture object representing the gesture
 *	@param	velocity					the velocity of the gesture in the view
 */
- (void)panGestureChanged:(UIPanGestureRecognizer *)panGesture withVelocity:(CGPoint)velocity
{
	CGPoint translation					= [panGesture translationInView:panGesture.view];
	
	//	if the velocity is right we react accordingly and same for left
	if (velocity.x > 0);
	else;
	
	//	check if we're now more than half way, and if so we are officially showing the panel
	self.showPanel						= abs(panGesture.view.center.x - self.centreViewController.view.bounds.size.width / 2) >
												(self.centreViewController.view.bounds.size.width / 2);
	
	//	allow dragging only along the x-axis
	panGesture.view.center				= CGPointMake(panGesture.view.center.x + translation.x, panGesture.view.center.y);
	[panGesture setTranslation:CGPointMake(0, 0) inView:panGesture.view];
	
	//	check for change in direction
	if ((velocity.x * self.preVelocity.x) + (velocity.y * self.preVelocity.y) > 0);
	else;
	
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
}

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 *
 *	@param	centreViewController		the view controller to present in the centre
 */
- (instancetype)initWithCentreViewController:(UIViewController <CentreViewControllerProtocol> *)centreViewController
{
	if (self = [super init])
	{
		self.centreViewController		= centreViewController;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewTrackingTouch:) name:kSubviewTrackingTouch object:nil];
		self.canTrackTouches			= YES;
		self.backButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_back"]
															   style:UIBarButtonItemStyleBordered
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
	self.leftViewController.view.frame	= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
	
	self.showingLeftPanel				= YES;
	
	//	set up view shadows
	[self showCenterViewWithShadow:YES withOffset:-2.0f];
	
	UIView *view						= self.leftViewController.view;
	return view;
}

/**
 *	returns the right controller's view
 */
- (UIView *)rightPanelView
{
	self.rightViewController.view.frame	= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
	
	self.showingRightPanel				= YES;
	
	//	set up view shadows
	[self showCenterViewWithShadow:YES withOffset:2.0f];
	
	UIView *view						= self.rightViewController.view;
	return view;
}

#pragma mark - Setter & Getter Methods

/**
 *	this is the controller that slides out form the left
 */
- (UIViewController *)leftViewController
{
	if (!_leftViewController && self.leftViewControllerClass)
	{
		_leftViewController					= self.leftViewControllerClass;
		
		_leftViewController.view.tag		= kLeftViewTag;
		
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
	_centreViewController.view.frame	= self.view.bounds;
	
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
 *
 *
 *	@param
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	   shouldReceiveTouch:(UITouch *)touch
{
	return self.canTrackTouches;
}

/**
 *	asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously
 *
 *	@param	gestureRecogniser			the instance of a subclass of uigesturerecogniser sending the message to the delegate
 *	@param	otherGestureRecogniser		the other instance of a subclass of uigesturerecogniser
 */
- (BOOL)						 gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return NO;
}

#pragma mark - View Management Methods

/**
 *	resets the main (centre) view
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
	[self showCenterViewWithShadow:NO withOffset:0.0f];
}

/**
 *
 *
 *	@param
 *	@param
 */
- (void)showCenterViewWithShadow:(BOOL)showShadow
					  withOffset:(double)offset
{
	if (showShadow)
	{
		self.centreViewController.view.layer.cornerRadius	= kCornerRadius;
		self.centreViewController.view.layer.shadowColor	= [UIColor blackColor].CGColor;
		self.centreViewController.view.layer.shadowOpacity	= 0.8f;
	}
	
	else
		self.centreViewController.view.layer.cornerRadius	= 0.0f;
	
	self.centreViewController.view.layer.shadowOffset	= CGSizeMake(offset, offset);
}

/**
 *
 *
 *	@param
 */
- (void)transitionCentreToViewController:(UIViewController <CentreViewControllerProtocol>*)viewController
{
	NSDictionary *pastVCDictionary		= @{kCentreVCKey: self.centreViewController,
											kLeftVCKey	: self.leftViewControllerClass,
											kRightVCKey	: self.rightViewControllerClass};
	[self.pastViewControllerDictionaries addObject:pastVCDictionary];
	self.leftViewControllerClass		= self.centreViewController;
	[self animateCentreViewControllerTransitionForwards:YES toViewController:viewController];
}

@end