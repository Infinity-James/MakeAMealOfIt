//
//  RightControllerDelegate.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Right Controller Delegate Protocol

typedef void(^AttributionDictionaryLoaded)(NSDictionary *attributionDictionary);

@protocol RightControllerDelegate <NSObject>

#pragma mark - Required Methods

@required

/**
 *	Called when the user has updated selections available in the right view controller/
 *
 *	@param	rightViewController			The right view updated with selections.
 *	@param	selections					A dictionary of selection updates in the right view controller.
 */
- (void)rightController:(UIViewController *)rightViewController
  updatedWithSelections:(NSDictionary *)selections;

#pragma mark - Optional Methods

/**
 *	Called to get the attribution dictionary for the recipe being shown in the delegate.
 *
 *	@return	A dictionary with the details required for correct attribution for a recipe.
 */
- (NSDictionary *)attributionDictionaryForCurrentRecipe;

- (void)blockToCallWithAttributionDictionary:(AttributionDictionaryLoaded)attributionDictionaryLoaded;

@end