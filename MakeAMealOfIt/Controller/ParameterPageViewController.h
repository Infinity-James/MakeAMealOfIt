//
//  ParameterPageViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIRightViewController.h"

@class ParameterPageViewController;

#pragma mark - Parameter Page Delegate Protocol

@protocol ParameterPageDelegate <NSObject>

@required

/**
 *	Sent to the delegate when a parameter has been selected in some fashion.
 *
 *	@param	parameterPageVC				The page calling this method.
 *	@param	metadata					The metadata description that was selected.
 *	@param	included					Whether the selected parameter is to be included or excluded.
 *
 *	@return	YES if metadata was included in the search, NO otherwise.
 */
- (BOOL)parameterPageViewController:(ParameterPageViewController *)parameterPageVC
				   selectedMetadata:(NSString *)metadata
						   included:(BOOL)included;

@end

#pragma mark - Parameters Page View Controller Public Interface

@interface ParameterPageViewController : UIRightViewController {}

#pragma mark - Public Properties

/**	The delegate for this page.	*/
@property (nonatomic, weak)		id <ParameterPageDelegate>	delegate;
/**	The index of this page within the containing page view controller.	*/
@property (nonatomic, assign)	NSUInteger					index;
/**	An array of options for this page to show.	*/
@property (nonatomic, strong)	NSArray						*options;
/**	The title of this page.	*/
@property (nonatomic, strong)	NSString					*optionCategoryTitle;

@end