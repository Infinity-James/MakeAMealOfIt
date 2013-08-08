//
//  WebViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UICentreViewController.h"

#pragma mark - Web View Controller Public Interface

@interface WebViewController : UICentreViewController {}

#pragma mark - Public Properties

/**	*/
@property (nonatomic, assign)	BOOL	modallyPresented;
/**	The URL that should be shown in the web view of this view controller.	*/
@property (nonatomic, copy)		NSURL	*url;

#pragma mark - Public Methods

/**
 *	Initializes and returns a newly allocated web view controller displaying the specified URL.
 *
 *	@param	url							The URL to display in the web view of this controller.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithURL:(NSURL *)url;

@end