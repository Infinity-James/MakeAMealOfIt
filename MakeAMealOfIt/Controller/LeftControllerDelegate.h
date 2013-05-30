//
//  LeftControllerDelegate.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 29/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Type Definitions

typedef void(^LeftControllerDataModified)(NSDictionary *modifiedIngredient);

#pragma mark - Left Controller Delegate Protocol

static NSString *const kAddedSelections		= @"AddedSelections";
static NSString *const kAllSelections		= @"AllSelections";
static NSString *const kRemovedSelections	= @"RemovedSelections";

@protocol LeftControllerDelegate <NSObject>

#pragma mark - Required Methods

@required

- (void)blockToExecuteWhenDataModified:(LeftControllerDataModified)dataModifiedBlock;
- (void)leftController:(UIViewController *)leftViewController
 updatedWithSelections:(NSDictionary *)selections;

@end