//
//  YummlyAttributionViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAttributionViewController.h"

#pragma mark - Yummly Attribution VC Private Class Extension

@interface YummlyAttributionViewController () {}

@end

#pragma mark - Yummly Attribution VC Implementation

@implementation YummlyAttributionViewController {}

#pragma mark - Autolayout Methods

/**
 *	called when the view controller’s view needs to update its constraints
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	
	
}

@end