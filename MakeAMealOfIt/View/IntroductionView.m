//
//  IntroductionView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "BlurView.h"
#import "IntroductionHeaderView.h"
#import "IntroductionView.h"

#pragma mark - Constants & Static Variables

#define kScrollViewHeight									self.bounds.size.height - 100.0f
/**	The padding to be applied to the scroll view's left and right side. */
static CGFloat const kScrollViewHorizontalPadding			= 5.0f;
/**	The duration for the animating of fading in a panel view which has been switched to.*/
static NSTimeInterval const kAnimationDurationPanelSwitch	= 0.3f;
/**	The duration for the animating of fading in a panel view which has been switched to.*/
static NSTimeInterval const kAnimationDurationDismiss		= 0.5f;
/**	The duration for the animating of fading in a panel view which has been switched to.*/
static NSTimeInterval const kAnimationDurationPresent		= 0.5f;

#pragma mark - Introduction View Private Class Extension

@interface IntroductionView () <UIScrollViewDelegate> {}

#pragma mark - Private Properties

/**	A translucent, blurry view to be used in the background if desired.	*/
@property (nonatomic, strong)	BlurView					*blurView;
/**	A UIScrollView to hold the IntroductionPanels.	*/
@property (nonatomic, strong)	UIScrollView				*contentScrollView;
/**	A view used to display a header for the panels.	*/
@property (nonatomic, strong)	IntroductionHeaderView		*headerView;
/**	Keeps track of the panel currently navigated to.	*/
@property (nonatomic, assign)	NSUInteger					currentPanelIndex;
/**	The page control to indicate what panel is being displayed.	*/
@property (nonatomic, strong)	UIPageControl				*pageControl;
/**	Array of IntroductionPanelViews passed in at initialisation.	*/
@property (nonatomic, copy)		NSArray						*panels;
/**	The button that allows the user to skip this whole introduction.	*/
@property (nonatomic, strong)	UIButton					*skipButton;

@end

#pragma mark - Introduction View Implementation

@implementation IntroductionView {}

#pragma mark - Action & Selector Methods

/**
 *	The user wants to skip this introduction.
 */
- (void)skipButtonTapped
{
	[self removeFromSuperviewAnimated:YES];
}

#pragma mark - Auto Layout Methods

/**
 *	Returns whether the receiver depends on the constraint-based layout system.
 *
 *	@return	YES if the view must be in a window using constraint-based layout to function properly, NO otherwise.
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	Update constraints for the view.
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self removeConstraints:self.constraints];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[headerView]-(padding)-|"
																 options:kNilOptions
																 metrics:@{@"padding": @(kScrollViewHorizontalPadding)}
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(30)-[headerView(==25)]-[scrollView(==scrollViewHeight)]"
																 options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
																 metrics:@{@"scrollViewHeight": @(kScrollViewHeight)}
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerView]-(padding)-[pageControl]"
																 options:NSLayoutFormatAlignAllCenterX
																 metrics:@{@"padding": @(kScrollViewHeight - 20.0f)}
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[skipButton]-(10)-|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[skipButton]-(10)-|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	
	[self sendSubviewToBack:self.blurView];
	[self bringSubviewToFront:self.pageControl];
}

#pragma mark - Initialisation

/**
 *	Handles the basic initialisation for this view.
 */
- (void)basicInitialisation
{
	self.autoresizingMask				= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backgroundColor				= kDarkGreyColour;
}

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		[self basicInitialisation];
    }
	
    return self;
}

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 *	@param	panels						The IntroductionPanels to be displayed in this IntroductionView.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame panels:(NSArray *)panels
{
    if (self = [super initWithFrame:frame])
	{
		[self basicInitialisation];
		self.panels						= panels;
    }
	
    return self;
}

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
*	@param	panels						The IntroductionPanels to be displayed in this IntroductionView.
 *	@param	headerImage					An image for the header of the introduction.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame panels:(NSArray *)panels headerImage:(UIImage *)headerImage
{
    if (self = [super initWithFrame:frame])
	{
		[self basicInitialisation];
		self.panels						= panels;
		self.headerView.headerImage		= headerImage;
    }
	
    return self;
}

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
*	@param	panels						The IntroductionPanels to be displayed in this IntroductionView.
 *	@param	headerText					The text to be displayed in the header.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame panels:(NSArray *)panels headerText:(NSString *)headerText
{
    if (self = [super initWithFrame:frame])
	{
		[self basicInitialisation];
		self.panels						= panels;
		self.headerView.headerText		= headerText;
    }
	
    return self;
}

#pragma mark - Panel Handling Methods

/**
 *	Makes a panel at a certain index visible.
 *
 *	@param	panelIndex					The index of the panel to make visible.
 */
- (void)makePanelVisibleAtIndex:(NSUInteger)panelIndex
{
	if (panelIndex >= self.panels.count)	return;
	
	[UIView animateWithDuration:kAnimationDurationPanelSwitch animations:
	^{
		for (NSUInteger index = 0; index < self.panels.count; index++)
			((UIView *)self.panels[index]).alpha	= index == panelIndex ? 1.0f : 0.0f;
	}];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	A translucent, blurry view to be used in the background if desired.
 *
 *	@return	An initialised BlurView.
 */
- (BlurView *)blurView
{
	if (!_blurView)
	{
		_blurView						= [[BlurView alloc] initWithFrame:self.bounds];
		_blurView.hidden				= YES;
		
		_blurView.translatesAutoresizingMaskIntoConstraints		= NO;
		[self addSubview:_blurView];
	}
	
	return _blurView;
}

/**
 *	A UIScrollView to hold the IntroductionPanels.
 *
 *	@return	An initialised UIScrollView.
 */
- (UIScrollView *)contentScrollView
{
	if (!_contentScrollView)
	{
		_contentScrollView									= [[UIScrollView alloc] init];
		_contentScrollView.delegate							= self;
		_contentScrollView.pagingEnabled					= YES;
		_contentScrollView.showsHorizontalScrollIndicator	= NO;
		_contentScrollView.showsVerticalScrollIndicator		= NO;
		
		_contentScrollView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_contentScrollView];
	}
	
	return _contentScrollView;
}

/**
 *	A view used to display a header for the panels.
 *
 *	@return	A view initialised to display a header.
 */
- (IntroductionHeaderView *)headerView
{
	if (!_headerView)
	{
		_headerView						= [[IntroductionHeaderView alloc] init];
		
		_headerView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_headerView];
	}
	
	return _headerView;
}

/**
 *	The page control to indicate what panel is being displayed.
 *
 *	@return	An initialised UIPageControl.
 */
- (UIPageControl *)pageControl
{
	if (!_pageControl)
	{
		_pageControl								= [[UIPageControl alloc] init];
		_pageControl.currentPageIndicatorTintColor	= [[UIColor alloc] initWithRed:011.0f / 255.0f
																			green:156.0f / 255.0f
																			 blue:218.0f / 255.0f
																			alpha:1.0f];
		_pageControl.numberOfPages					= self.panels.count;
		_pageControl.pageIndicatorTintColor			= [UIColor whiteColor];
		
		_pageControl.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_pageControl];
	}
	
	return _pageControl;
}

/**
 *	The button that allows the user to skip this whole introduction.
 *
 *	@return	An initialised and target UIButton.
 */
- (UIButton *)skipButton
{
	if (!_skipButton)
	{
		_skipButton						= [[UIButton alloc] init];
		[_skipButton addTarget:self action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
		[_skipButton setTitleColor:kYummlyColourMain
						  forState:UIControlStateNormal];
		[_skipButton setTitleColor:[UIColor whiteColor]
						  forState:UIControlStateHighlighted];
		
		_skipButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_skipButton];
	}
	
	return _skipButton;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"blurView"		: self.blurView,
			 @"headerView"		: self.headerView,
			 @"pageControl"		: self.pageControl,
			 @"scrollView"		: self.contentScrollView,
			 @"skipButton"		: self.skipButton			};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets the currently viewed panel index.
 *
 *	@param	currentPanelIndex			The panel now being currently viewed.
 */
- (void)setCurrentPanelIndex:(NSUInteger)currentPanelIndex
{
	_currentPanelIndex					= currentPanelIndex;
	
	//	make the current panel visible
	[self makePanelVisibleAtIndex:_currentPanelIndex];
}

/**
 *	Sets the array of IntroductionPanelViews passed in at initialisation.
 *
 *	@param	panels						Array of IntroductionPanelViews passed in at initialisation.
 */
- (void)setPanels:(NSArray *)panels
{
	if (_panels == panels)				return;
	
	_panels								= panels;
	
	//	calculate the size for the panels
	CGFloat scrollViewWidth				= self.bounds.size.width - (kScrollViewHorizontalPadding * 2.0f);
	CGRect panelFrame					= CGRectMake(0.0f, 0.0f, scrollViewWidth, kScrollViewHeight);
	
	for (IntroductionPanelView *panelView in _panels)
	{
		panelView.frame					= panelFrame;
		[self.contentScrollView addSubview:panelView];
		//	increase the origin so that the panels are side by side
		panelFrame.origin.x				+= scrollViewWidth;
	}
	
	UIView *lastClosingView				= [[UIView alloc] initWithFrame:panelFrame];
	[self.contentScrollView addSubview:lastClosingView];
	
	//	set the content size of the scroll view to hold the panels correctly
	self.contentScrollView.contentSize	= CGSizeMake(scrollViewWidth * (_panels.count + 1), kScrollViewHeight);
	
	//	set the current panel index at the beginning
	self.currentPanelIndex				= 0;
}

/**
 *	Sets whether this view should be translucent or not.
 *
 *	@param	Whether this view should be translucent or not.
 */
- (void)setTranslucent:(BOOL)translucent
{
	if (_translucent == translucent)	return;
	
	_translucent						= translucent;
	self.backgroundColor				= _translucent ? [UIColor clearColor] : kDarkGreyColour;
	self.blurView.hidden				= !_translucent;
}

#pragma mark - UIScrollViewDelegate Methods

/**
 *	Tells the delegate that the scroll view has ended decelerating the scrolling movement.
 *
 *	@param	scrollView					The scroll-view object that is decelerating the scrolling of the content view.
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.currentPanelIndex				= scrollView.contentOffset.x / scrollView.bounds.size.width;
	
	if (self.currentPanelIndex == self.panels.count)
		[self removeFromSuperviewAnimated:NO];
	else
		self.pageControl.currentPage	= self.currentPanelIndex;
}

/**
 *	Tells the delegate when the user scrolls the content view within the receiver.
 *
 *	@param	scrollView					The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//	if the user is trying to scroll to a panel that doesn't exist we indicate this by fading the panel
	if (self.currentPanelIndex == self.panels.count - 1)
	{
		CGFloat xOffset					= (self.panels.count * scrollView.bounds.size.width) - scrollView.contentOffset.x;
		CGFloat alpha					= xOffset / scrollView.bounds.size.width;
		self.alpha						= alpha;
	}
}

#pragma mark - Presentation & Dismissal

/**
 *	Presents this introduction view in another view.
 *
 *	@param	view						The view in which to present this introduction view.
 *	@param	animated					Whether to animate the presentation of this view or not.
 */
- (void)presentInView:(UIView *)view animated:(BOOL)animated
{
	self.alpha							= 0.0f;
	[view addSubview:self];
	
	[UIView animateWithDuration:animated ? kAnimationDurationPresent : 0.0f
					 animations:
	^{
		self.alpha						= 1.0f;
	}];
}

/**
 *	Unlinks the receiver from its superview and its window, and removes it from the responder chain.
 *
 *	@param	animated					Whether to remove in an animated fashion or not.
 */
- (void)removeFromSuperviewAnimated:(BOOL)animated
{
	[UIView animateWithDuration:animated ? kAnimationDurationDismiss : 0.0f
					 animations:
	^{
		self.alpha						= 0.0f;
	}
					 completion:^(BOOL finished)
	{
		[self removeFromSuperview];
	}];
}

@end