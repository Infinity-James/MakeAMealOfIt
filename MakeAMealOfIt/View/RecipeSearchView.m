//
//  RecipeSearchView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 17/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "RecipeSearchView.h"

#pragma mark - Recipe Search View Private Class Extension

@interface RecipeSearchView () <UITextFieldDelegate> {}

@property (nonatomic, strong)	UIButton		*searchButton;
@property (nonatomic, assign)	BOOL			searchLoading;
@property (nonatomic, strong)	UITextField		*searchPhraseField;
@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Recipe Search View Implementation

@implementation RecipeSearchView

#pragma mark - Action & Selector Methods

/**
 *	the user wants to execute the search
 */
- (void)searchButtonTapped
{
	//	if the keyboard is still up we take it down
	[self.searchPhraseField resignFirstResponder];
	
	//	set the yummly request's 
	appDelegate.yummlyRequest.searchPhrase	= self.searchPhraseField.text;
	
	if (!self.searchLoading)
		self.searchLoading				= YES;
	else
		return;
	
	//	executes the search request
	[appDelegate.yummlyRequest executeSearchRecipesCallWithCompletionHandler:^(BOOL success, NSDictionary *results)
	{
		[self.delegate performSelectorOnMainThread:@selector(searchExecutedForResults:) withObject:results waitUntilDone:NO];
		self.searchLoading				= NO;
	}];
}

#pragma mark - Auto Layout Methods

/**
 *	returns whether the receiver depends on the constraint-based layout system
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	update constraints for the view
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self removeConstraints:self.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the search field
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=20)-[searchField]-(==20)-[searchButton]" options:NSLayoutFormatAlignAllTrailing metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=10)-[searchField(<=300)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:self.viewsDictionary];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:[searchField(>=200)]" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
	constraint							= [NSLayoutConstraint constraintWithItem:self.searchPhraseField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
	[self addConstraint:constraint];
}

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (instancetype)init
{
	if (self = [super init])
	{
		self.backgroundColor			= [UIColor whiteColor];
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	an array of example foods for the placeholder of the search field
 */
- (NSArray *)foods
{
	return @[@"Barbeque", @"Brownie", @"Cookie", @"Cottage Pie", @"Doughnut", @"Flapjack", @"Lasagne", @"Pizza", @"Risotto", @"Soup"];
}

/**
 *	this button when tapped will execute the search
 */
- (UIButton *)searchButton
{
	if (!_searchButton)
	{
		_searchButton					= [[UIButton alloc] init];
		[_searchButton setTitle:@"Search" forState:UIControlStateNormal];
		_searchButton.contentEdgeInsets	= UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f);
		[ThemeManager customiseButton:_searchButton withTheme:nil];
		[_searchButton addTarget:self action:@selector(searchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[_searchButton sizeToFit];
		
		_searchButton.translatesAutoresizingMaskIntoConstraints			= NO;
		[self addSubview:_searchButton];
	}
	
	return _searchButton;
}

/**
 *	the field for search phrases
 */
- (UITextField *)searchPhraseField
{
	if (!_searchPhraseField)
	{
		_searchPhraseField				= [[UITextField alloc] init];
		_searchPhraseField.borderStyle	= UITextBorderStyleNone;
		_searchPhraseField.delegate		= self;
		_searchPhraseField.placeholder	= [[NSString alloc] initWithFormat:@"%@...", self.foods[arc4random() % self.foods.count]];
		[_searchPhraseField setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[_searchPhraseField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		
		_searchPhraseField.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_searchPhraseField];
	}
	
	return _searchPhraseField;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"searchField"		: self.searchPhraseField,
				@"searchButton"		: self.searchButton};
}

/**
 *	tells the receiver when one or more fingers touch down in a view or window
 *
 *	@param	touches						set of uitouch instances that represent touches for the starting phase of the event
 *	@param	event						object representing the event to which the touches belong
 */
- (void)touchesBegan:(NSSet *)touches
		   withEvent:(UIEvent *)event
{
	[self.searchPhraseField resignFirstResponder];
}

#pragma mark - UIResponder Methods

/**
 *	notifies the receiver that it has been asked to relinquish its status as first responder in its window
 */
- (BOOL)resignFirstResponder
{
	[self.searchPhraseField resignFirstResponder];
	return [super resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods

/**
 *	tells delegate that editing began for the specified text field
 *
 *	@param textField					text field for which an editing session began
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	
}

/**
 *	tells delegate that editing stopped for the specified text field
 *
 *	@param	textField					text field for which editing ended
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	appDelegate.yummlyRequest.searchPhrase	= textField.text;
}

/**
 *	asks delegate if editing should begin in the specified text field
 *
 *	@param	textField					text field for which editing is about to begin
 */
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

/**
 *	asks delegate if the text field should process the pressing of the return button
 *
 *	@param	textField					text field whose return button was pressed
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}


#pragma mark - UIView Methods

/**
 *	draws the receiver’s image within the passed-in rectangle
 *
 *	@param	rect						portion of the view’s bounds that needs to be updated
 *
- (void)drawRect:(CGRect)rect
{
	//	get the context
	CGContextRef context				= UIGraphicsGetCurrentContext();
	
	//	----	fiil the rect with a background colour first of all	----
	
	//	set fill colour and then fill the rect
	UIColor *backgroundColour			= [UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1.0f];
	CGContextSetFillColorWithColor(context, backgroundColour.CGColor);
	CGContextFillRect(context, self.bounds);
}*/

#pragma mark - View-Related Observation Methods

/**
 *	tells the view that its superview changed
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	[self setNeedsUpdateConstraints];
}

@end