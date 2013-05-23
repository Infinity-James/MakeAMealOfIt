//
//  RecipeSearchView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 17/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@protocol RecipeSearchViewController <NSObject>

@required

- (void)addedViewController:(UIViewController *)viewController;
- (void)searchExecutedForResults:(NSDictionary *)results;

@end

#pragma mark - Recipe Search View Public Interface

@interface RecipeSearchView : UIView

#pragma mark - Private Properties

@property (nonatomic, weak)	UIViewController<RecipeSearchViewController>	*delegate;

@end