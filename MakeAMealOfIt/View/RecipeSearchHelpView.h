//
//  RecipeSearchHelpView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Recipe Search Help View Public Interface

@interface RecipeSearchHelpView : UIView {}

#pragma mark - Public Methods

/**
 *	Sets the Boolean value that determines whether the view is hidden.
 *
 *	@param	hidden						A Boolean value that determines whether the view is hidden.
 *	@param	animated					Whether to animate the hiding of the view.
 */
- (void)setHidden:(BOOL)hidden
		 animated:(BOOL)animated;

@end