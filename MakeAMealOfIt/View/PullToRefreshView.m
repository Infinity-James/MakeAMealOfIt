//
//  PullToRefreshView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 08/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AudioManager.h"
#import "PullToRefreshView.h"

#pragma mark - Constants & Static Variables

#define FrameWithScrollView(x)			CGRectMake(0.0f, 0.0f - x.bounds.size.height,	\
											x.bounds.size.width, x.bounds.size.height)

/**	The duration of the animation to switch the activity state.	*/
static NSTimeInterval const kAnimationDurationActivity		= 01.00f;
/**	The duration of the animation to flip the arrow.	*/
static NSTimeInterval const kAnimationDurationArrowFlip		= 00.20f;
/**	The duration of the animation indicating enabling and disabling this view.	*/
static NSTimeInterval const kAnimationDurationEnable		= 00.25f;
/**	The duration of the animation to switch from Ready to Loading.	*/
static NSTimeInterval const kAnimationDurationStartLoading	= 00.20f;
/**	The duration of the animation to switch from Loading to Normal.	*/
static NSTimeInterval const kAnimationDurationStopLoading	= 00.30f;
/**	*/
static CGFloat const kDefaultViewHeight						= 60.00f;
/**	The value at which to register the offset as the user wanting to refresh.	*/
static CGFloat const kRegisterRefreshYOffset				= 60.00f;

#pragma mark - Pull To Refresh View Private Class Extension

@interface PullToRefreshView () {}

#pragma mark - Private Properties

/**	A view that indicates loading.	*/
@property (nonatomic, strong)	UIActivityIndicatorView	*activityIndicatorView;
/**	An image of an arrow.	*/
@property (nonatomic, strong)	UIImageView				*arrowImageView;
/**	A label of an arrow.	*/
@property (nonatomic, strong)	UILabel					*arrowLabel;
/**	A label that indicates the last refresh of the delegate of this view.	*/
@property (nonatomic, strong)	UILabel					*lastUpdatedLabel;
/**	A label that indicates the state of this view.	*/
@property (nonatomic, strong)	UILabel					*statusLabel;

@end

#pragma mark - Pull To Refresh View Implementation

@implementation PullToRefreshView {}

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
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeCenterX
													multiplier:1.0f
													  constant:0.0f]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[updatedLabel]-[statusLabel]-(10)-|"
																 options:NSLayoutFormatAlignAllCenterX
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[arrowImage]-[statusLabel]"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[arrowLabel]-[statusLabel]"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[activityView]-[statusLabel]"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:nil
																   views:self.viewsDictionary]];
}

#pragma mark - Initialisation

/**
 *	Deallocates the memory occupied by the receiver.
 */
- (void)dealloc
{
	[self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	scrollView					The scroll view that this view is attached to.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
	CGRect frame						= FrameWithScrollView(scrollView);
	
	if (self = [super initWithFrame:frame])
	{
		self.scrollView					= scrollView;
		[self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
		_startingContentInset			= self.scrollView.contentInset;
		
		self.autoresizingMask			= UIViewAutoresizingFlexibleWidth;
		self.backgroundColor			= kYummlyColourMain;
		self.enabled					= YES;
		self.state						= PullToRefreshStateNormal;
	}
	
	return self;
}

#pragma mark - NSKeyValueObserving Methods

/**
 *	This message is sent to the receiver when the value at the specified key path relative to the given object has changed.
 *
 *	@param	keyPath						The key path, relative to object, to the value that has changed.
 *	@param	object						The source object of the key path keyPath.
 *	@param	change						A dictionary describing the changes that have been made to the value of the property at the key path relative to object.
 *	@param	context						The value that was provided when the receiver was registered to receive key-value observation notifications.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	//	if this is the content offset of the scroll view which has changed
	if ([keyPath isEqualToString:@"contentOffset"] && self.isEnabled)
	{
		CGPoint scrollViewOffset		= self.scrollView.contentOffset;
		
		//	if the user is still dragging the view
		if (self.scrollView.isDragging)
		{
			switch (self.state)
			{
				//	if the the view is already refreshing show the user the loading status unless they have scrolled back down
				case PullToRefreshStateLoading:
					if (scrollViewOffset.y >= 0.0f)
						self.scrollView.contentInset	= self.startingContentInset;
					else
						self.scrollView.contentInset	= UIEdgeInsetsMake(MIN(-scrollViewOffset.y, kDefaultViewHeight), 0.0f, 0.0f, 0.0f);
					break;
					
				//	if the view is currently normal, we check to see if the view has been pulled far enough to start refreshing
				case PullToRefreshStateNormal:
					if (scrollViewOffset.y < - kRegisterRefreshYOffset)
						[AudioManager playSound:@"psst1" withExtension:@"wav"],
						self.state		= PullToRefreshStateReady;
					break;
					
				//	if the view is ready to refresh we see if the user wants to cancel out
				case PullToRefreshStateReady:
					if (scrollViewOffset.y > - kRegisterRefreshYOffset && scrollViewOffset.y < 0.0f)
						self.state		= PullToRefreshStateNormal;
					break;
			}
		}
		
		//	if the user is no longer dragging
		else
		{
			//	if the user has let go and wants to refresh we animate the transition into loading and update the delegate if able
			if (self.state == PullToRefreshStateReady)
			{
				[UIView animateWithDuration:kAnimationDurationStartLoading animations:
				^{
					self.state			= PullToRefreshStateLoading;
				}];
				
				if ([self.delegate respondsToSelector:@selector(pullToRefreshViewRequestingRefresh:)])
					[self.delegate pullToRefreshViewRequestingRefresh:self];
			}
			
			//	update the frame of this view if the user has stopped dragging
			CGRect frame				= FrameWithScrollView(self.scrollView);
			frame.origin.x				= scrollViewOffset.x;
			self.frame					= frame;
		}
	}
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The view that indicates to the user that refreshing is occuring.
 *
 *	@return	An initialised UIActivityIndicatorView.
 */
- (UIActivityIndicatorView *)activityIndicatorView
{
	if (!_activityIndicatorView)
	{
		_activityIndicatorView			= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
		_activityIndicatorView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_activityIndicatorView];
	}
	
	return _activityIndicatorView;
}

/**
 *	An image of an arrow indicating which way the scroll view should be pulled.
 *
 *	@return	An initialised UIImageView with an arrow for it's image.
 */
- (UIImageView *)arrowImageView
{
	if (!_arrowImageView)
	{
		_arrowImageView						= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
		_arrowImageView.contentMode			= UIViewContentModeScaleAspectFit;
		
		_arrowImageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_arrowImageView];
	}
	
	return _arrowImageView;
}

/**
 *	A label	with an arrow indicating which way the scroll view should be pulled.
 *
 *	@return	An initialised UILabel configured to be positioned via AutoLayout.
 */
- (UILabel *)arrowLabel
{
	if (!_arrowLabel)
	{
		_arrowLabel						= [[UILabel alloc] init];
		_arrowLabel.backgroundColor		= [UIColor clearColor];
		_arrowLabel.font				= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody));
		_arrowLabel.text				= @"↑";
		_arrowLabel.textAlignment		= NSTextAlignmentCenter;
		_arrowLabel.textColor			= [UIColor whiteColor];
		
		_arrowLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_arrowLabel];
	}
	
	return _arrowLabel;
}

/**
 *	A label that indicates the last refresh of the delegate of this view.
 *
 *	@return	An initialised UILabel configured to be positioned via AutoLayout.
 */
- (UILabel *)lastUpdatedLabel
{
	if (!_lastUpdatedLabel)
	{
		_lastUpdatedLabel					= [[UILabel alloc] init];
		_lastUpdatedLabel.backgroundColor	= [UIColor clearColor];
		_lastUpdatedLabel.font				= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody));
		_lastUpdatedLabel.textAlignment		= NSTextAlignmentCenter;
		_lastUpdatedLabel.textColor			= [UIColor whiteColor];
		
		_lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_lastUpdatedLabel];
		
	}
	
	return _lastUpdatedLabel;
}

/**
 *	A label that indicates the state of this view.
 *
 *	@return	An initialised UILabel configured to be positioned via AutoLayout.
 */
- (UILabel *)statusLabel
{
	if (!_statusLabel)
	{
		_statusLabel					= [[UILabel alloc] init];
		_statusLabel.backgroundColor	= [UIColor clearColor];
		_statusLabel.font				= kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody));
		_statusLabel.textAlignment		= NSTextAlignmentCenter;
		_statusLabel.textColor			= [UIColor whiteColor];
		
		_statusLabel.translatesAutoresizingMaskIntoConstraints		= NO;
		[self addSubview:_statusLabel];
	}
	
	return _statusLabel;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"activityView"	: self.activityIndicatorView,
				@"arrowImage"	: self.arrowImageView,
				@"arrowLabel"	: self.arrowLabel,
				@"statusLabel"	: self.statusLabel,
				@"updatedLabel"	: self.lastUpdatedLabel};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets whether this view should be enabled or not.
 *
 *	@param	enabled						YES to enable the functionaility of this PullToRefresh, NO to disable it.
 */
- (void)setEnabled:(BOOL)enabled
{
	if (_enabled == enabled)			return;
	
	_enabled							= enabled;
	
	[UIView animateWithDuration:kAnimationDurationEnable animations:
	^{
		self.alpha						= _enabled ? 1.0f : 0.0f;
	}];
}

/**
 *	Sets the state for this PullToRefreshView.
 *
 *	@param	state						A PullToRefreshState to set this view to.
 */
- (void)setState:(PullToRefreshState)state
{
	_state								= state;
	
	switch (state)
	{
		case PullToRefreshStateLoading:
			self.statusLabel.text		= NSLocalizedString(@"Loading...", @"the view is loading");
			[self showActivity:YES animated:YES];
			[self setArrowFlipped:NO];
			self.scrollView.contentInset= UIEdgeInsetsMake(kDefaultViewHeight, 0.0f, 0.0f, 0.0f);
			break;
			
		case PullToRefreshStateNormal:
			self.statusLabel.text		= NSLocalizedString(@"Pull Down to Refresh", @"keep pulling the view down to refresh");
			[self showActivity:NO animated:NO];
			[self setArrowFlipped:NO];
			self.scrollView.contentInset= self.startingContentInset;
			break;
			
		case PullToRefreshStateReady:
			self.statusLabel.text		= NSLocalizedString(@"Release to Refresh", @"let go of the view to refresh it");
			[self showActivity:NO animated:NO];
			[self setArrowFlipped:YES];
			self.scrollView.contentInset= self.startingContentInset;
			break;
	}
}

#pragma mark - Refresh Management

/**
 *	Ends the refreshing state of this view.
 */
- (void)endRefresh
{
	if (self.state == PullToRefreshStateLoading)
	{
		[AudioManager playSound:@"pop" withExtension:@"wav"];
		[UIView animateWithDuration:kAnimationDurationStopLoading
						 animations:
		^{
			self.state					= PullToRefreshStateNormal;
		}];
		
	}
}

/**
 *	Forces a refresh of the timestamp indicating when the delegate was last updated.
 */
- (void)refreshLastUpdated
{
	NSDate *updatedDate					= [[NSDate alloc] init];
	
	if ([self.delegate respondsToSelector:@selector(pullToRefreshViewLastUpdated:)])
		updatedDate						= [self.delegate pullToRefreshViewLastUpdated:self];
	
	NSDateFormatter *dateFormatter		= [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle				= NSDateFormatterMediumStyle;
	dateFormatter.locale				= [NSLocale currentLocale];
	dateFormatter.timeStyle				= NSDateFormatterMediumStyle;
	
	self.lastUpdatedLabel.text			= [[NSString alloc] initWithFormat:NSLocalizedString(@"Last Updated: %@", @"when the view was last updated"), [dateFormatter stringFromDate:updatedDate]];
}

#pragma mark - User Interface

/**
 *	Sets the arrow's direction either up (default) or down (flipped).
 *
 *	@param	flipped						If YES the arrow is flipped upside down, if NO the arrow is set back to facing up.
 */
- (void)setArrowFlipped:(BOOL)flipped
{
	[UIView animateWithDuration:kAnimationDurationArrowFlip animations:
	^{
		self.arrowImageView.layer.affineTransform	= flipped ? CGAffineTransformMakeRotation(M_PI * 2.0f) : CGAffineTransformMakeRotation(M_PI);
		self.arrowLabel.text						= flipped ? @"↻" : @"↑";
	}];
}

/**
 *	Indicates to the user the activity of this view.
 *
 *	@param	showActivity				Whether or not the cue should represent activity, or no activity.
 *	@param	animated					YES to animate the activity cue, NO otherwise.
 */
- (void)showActivity:(BOOL)showActivity
			animated:(BOOL)animated
{
	showActivity ? [self.activityIndicatorView startAnimating] : [self.activityIndicatorView stopAnimating];
	
	[UIView animateWithDuration:(animated ? kAnimationDurationActivity : 0.0f) animations:
	^{
		self.arrowImageView.alpha	= self.arrowLabel.alpha	= (showActivity ? 0.0f : 1.0f);
	}];
}

@end