//
//  ParameterPageViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Parameters Page View Controller Public Interface

@interface ParameterPageViewController : UIViewController {}

#pragma mark - Public Properties

@property (nonatomic, assign)	NSUInteger	index;
@property (nonatomic, strong)	UILabel		*optionLabel;
@property (nonatomic, strong)	NSArray		*options;

@end