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

#pragma mark - Optional Methods

@optional

/**
 *	Called to get the attribution dictionary for the recipe being shown in the delegate.
 *
 *	@return	A dictionary with the details required for correct attribution for a recipe.
 */
- (NSDictionary *)attributionDictionaryForCurrentRecipe;
/**
 *	Sent to the delegate with a block that should be called when the attribution dictionary has been loaded.
 *
 *	@param	attributionDictionaryLoaded	A block to be called with a loaded attribution dictionary.
 */
- (void)blockToCallWithAttributionDictionary:(AttributionDictionaryLoaded)attributionDictionaryLoaded;
/**
 *	Instructs the centre view controller to open a URL in a web view of some sort.
 *
 *	@param	url							An NSURL to open in some sort of web view.
 *	@param	rightViewController			The new right view controller to present alongside the URL in a web view of some sort.
 */
- (void)openURL:(NSURL *)url withRightViewController:(UIViewController *)rightViewController;
/**
 *	Called when the user has updated selections available in the right view controller/
 *
 *	@param	rightViewController			The right view updated with selections.
 *	@param	selections					A dictionary of selection updates in the right view controller.
 */
- (void)rightController:(UIViewController *)rightViewController
  updatedWithSelections:(NSDictionary *)selections;

@end