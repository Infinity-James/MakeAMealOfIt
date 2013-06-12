//
//  ToolbarLabelYummlyTheme.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 20/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ToolbarLabelYummlyTheme.h"

#pragma mark - Toolbar Label Yummly Theme Implementation

@implementation ToolbarLabelYummlyTheme {}

#pragma mark - Theme Methods: Label Appearance

/**
 *	returns a dictionary of properties for uilabels
 */
- (NSDictionary *)labelTextDictionary
{
	return @{	UITextAttributeFont				: [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f],
				UITextAttributeTextColor		: kYummlyColourMain,
				UITextAttributeTextShadowColor	: [UIColor colorWithWhite:0.8f alpha:1.0f],
				UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
}

@end