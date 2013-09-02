//
//  WebViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "NetworkActivityIndicator.h"
#import "PullToRefreshView.h"
#import "SafariActivity.h"
#import "WebViewController.h"

#pragma mark - Web View Controller Private Class Extension

@interface WebViewController () <PullToRefreshDelegate, UIWebViewDelegate>  {}

#pragma mark - Private Properties

/**	A number to keep track of the amount of web laods currently occuring.	*/
@property (nonatomic, assign)	NSUInteger				currentLoads;
/**	The button that allows the user to dismiss this view controller.	*/
@property (nonatomic, strong)	UIBarButtonItem			*doneButton;
/**	An item that separate the UIBarButtonItems neatly.	*/
@property (nonatomic, strong)	UIBarButtonItem			*flexibleSpace;
/**	A button that allows the user to go forward to the next page.	*/
@property (nonatomic, strong)	UIBarButtonItem			*nextPageButton;
/**	A button that allows the user to go back to the previous page.	*/
@property (nonatomic, strong)	UIBarButtonItem			*previousPageButton;
/**	A few that allows the user to refresh the current web page.	*/
@property (nonatomic, strong)	PullToRefreshView		*pullToRefreshView;
/**	A button that allows the user to go refresh the current page.	*/
@property (nonatomic, strong)	UIBarButtonItem			*refreshPageButton;
/**	A button that allows the user to go share the current page.	*/
@property (nonatomic, strong)	UIBarButtonItem			*shareButton;
/**	A button that allows the user to stop loading the current page.	*/
@property (nonatomic, strong)	UIBarButtonItem			*stopButton;
/**	A toolbar used for navigation of the webView.	*/
@property (nonatomic, strong)	UIToolbar				*toolbar;
/**	The view responsible for displaying given URLs and them main view of this view controller.	*/
@property (nonatomic, strong)	UIWebView				*webView;

@end

#pragma mark - Web View Controller Implementation

@implementation WebViewController {}

#pragma mark - Action & Selector Methods

/**
 *	The user has tapped the button to share the current page displayed in the UIWebView.
 */
- (void)actionTapped
{
	SafariActivity *safariActivity		= [[SafariActivity alloc] init];
	
	NSString *initialTextString			= self.url.absoluteString;
	UIActivityViewController *activity	= [[UIActivityViewController alloc] initWithActivityItems:@[initialTextString, self.url]
																		   applicationActivities:@[safariActivity]];

	[self presentViewController:activity animated:YES completion:nil];
}

/**
 *	If this WebViewController is being modally present, this will dismiss it.
 */
- (void)doneTapped
{
	if (self.presentingViewController)
	{
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.webView stopLoading];
			[self dismissViewControllerAnimated:YES completion:
			^{
				[NetworkActivityIndicator forceStop];
			}];
		});
	}
}

/**
 *	The user has tapped the button to navigate the UIWebView to the next page.
 */
- (void)nextPageTapped
{
	[self.webView goForward];
}

/**
 *	The user has tapped the button to navigate the UIWebView to the previous page.
 */
- (void)previousPageTapped
{
	[self.webView goBack];
}

#pragma mark - Autolayout Methods

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
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(navBar)-[webView]|"
																	  options:kNilOptions
																	  metrics:@{@"navBar"	: @(toolbarHeight)	}
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar]|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
	[self.view bringSubviewToFront:self.toolbar];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Updates the status of the toolbar UIBarButtonItems.
 */
- (void)updateToolbarButtons
{
	self.nextPageButton.enabled			= self.webView.canGoForward;
	self.previousPageButton.enabled		= self.webView.canGoBack;
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
		//self.restorationIdentifier		= NSStringFromClass([self class]);
		self.url						= url;
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The button that allows the user to dismiss this view controller.
 *
 *	@return	A UIBarButtonItem to be added to the toolbar if this view has been presented in a modal fashion.
 */
- (UIBarButtonItem *)doneButton
{
	if (!_doneButton)
	{
		_doneButton						= [[UIBarButtonItem alloc] initWithTitle:@"Done"
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(doneTapped)];
		_doneButton.tintColor			= kYummlyColourMain;
		
	}
	
	return _doneButton;
}

/**
 *	An item that separates the UIBarButtonItems neatly.
 *
 *	@return	A UIBarButtonItem configured with the UIBarButtonSystemItemFlexibleSpace and no target / action.
 */
- (UIBarButtonItem *)flexibleSpace
{
	if (!_flexibleSpace)
		_flexibleSpace					= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:self
																		   action:nil];
	
	return _flexibleSpace;
}

/**
 *	A button that allows the user to go forward to the next page.
 *
 *	@return	A UIBarButtonItem to be added to the toolbar to control UIWebView.
 */
- (UIBarButtonItem *)nextPageButton
{
	if (!_nextPageButton)
		_nextPageButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_main_normal_nextpage_yummly"]
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(nextPageTapped)];
	
	return _nextPageButton;
}

/**
 *	A button that allows the user to go back to the previous page.
 *
 *	@return	A UIBarButtonItem to be added to the toolbar to control UIWebView.
 */
- (UIBarButtonItem *)previousPageButton
{
	if (!_previousPageButton)
	{
		UIImage *previousPageImage		= [UIImage imageNamed:@"barbuttonitem_main_normal_previouspage_yummly"];
		
		_previousPageButton				= [[UIBarButtonItem alloc] initWithImage:previousPageImage
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(previousPageTapped)];
	}
	
	return _previousPageButton;
}

/**
 *	When pressed the user is able to share the web page.
 *
 *	@return	A button that allows the user to go share the current page.
 */
- (UIBarButtonItem *)shareButton
{
	if (!_shareButton)
		_shareButton					= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																		 target:self
																		 action:@selector(actionTapped)];
	
	return _shareButton;
}

/**
 *	A toolbar used for navigation of the webView
 *
 *	@return	An initialised UIToolbar added to the view.
 */
- (UIToolbar *)toolbar
{
	if (!_toolbar)
	{
		_toolbar						= [[UIToolbar alloc] init];
		_toolbar.translucent			= YES;
		
		_toolbar.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_toolbar];
		[self.view bringSubviewToFront:_toolbar];
	}
	
	return _toolbar;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"toolbar"		: self.toolbar,
				@"webView"		: self.webView	};
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
		_webView.delegate				= self;
		_webView.scalesPageToFit		= YES;
		
		self.pullToRefreshView			= [[PullToRefreshView alloc] initWithScrollView:_webView.scrollView];
		self.pullToRefreshView.delegate	= self;
		[_webView.scrollView addSubview:self.pullToRefreshView];
		
		_webView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_webView];
	}
	
	return _webView;
}

#pragma mark - Property Accessor Methods - Setters

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

#pragma mark - PullToRefreshDelegate Methods

/**
 *	Sent to the delegate when the pull to refresh has been triggered.
 *
 *	@param	pullToRefreshView			The view requesting the refresh.
 */
- (void)pullToRefreshViewRequestingRefresh:(PullToRefreshView *)pullToRefreshView
{
	[self.webView stopLoading];
	[self.webView reload];
}

#pragma mark - UIWebViewDelegate Methods

/**
 *	Sent if a web view failed to load a frame.
 *
 *	@param	webView						The web view that failed to load a frame.
 *	@param	error						The error that occurred during loading.
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	self.currentLoads--;
	
	[NetworkActivityIndicator stop];
	[self updateToolbarButtons];
}

/**
 *	Sent after a web view finishes loading a frame.
 *
 *	@param	webView						The web view has finished loading.
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	self.currentLoads--;
	
	[NetworkActivityIndicator stop];
	[self updateToolbarButtons];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self.pullToRefreshView];
	
	if (self.currentLoads == 0)
		[self.pullToRefreshView performSelector:@selector(endRefresh) withObject:nil afterDelay:0.5f];
}

/**
 *	Sent after a web view starts loading a frame.
 *
 *	@param	webView						The web view that has begun loading a new frame.
 */
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	self.currentLoads++;
	
	[NetworkActivityIndicator start];
	[self updateToolbarButtons];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self.pullToRefreshView];
	
	if (self.pullToRefreshView.state != PullToRefreshStateLoading && self.currentLoads == 1)
		self.pullToRefreshView.state	= PullToRefreshStateLoading;
}

#pragma mark - View Lifecycle

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSMutableArray *toolbarItems		= [@[self.previousPageButton, self.flexibleSpace, self.nextPageButton,
											 self.flexibleSpace, self.shareButton] mutableCopy];
	
	if (self.presentingViewController)
		[toolbarItems addObjectsFromArray:@[self.flexibleSpace, self.doneButton]];
	
	[self.toolbar setItems:toolbarItems
				  animated:YES];
	
	[self updateToolbarButtons];
}

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
}

/**
 *	Notifies the view controller that its view is about to layout its subviews.
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
}

@end