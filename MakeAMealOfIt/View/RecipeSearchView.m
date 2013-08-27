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

/**	A button allowing the user to execute the search.	*/
@property (nonatomic, strong)	UIButton		*searchButton;
/**	A boolean value indicating whether a search is currently loading.	*/
@property (nonatomic, assign)	BOOL			searchLoading;
/**	A text field allowing the user to specify a search phrase.	*/
@property (nonatomic, strong)	UITextField		*searchPhraseField;
/**	A dictionary to be used for auto layout.	*/
@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Recipe Search View Implementation

@implementation RecipeSearchView

#pragma mark - Action & Selector Methods

/**
 *	The user wants to execute the search.
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
	
	if ([self.delegate respondsToSelector:@selector(searchWillExecute)])
		[self.delegate searchWillExecute];
	
	//	executes the search request
	[appDelegate.yummlyRequest executeSearchRecipesCallWithCompletionHandler:^(BOOL success, NSDictionary *results)
	 {
		 [self.delegate performSelectorOnMainThread:@selector(searchExecutedForResults:) withObject:results waitUntilDone:NO];
		 self.searchLoading				= NO;
	 }];
}

/**
 *	The user has updated their choice of text size.
 */
- (void)textSizeChanged
{
	[ThemeManager customiseTextField:self.searchPhraseField withTheme:nil];
	[self.searchButton removeFromSuperview];
	self.searchButton					= nil;
	[self setNeedsUpdateConstraints];
}

/**
 *	Called when the global Yummly Request object has been reset.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
	self.searchPhraseField.text			= @"";
}

#pragma mark - Auto Layout Methods

/**
 *	Returns whether the receiver depends on the constraint-based layout system.
 *
 *	@return	YES if the view must be in a window using constraint-based layout to function properly, NO otherwise.
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	Update constraints for the view.
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self removeConstraints:self.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the search field
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=20)-[searchField]-(==20)-[searchButton]"
																options:NSLayoutFormatAlignAllTrailing
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[searchField(<=300)]"
																options:NSLayoutFormatAlignAllCenterX
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:[searchField(>=200)]"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.searchPhraseField
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yummlyRequestHasBeenReset:) name:kNotificationYummlyRequestReset object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(textSizeChanged)
													 name:kNotificationTextSizeChanged
												   object:nil];
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	An array of example foods for the placeholder of the search field.
 *
 *	@return	An array of NSStrings.
 */
- (NSArray *)foods
{
	return @[@"Barbeque", @"Brownie", @"Cookie", @"Cottage Pie", @"Doughnut", @"Flapjack", @"Lasagne", @"Pizza", @"Risotto", @"Soup"];
}

/**
 *	This button when tapped will execute the search.
 *
 *	@return	This button when tapped will execute the search.
 */
- (UIButton *)searchButton
{
	if (!_searchButton)
	{
		_searchButton					= [[UIButton alloc] init];
		_searchButton.contentEdgeInsets	= UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f);
		_searchButton.opaque			= YES;
		[_searchButton setTitle:@"Search" forState:UIControlStateNormal];
		[_searchButton setTitleColor:kYummlyColourMain forState:UIControlStateNormal];
		[_searchButton setTitleColor:kYummlyColourShadow forState:UIControlStateHighlighted];
		[_searchButton addTarget:self action:@selector(searchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[_searchButton sizeToFit];
		
		_searchButton.translatesAutoresizingMaskIntoConstraints			= NO;
		[self addSubview:_searchButton];
	}
	
	return _searchButton;
}

/**
 *	The field for search phrases.
 *
 *	@return	A fully initialised text field designed to accept search text.
 */
- (UITextField *)searchPhraseField
{
	if (!_searchPhraseField)
	{
		_searchPhraseField				= [[UITextField alloc] init];
		_searchPhraseField.borderStyle	= UITextBorderStyleNone;
		_searchPhraseField.clearButtonMode	= UITextFieldViewModeWhileEditing;
		_searchPhraseField.delegate		= self;
		_searchPhraseField.opaque		= YES;
		_searchPhraseField.placeholder	= [[NSString alloc] initWithFormat:@"%@...", self.foods[arc4random() % self.foods.count]];
		_searchPhraseField.returnKeyType= UIReturnKeySearch;
		[_searchPhraseField setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[_searchPhraseField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		
		_searchPhraseField.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_searchPhraseField];
	}
	
	return _searchPhraseField;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"searchField"		: self.searchPhraseField,
			 @"searchButton"	: self.searchButton};
}

#pragma mark - UIResponder Methods

/**
 *	Notifies the receiver that it has been asked to relinquish its status as first responder in its window.
 *
 *	@return	YES - resigning first responder status or NO, refusing to relinquish first responder status.
 */
- (BOOL)resignFirstResponder
{
	[self.searchPhraseField resignFirstResponder];
	return [super resignFirstResponder];
}

/**
 *	Tells the receiver when one or more fingers touch down in a view or window.
 *
 *	@param	touches						A set of UITouch instances that represent the touches for the starting phase of the event represented by event.
 *	@param	event						An object representing the event to which the touches belong.
 */
- (void)touchesBegan:(NSSet *)touches
		   withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	[self.searchPhraseField resignFirstResponder];
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
 *	Asks the delegate if editing should begin in the specified text field.
 *
 *	@param	textField					The text field for which editing is about to begin.
 *
 *	@return	YES if an editing session should be initiated; otherwise, NO to disallow editing.
 */
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return [self.delegate recipeSearchViewCanBecomeFirstResponder:self];
}

/**
 *	Asks the delegate if the text field should process the pressing of the return button.
 *
 *	@param	textField					The text field whose return button was pressed.
 *
 *	@return	YES if the text field should implement its default behavior for the return button; otherwise, NO.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	[self searchButtonTapped];
	
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