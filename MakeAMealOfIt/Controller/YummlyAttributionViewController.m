//
//  YummlyAttributionViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAttributionViewController.h"
#import "YummlySearchResult.h"

#pragma mark - Constants & Static Variables

static NSString *const kCompanyURLString	= @"http://james.dontexist.net/AndBeyond/";
static NSString *const kDeveloperURLString	= @"http://andbeyond.co";

#pragma mark - Yummly Attribution VC Private Class Extension

@interface YummlyAttributionViewController () {}

#pragma mark - Private Properties

/**	The Make A Meal Of It logo in an image view.	*/
@property (nonatomic, strong)	UIImageView				*appLogo;
/**	A label with the name of the app; Make A Meal Of It; on it.	*/
@property (nonatomic, strong)	UILabel					*appName;
/**	A dictionary with stuff to include in the attribution.	*/
@property (nonatomic, strong)	NSDictionary			*attributionDictionary;
/**	This label simply attributes Yummly for the data.	*/
@property (nonatomic, strong)	UILabel					*attributionText;
/**	This URL opens the Yummly website with a specific search or recipe.	*/
@property (nonatomic, strong)	NSURL					*attributionURL;
/**	The label that for my company.	*/
@property (nonatomic, strong)	UILabel					*companyLabel;
/**	The label I will use to show that I made it.	*/
@property (nonatomic, strong)	UILabel					*developerLabel;
/**	A tap gesture recogniser intended to open a url when triggered.	*/
@property (nonatomic, strong)	UITapGestureRecognizer	*urlGestureRecogniser;
/**	When clicked on it will open the Yuumly attribution URL in a web view of some sort.	*/
@property (nonatomic, strong)	UIButton				*yummlyButton;
/**	An image of the Yummly logo.	*/
@property (nonatomic, strong)	UIImage					*yummlyLogo;

@end

#pragma mark - Yummly Attribution VC Implementation

@implementation YummlyAttributionViewController {}

#pragma mark - Synthesise Properties

@synthesize attributionDictionary		= _attributionDictionary;

#pragma mark - Action & Selector Methods

/**
 *	Opens a web view with the attribution URL.
 */
- (void)openAttributionURL
{	
	NSLog(@"\nATTRIBUTION URL:\n %@", self.attributionURL);
	
	if ([self.rightDelegate respondsToSelector:@selector(openURL:withRightViewController:)])
		[self.rightDelegate openURL:self.attributionURL withRightViewController:nil];
}

/**
 *	Opens a URL for a given gesture recogniser in a web view of some sort.
 *
 *	@param	gestureRecogniser			The gesture recogniser responsible for calling this method.
 */
- (void)openURL:(UITapGestureRecognizer *)gestureRecogniser
{
	NSString *urlString;
	
	if (gestureRecogniser.view == self.companyLabel)
		urlString						= kCompanyURLString;
	else if (gestureRecogniser.view == self.developerLabel)
		urlString						= kDeveloperURLString;
		
	if ([self.rightDelegate respondsToSelector:@selector(openURL:withRightViewController:)])
		[self.rightDelegate openURL:[[NSURL alloc] initWithString:urlString] withRightViewController:nil];
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
	
	//	objects to be used in creating constraints
	NSLayoutConstraint *constraint;
	NSArray *constraints;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[developerLabel]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:[developerLabel]-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyLabel]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Panel)-[companyLabel]"
																options:kNilOptions
																metrics:@{ @"Panel" : @(kPanelWidth + 10.0f) }
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:[attributionText]-(>=20)-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.yummlyButton
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self.view
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:20.0f];
	[self.view addConstraint:constraint];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.yummlyButton
													attribute:NSLayoutAttributeWidth
													relatedBy:NSLayoutRelationEqual
													   toItem:nil
													attribute:NSLayoutAttributeNotAnAttribute
												   multiplier:1.0f
													 constant:44.0f];
	[self.yummlyButton addConstraint:constraint];
	constraint							= [NSLayoutConstraint constraintWithItem:self.yummlyButton
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:nil
													attribute:NSLayoutAttributeNotAnAttribute
												   multiplier:1.0f
													 constant:44.0f];
	[self.yummlyButton addConstraint:constraint];
	constraint							= [NSLayoutConstraint constraintWithItem:self.appLogo
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.appLogo
													attribute:NSLayoutAttributeWidth
												   multiplier:1.0f
													 constant:0.0f];
	[self.appLogo addConstraint:constraint];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:[appLogo]-(>=20)-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[appName]-[appLogo]-[attributionText]-[yummlyButton]"
																options:NSLayoutFormatAlignAllCenterX
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	attributionDictionary		A dictionary of things required for a Yummly attribution.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithAttributionDictionary:(NSDictionary *)attributionDictionary
{
	if (self = [super init])
	{
		self.attributionDictionary		= attributionDictionary;
	}
	
	return self;
}

/**
 *	Loads the subviews and lays out appropriately.
 */
- (void)loadSubviews
{
	dispatch_async(dispatch_queue_create("Logo Fetcher", NULL),
	^{
		UIImage *yummlyLogo				= [[UIImage alloc] initWithCGImage:self.yummlyLogo.CGImage
														scale:self.yummlyLogo.scale * 2.0f
												  orientation:self.yummlyLogo.imageOrientation];
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.yummlyButton setImage:yummlyLogo forState:UIControlStateNormal];
			[self.view setNeedsUpdateConstraints];
		});
	});
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The Make A Meal Of It logo in an image view.
 *
 *	@return	A fully initialise UIImageView with a set image.
 */
- (UIImageView *)appLogo
{
	if (!_appLogo)
	{
		UIImage *logoImage				= [UIImage imageNamed:@"logo_makeamealofit"];
		_appLogo						= [[UIImageView alloc] initWithImage:logoImage];
		
		_appLogo.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_appLogo];
	}
	
	return _appLogo;
}

/**
 *	A label with the name of the app; Make A Meal Of It; on it.
 *
 *	@return	A label stylised to represent this app's name.
 */
- (UILabel *)appName
{
	if (!_appName)
	{
		_appName						= [[UILabel alloc] init];
		_appName.backgroundColor		= [UIColor clearColor];
		_appName.font					= kYummlyBolderFontWithSize(18.0f);
		_appName.lineBreakMode			= NSLineBreakByWordWrapping;
		_appName.numberOfLines			= 0;
		_appName.text					= @"Make A Meal Of It";
		_appName.textAlignment			= NSTextAlignmentCenter;
		_appName.textColor				= kYummlyColourMain;
		
		_appName.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_appName];
	}
	
	return _appName;
}

/**
 *	This dictionary holds all of the details to attribute Yummly.
 *
 *	@return	A dictionary with a logo URL, attribution text, and URL to the Yummly website in it.
 */
- (NSDictionary *)attributionDictionary
{
	//	use lazy instantiation to make sure it is never a nil object
	if (!_attributionDictionary)
		_attributionDictionary			= @{	kYummlyAttributionHTMLKey	: @"",
												kYummlyAttributionLogoKey	: @"",
												kYummlyAttributionTextKey	: @"",
												kYummlyAttributionURLKey	: @""	};
	
	return _attributionDictionary;
}

/**
 *	Acts as a label to attribute Yummly and also allow the user to navigate to the Yummly website.
 *
 *	@return	A long button that when pressed will navigate to the Yummly website.
 */
- (UILabel *)attributionText
{
	//	lazy instantiation of the button
	if (!_attributionText)
	{
		_attributionText				= [[UILabel alloc] init];
		_attributionText.backgroundColor= [UIColor clearColor];
		_attributionText.font			= kYummlyFontWithSize(14.0f);
		_attributionText.lineBreakMode	= NSLineBreakByWordWrapping;
		_attributionText.numberOfLines	= 0;
		_attributionText.text			= self.attributionDictionary[kYummlyAttributionTextKey];
		_attributionText.textAlignment	= NSTextAlignmentCenter;
		_attributionText.textColor		= kYummlyColourMain;
		
		_attributionText.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_attributionText];
	}
	
	return _attributionText;
}

/**
 *	This URL either pertains a recipes search or a specific recipe.
 *
 *	@return	A URL that is taken from the attribution dictionary.
 */
- (NSURL *)attributionURL
{
	if (!_attributionURL)
	{
		_attributionURL					= [[NSURL alloc] initWithString:self.attributionDictionary[kYummlyAttributionURLKey]];
	}
	
	return _attributionURL;
}

/**
 *	A label that shows that &Beyond made this app.
 *
 *	@return	A label fully initialised with &Beyond on it.
 */
- (UILabel *)companyLabel
{
	if (!_companyLabel)
	{
		_companyLabel						= [[UILabel alloc] init];
		
		UIColor *andColour					= [[UIColor alloc] initWithRed:185.0f / 255.0f green:46.0f / 255.0f blue:0.0f alpha:1.0f];
		
		NSMutableAttributedString *company	= [[NSMutableAttributedString alloc] initWithString:@"&Beyond"
																					attributes:@{	NSTextEffectAttributeName	: NSTextEffectLetterpressStyle,
																									NSFontAttributeName			: kYummlyFontWithSize(14.0f)	}];
		[company addAttribute:NSForegroundColorAttributeName
						value:andColour
						range:NSMakeRange(0, 1)];
		[company addAttribute:NSForegroundColorAttributeName
						value:[UIColor blackColor]
						range:NSMakeRange(1, 6)];
		
		_companyLabel.attributedText			= company;
		_companyLabel.opaque					= YES;
		_companyLabel.userInteractionEnabled	= YES;
		[_companyLabel sizeToFit];
		
		[_companyLabel addGestureRecognizer:self.urlGestureRecogniser];
		
		_companyLabel.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_companyLabel];
	}
	
	return _companyLabel;
}

/**
 *	A label with the name of the developer on it; James Valaitis
 *
 *	@return	A fully initialised label to show who developed the app.
 */
- (UILabel *)developerLabel
{
	if (!_developerLabel)
	{
		_developerLabel					= [[UILabel alloc] init];
		
		UIColor *signatureColour		= [[UIColor alloc] initWithRed:175.0f / 255.0f green:124.0f / 255.0f blue:208.0f / 255.0f alpha:1.0f];
		NSAttributedString *developer	= [[NSAttributedString alloc] initWithString:@"james valaitis"
																		attributes:@{	NSForegroundColorAttributeName	: signatureColour,
																						NSTextEffectAttributeName		: NSTextEffectLetterpressStyle,
																						NSFontAttributeName				: [UIFont fontWithName:@"Futura-Medium"
																																 size:14.0f]}];
		_developerLabel.attributedText	= developer;
		_developerLabel.opaque			= YES;
		_developerLabel.userInteractionEnabled	= YES;
		[_developerLabel sizeToFit];
		
		[_developerLabel addGestureRecognizer:self.urlGestureRecogniser];
		
		_developerLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_developerLabel];
	}
	
	return _developerLabel;
}

/**
 *	A tap gesture recogniser to be added to views that open URLs when tapped on.
 *
 *	@return	A UITapGestureRecogniser intended to open a url when triggered.
 */
- (UITapGestureRecognizer *)urlGestureRecogniser
{
	_urlGestureRecogniser			= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL:)];
	_urlGestureRecogniser.numberOfTapsRequired	= 1;
	
	return _urlGestureRecogniser;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"appLogo"			: self.appLogo,
				@"appName"			: self.appName,
				@"attributionText"	: self.attributionText,
				@"companyLabel"		: self.companyLabel,
				@"developerLabel"	: self.developerLabel,
				@"yummlyButton"		: self.yummlyButton		};
}

/**
 *	This button is intended to let the user view the presented Yummly data on their website when tapped on.
 *
 *	@return	An initialised button with an added target to open attribution URL.
 */
- (UIButton *)yummlyButton
{
	if (!_yummlyButton)
	{
		_yummlyButton					= [[UIButton alloc] init];
		[_yummlyButton addTarget:self action:@selector(openAttributionURL) forControlEvents:UIControlEventTouchUpInside];
		_yummlyButton.imageView.contentMode	= UIViewContentModeCenter;
		
		_yummlyButton.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_yummlyButton];
	}
	
	return _yummlyButton;
}

/**
 *	Image view with Yummly logo.
 *
 *	@return	An initialised image view containing the small Yummly logo.
 */
- (UIImage *)yummlyLogo
{
	if (!_yummlyLogo)
	{
		NSData *yummlyImageData			= [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:self.attributionDictionary[kYummlyAttributionLogoKey]]];
		_yummlyLogo						= [[UIImage alloc] initWithData:yummlyImageData];
	}
	
	return _yummlyLogo;
}

#pragma mark - Property Accessor Methods - Setters

/**
 *
 *
 *	@param
 */
- (void)setAttributionDictionary:(NSDictionary *)attributionDictionary
{
	if (!_attributionDictionary && attributionDictionary)
	{
		_attributionDictionary			= attributionDictionary;
		[self loadSubviews];
	}
	else
		_attributionDictionary			= attributionDictionary;
}

/**
 *	Called when our right controller delegate is set.
 *
 *	@param	rightDelegate				An NSObject adhering to our LeftControllerDelegate protocol.
 */
- (void)setRightDelegate:(id<RightControllerDelegate>)rightDelegate
{
	_rightDelegate						= rightDelegate;
	
	if ([_rightDelegate respondsToSelector:@selector(blockToCallWithAttributionDictionary:)])
		[_rightDelegate blockToCallWithAttributionDictionary:^(NSDictionary *attributionDictionary)
		{
			self.attributionDictionary	= attributionDictionary;
		}];
}

@end