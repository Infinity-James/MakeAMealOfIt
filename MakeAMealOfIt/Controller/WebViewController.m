//
//  WebViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "WebViewController.h"

#pragma mark - Web View Controller Private Class Extension

@interface WebViewController () {}

#pragma mark - Private Properties

/**	The view responsible for displaying given URLs and them main view of this view controller.	*/
@property (nonatomic, strong)	UIWebView	*webView;

@end

#pragma mark - Web View Controller Implementation

@implementation WebViewController {}

/**
 *	Called when the view controller’s view needs to update its constraints.
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	NSUInteger toolbarHeight			= self.slideNavigationController.slideNavigationBar.frame.size.height;
	
	//	objects to be used in creating constraints
	//	NSLayoutConstraint *constraint;
	NSArray *constraints				= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toolbar)-[webView]|"
																	  options:kNilOptions
																	  metrics:@{	@"toolbar"	:	@(toolbarHeight)	}
																		views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	Initializes and returns a newly allocated web view controller displaying the specified URL.
 *
 *	@param	url							The URL to display in the web view of this controller.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithURL:(NSURL *)url
{
	if (self = [super init])
	{
		self.url						= url;
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	Sets the URL to be displayed in the web view.
 *
 *	@param	url							The URL to display in the web view of this controller.
 */
- (void)setUrl:(NSURL *)url
{
	if (_url == url)					return;
	
	_url								= [url copy];
	
	//	open the url in the web view
	NSURLRequest *urlRequest			= [[NSURLRequest alloc] initWithURL:_url];
	[self.webView loadRequest:urlRequest];
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"webView"		: self.webView	};
}

/**
 *	The view responsible for displaying given URLs and them main view of this view controller.
 *
 *	@return	A UIWebView initialised and added to this view.
 */
- (UIWebView *)webView
{
	if (!_webView)
	{
		_webView						= [[UIWebView alloc] init];
		
		_webView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_webView];
	}
	
	return _webView;
}

@end