//
//  MakeAMealOfItIntroduction.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Make A Meal Of It Introduction Public Interface

@interface MakeAMealOfItIntroduction : NSObject

#pragma mark - Public Methods

/**
 *	Whether or not the introduction has already been shown or not.
 *
 *	@return	YES if the introduction for this app has already been shown, NO otherwise.
 */
+ (BOOL)introductionHasBeenShown;
/**
 *	Presents a fully initialised and configured IntroductionView specifically for introducing this app.
 *
 *	@param	frame						The desired frame for the introduction view.
 *	@param	view						The view in which to display the introduction view.
 */
+ (void)showIntroductionViewWithFrame:(CGRect)frame inView:(UIView *)view;
/**
 *	Whether or not the introduction has already been shown or not.
 *
 *	@param	hasBeenShown				Sets whether the introduction has now been shown or not.
 */
+ (void)setIntroductionHasBeenShown:(BOOL)hasBeenShown;

@end