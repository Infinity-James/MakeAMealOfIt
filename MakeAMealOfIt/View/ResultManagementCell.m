//
//  LoadMoreResultsCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 18/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ResultManagementCell.h"

#pragma mark - Result Management Cell Private Class Extension

@interface ResultManagementCell () {}

@property (nonatomic, strong)	UIActivityIndicatorView		*activityIndicatorView;
@property (nonatomic, strong)	UILabel						*instructionLabel;
@property (nonatomic, strong)	NSDictionary				*viewsDictionary;

@end

#pragma mark - Result Management Cell Cell Implementation

@implementation ResultManagementCell {}

#pragma mark - Autolayout Methods

/**
 *	Returns whether the receiver depends on the constraint-based layout system.
 *
 *	@return YES if the view must be in a window using constraint-based layout to function properly, NO otherwise.
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
	
	//	remove all constraints
	[self removeConstraints:self.contentView.constraints];
	
	//	set up variables to be used when laying out views
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	centre the activity indicator view
	constraint							= [NSLayoutConstraint constraintWithItem:self.activityIndicatorView
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self.contentView
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self.contentView addConstraint:constraint];
	constraint							= [NSLayoutConstraint constraintWithItem:self.activityIndicatorView
													attribute:NSLayoutAttributeCenterY
													relatedBy:NSLayoutRelationEqual
													   toItem:self.contentView
													attribute:NSLayoutAttributeCenterY
												   multiplier:1.0f
													 constant:0.0f];
	[self.contentView addConstraint:constraint];
	
	//	add the instruction label nearer the bottom of the cell and centre along x axis
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[instructionLabel]-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[instructionLabel]-(>=20)-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	constraint							= [NSLayoutConstraint constraintWithItem:self.instructionLabel
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self.contentView
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self.contentView addConstraint:constraint];
}

#pragma mark - Loading More Results

/**
 *	Starts the activity indicator of this view spinning.
 */
- (void)startLoading
{
	[self.activityIndicatorView startAnimating];
}

/**
 *	Stop the activity indicator view spinning.
 */
- (void)stopLoading
{
	[self.activityIndicatorView stopAnimating];
}

#pragma mark - Setter & Getter Methods

/**
 *	The view that shows the user that something is loading.
 *
 *	@return	The activity indicator representing loading.
 */
- (UIActivityIndicatorView *)activityIndicatorView
{
	//	lazy construction of this activity indicator view
	if (!_activityIndicatorView)
	{
		_activityIndicatorView			= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicatorView.color	= kYummlyColourMain;
		
		_activityIndicatorView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_activityIndicatorView];
	}
	
	return _activityIndicatorView;
}

/**
 *	The label telling the user the function of this cell.
 *
 *	@return	A label explaining more results are loading.
 */
- (UILabel *)instructionLabel
{
	//	lazy construction of the load more label with complete customisation and text
	if (!_instructionLabel)
	{
		_instructionLabel					= [[UILabel alloc] init];
		_instructionLabel.adjustsFontSizeToFitWidth	= NO;
		_instructionLabel.backgroundColor	= [UIColor clearColor];
		_instructionLabel.font				= [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f];
		_instructionLabel.lineBreakMode		= NSLineBreakByWordWrapping;
		_instructionLabel.numberOfLines		= 0;
		_instructionLabel.textAlignment		= NSTextAlignmentCenter;
		_instructionLabel.textColor			= kYummlyColourMain;
		
		_instructionLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_instructionLabel];
	}
	
	return _instructionLabel;
}

/**
 *	Publicly allows the setting of the instruction label text.
 *
 *	@param	text						The text for the instruction label to present.
 */
- (void)setInstructionLabelText:(NSString *)text
{
	self.instructionLabel.text			= text;
}

/**
 *	This dictionary is used when laying out constraints.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"activityIndicator"	: self.activityIndicatorView,
				@"instructionLabel"		: self.instructionLabel			};
}

@end