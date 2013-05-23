//
//  RecipesViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "CentreViewControllerProtocol.h"

#pragma mark - Recipes View Controller Public Interface

@interface RecipesViewController : UIViewController <CentreViewControllerProtocol>

@property (nonatomic, strong)	NSArray					*recipes;

@end