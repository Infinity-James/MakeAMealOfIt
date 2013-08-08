//
//  PullToRefreshView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 08/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@class PullToRefreshView;

#pragma mark - Type Definitions

typedef NS_ENUM(NSUInteger, PullToRefreshState)
{
	PullToRefreshStateNormal,
	PullToRefreshStateReady,
	PullToRefreshStateLoading
};

#pragma mark - Pull To Refresh Delegate Protocol

@protocol PullToRefreshDelegate <NSObject>

#pragma mark - Optional Methods

@optional

/**
 *	Sent to the delegate when the pull to refresh has been triggered.
 *
 *	@param	pullToRefreshView			The view requesting the refresh.
 */
- (void)pullToRefreshViewRequestingRefresh:(PullToRefreshView *)pullToRefreshView;

/**
 *	Sent to the delegate to retrieve the timestamp of the last refresh that occured in the delegate.
 *
 *	@param	pullToRefreshView			The view asking for the timestamp of the last refresh.
 *
 *	@return	The timestamp of the last refresh that occured.
 */
- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)pullToRefreshView;

@end

#pragma mark - Pull To Refresh View Public Interface

@interface PullToRefreshView : UIView {}

#pragma mark - Public Properties

/**	The delegate interested in being notified in refreshes by this view.	*/
@property (nonatomic, weak)		id <PullToRefreshDelegate>	delegate;
/**	Whether this view should be enabled or not.	*/
@property (nonatomic, assign, getter = isEnabled)	BOOL	enabled;
/**	The scroll view that this PullToRefreshView is attached to.	*/
@property (nonatomic, strong)		UIScrollView				*scrollView;
/**	The current state of this PullToRefreshView.	*/
@property (nonatomic, assign)	PullToRefreshState			state;
/**	The content inset of the scroll view.	*/
@property (nonatomic, assign)	UIEdgeInsets				startingContentInset;

/**
 *	Ends the refreshing state of this view.
 */
- (void)endRefresh;
/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	scrollView					The scroll view that this view is attached to.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
/**
 *	Forces a refresh of the timestamp indicating when the delegate was last updated.
 */
- (void)refreshLastUpdated;

@end