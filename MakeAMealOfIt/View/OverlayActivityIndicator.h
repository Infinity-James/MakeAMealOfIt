//
//  OverlayActivityIndicator.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Overlay Activity Indicator Public Interface

@interface OverlayActivityIndicator : UIView {}

#pragma mark - Public Properties

/**	The colour of the background of this view.	*/
@property (nonatomic, strong)	UIColor	*activityBackgroundColour;
/**	The colour of the activity indicator.	*/
@property (nonatomic, strong)	UIColor	*activityIndicatorColour;

#pragma mark - Public Methods

/**
 *	Starts the animation of the progress indicator.
 */
- (void)startAnimating;

/**
 *	Stops the animation of the progress indicator.
 */
- (void)stopAnimating;

@end