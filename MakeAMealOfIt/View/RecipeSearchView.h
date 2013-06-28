//
//  RecipeSearchView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 17/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@protocol RecipeSearchViewController <NSObject>

@required

/**
 *	Called when a view controller was added to recipe search view.
 *
 *	@param	viewController				The view controller which was added to the our child view.
 */
- (void)addedViewController:(UIViewController *)viewController;
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

@property (nonatomic, weak)	UIViewController<RecipeSearchViewController>	*delegate;

@end