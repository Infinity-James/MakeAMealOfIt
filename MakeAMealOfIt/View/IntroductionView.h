//
//  IntroductionView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IntroductionPanelView.h"

#pragma mark - Introduction Delegate

#pragma mark - Introduction View Public Interface

@interface IntroductionView : UIView {}

#pragma mark - Public Properties

/**	Whether this view should be translucent or not.	*/
@property (nonatomic, assign)	BOOL	translucent;

#pragma mark - Public Methods: Initialisation

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 *	@param	panels						The IntroductionPanels to be displayed in this IntroductionView.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame panels:(NSArray *)panels;
/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 *	@param	panels						The IntroductionPanels to be displayed in this IntroductionView.
 *	@param	headerImage					An image for the header of the introduction.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame panels:(NSArray *)panels headerImage:(UIImage *)headerImage;
/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 *	@param	panels						The IntroductionPanels to be displayed in this IntroductionView.
 *	@param	headerText					The text to be displayed in the header.
 *
 *	@return	An initialized view object or nil if the object couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame panels:(NSArray *)panels headerText:(NSString *)headerText;

#pragma mark - Public Methods: Presentation & Dismissal

/**
 *	Presents this introduction view in another view.
 *
 *	@param	view						The view in which to present this introduction view.
 *	@param	animated					Whether to animate the presentation of this view or not.
 */
- (void)presentInView:(UIView *)view animated:(BOOL)animated;

@end