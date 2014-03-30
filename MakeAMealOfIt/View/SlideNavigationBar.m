//
//  SlideNavigationToolbar.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 09/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "BlurView.h"
#import "SlideNavigationBar.h"
#import "TransparentToolbar.h"

/**	The correct frame for the toolbar sub-element.	*/
#define kCorrectToolbarFrame			CGRectMake(self.bounds.origin.x, self.bounds.size.height - self.toolbarHeight,	\
													self.bounds.size.width, self.toolbarHeight)
/**	The correct frame for the entirety of this slide navigation bar.	*/
#define kCorrectSlideBarFrame			CGRectMake(self.superview.bounds.origin.x, self.superview.bounds.origin.y,	\
													self.superview.bounds.size.width, self.slideBarHeight)

#pragma mark - Slide Navigation Bar Private Class Extension

@interface SlideNavigationBar () {}

/**	The blur view to blend in with the toolbar.	*/
@property (nonatomic, strong)	BlurView			*blurView;
/**	The toolbar element of this slide navigation bar.	*/
@property (nonatomic, strong)	TransparentToolbar	*toolbar;

@end

#pragma mark - Slide Navigation Bar Implementation

@implementation SlideNavigationBar {}

#pragma mark - Convenience & Helper Methods

/**
 *	Sets the frame for this view and all subviews.
 */
- (void)adjustFrames
{
	self.backgroundColor				= [UIColor clearColor];
	self.frame							= kCorrectSlideBarFrame;
	self.blurView.frame					= self.bounds;
	self.toolbar.frame					= kCorrectToolbarFrame;
	self.backgroundColor = kYummlyColourMain;
	[self bringSubviewToFront:self.toolbar];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		[self adjustFrames];
	}
	
	return self;
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
		[self adjustFrames];
    }
	
    return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The slide navigation bar alpha value.
 *
 *	@return	A value between 1.0 and 0.0 indicating the alpha level of the slide navigation bar.
 */
- (CGFloat)alpha
{
	return self.toolbar.alpha;
}

/**
 *	The blur view to blend in with the toolbar.
 *
 *	@return	A view which has been initialised and added to the view.
 */
- (BlurView *)blurView
{
	if (!_blurView)
	{
		_blurView						= [[BlurView alloc] initWithFrame:self.bounds];
		_blurView.blurTintColour		= kYummlyColourMain;
		[self addSubview:_blurView];
	}
	
	return _blurView;
}

/**
 *	Returns the correct height for this whole SlideNavigationBar, depending on the orientation.
 *
 *	@return	An adjusted bar height whether this is full screen or not.
 */
- (CGFloat)slideBarHeight
{
	CGFloat height						= self.toolbarHeight;
	
#ifdef FULLSCREENCENTRE
	height								+= 20.0f;
#endif
	
	return height;
}

/**
 *	The toolbar element of this slide navigation bar.
 *
 *	@return	An initialised toolbar to hold the elements
 */
- (TransparentToolbar *)toolbar
{
	if (!_toolbar)
	{
		_toolbar						= [[TransparentToolbar alloc] initWithFrame:kCorrectToolbarFrame];
		
		[self addSubview:_toolbar];
		[self bringSubviewToFront:_toolbar];
	}
	
	return _toolbar;
}

/**
 *	Returns the correct height for a toolbar, depending on the orientation.
 *
 *	@return	A smaller height for landscape and taller for portrait.
 */
- (CGFloat)toolbarHeight
{
	if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
		return 32.0f;
	
	return 44.0f;
}

/**
 *	A Boolean value that indicates this slide navigation bar's translucency.
 *
 *	@return	YES if this SlideNavigationBar is translucent, NO if not.
 */
- (BOOL)translucent
{
	return self.toolbar.translucent;
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	The setter for the slide navigation bar's alpha value.
 *
 *	@param	alpha						The view’s alpha value.
 */
- (void)setAlpha:(CGFloat)alpha
{
	self.toolbar.alpha					= alpha;
}

/**
 *	The setter of whether this view should be translucent or not.
 *
 *	@param	translucent					The desired Boolean value for the slide navigation bar's translucency.
 */
- (void)setTranslucent:(BOOL)translucent
{
	self.toolbar.translucent			= translucent;
}

#pragma mark - UIToolbar Methods

/**
 *	Removes all UIBarButtonItems from this SlideNavigationBar.
 */
- (void)removeItems
{
	self.toolbar.items					= nil;
}

/**
 *	Sets the items on the toolbar by animating the changes.
 *
 *	@param	items						The items to display on the toolbar.
 *	@param	animated					A Boolean value if set to YES animates the transition to the items; otherwise, does not.
 */
- (void)setItems:(NSArray *)items
		animated:(BOOL)animated
{
	[self.toolbar setItems:items animated:animated];
}

#pragma mark - UIView Methods

/**
 *	Lays out subviews.
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self adjustFrames];
}

#pragma mark - View-Related Observation Methods

/**
 *	Tells the view that its superview changed.
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	[self adjustFrames];
}

@end