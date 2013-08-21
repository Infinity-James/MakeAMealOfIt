//
//  RecipeSearchView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 17/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "OverlayActivityIndicator.h"

#pragma mark - RecipeSearchViewController Protocol

@protocol RecipeSearchViewController <NSObject>

@required

/**
 *	Called when a view controller was added to recipe search view.
 *
 *	@param	viewController				The view controller which was added to the our child view.
 */
- (void)addedViewController:(UIViewController *)viewController;
/**
 *	Sent to the delegate when a search will take place.
 */
- (void)searchWillExecute;
/**
 *	Called when a search was executed and returned with the results dictionary.
 *
 *	@param	results						The dictionary of results from the yummly response.
 */
- (void)searchExecutedForResults:(NSDictionary *)results;

@end

#pragma mark - Recipe Search View Public Interface

@interface RecipeSearchView : UIView

#pragma mark - Private Properties

/**	This view's delegate interested in the action of this view.	*/
@property (nonatomic, weak)		UIViewController<RecipeSearchViewController>	*delegate;

@end