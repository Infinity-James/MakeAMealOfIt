//
//  YummlyAttributionViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAttributionViewController.h"
#import "YummlyAPI.h"

#pragma mark - Yummly Attribution VC Private Class Extension

@interface YummlyAttributionViewController () {}

#pragma mark - Private Properties

/**	A dictionary with stuff to include in the attribution.	*/
@property (nonatomic, strong)	NSDictionary	*attributionDictionary;
/**	This button is used to actually attribute Yummly and allow the user to navigate to the Yummly website.	*/
@property (nonatomic, strong)	UIButton		*attributionText;
/**	This URL opens the Yummly website with a specific search or recipe.	*/
@property (nonatomic, strong)	NSURL			*attributionURL;
/**	The label that for my company.	*/
@property (nonatomic, strong)	UILabel			*companyLabel;
/**	The label I will use to show that I made it.	*/
@property (nonatomic, strong)	UILabel			*developerLabel;
/**	An image view to use with the Yummly logo	*/
@property (nonatomic, strong)	UIImageView		*yummlyLogo;

@end

#pragma mark - Yummly Attribution VC Implementation

@implementation YummlyAttributionViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Opens a web view with the attribution URL.
 */
- (void)openAttributionURL
{
	NSLog(@"Attribution URL: %@", self.attributionURL);
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
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[developerLabel]"
																options:kNilOptions
																metrics:Nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	constraint							= [NSLayoutConstraint constraintWithItem:self.developerLabel
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self.view
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self.view addConstraint:constraint];
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

#pragma mark - Setter & Getter Methods

/**
 *	This dictionary holds all of the details to attribute Yummly.
 *
 *	@return	A dictionary with a logo URL, attribution text, and URL to the Yummly website in it.
 */
- (NSDictionary *)attributionDictionary
{
	//	use lazy instantiation to make sure it is never a nil object
	if (!_attributionDictionary)
		_attributionDictionary			= @{};
	
	return _attributionDictionary;
}

/**
 *	Acts as a label to attribute Yummly and also allow the user to navigate to the Yummly website.
 *
 *	@return	A long button that when pressed will navigate to the Yummly website. 
 */
- (UIButton *)attributionText
{
	//	lazy instantiation of the button
	if (!_attributionText)
	{
		_attributionText						= [[UIButton alloc] init];
		_attributionText.backgroundColor		= [UIColor clearColor];
		_attributionText.titleLabel.text		= self.attributionDictionary[kYummlyAttributionTextKey];
		_attributionText.titleLabel.textColor	= kYummlyColourMain;
		[_attributionText addTarget:self action:@selector(openAttributionURL) forControlEvents:UIControlEventTouchUpInside];
		
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
		NSAttributedString *developer	= [[NSAttributedString alloc] initWithString:@"James Valaitis"
																		attributes:@{	NSForegroundColorAttributeName	:	kYummlyColourMain,
																						NSTextEffectAttributeName		: NSTextEffectLetterpressStyle,
																						NSFontAttributeName				: kYummlyFontWithSize(18.0f)}];
		_developerLabel.attributedText	= developer;
	}
	
	return _developerLabel;
}

/**
 *
 *
 *	@return
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"attributionText"	: self.attributionText,
				@"companyLabel"		: self.companyLabel,
				@"developerLabel"	: self.developerLabel,
				@"yummlyLogo"		: self.yummlyLogo		};
}

@end