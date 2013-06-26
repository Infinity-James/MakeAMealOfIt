//
//  MetadataCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "MetadataCell.h"

#pragma mark - Metadata Cell Implementation

@implementation MetadataCell

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
	[self.contentView removeConstraints:self.contentView.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[metadataLabel]-[metadataTypeLabel(==40)]-|"
																options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	constraint							= [NSLayoutConstraint constraintWithItem:self.metadataLabel
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.contentView
													attribute:NSLayoutAttributeHeight
												   multiplier:1.0f
													 constant:0.0f];
	[self.contentView addConstraint:constraint];
}

#pragma mark - Initialisation

/**
 *	Initializes a table cell with a style and a reuse identifier and returns it to the caller.
 *
 *	@param	style						A constant indicating a cell style.
 *	@param	reuseIdentifier				A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.
 *
 *	@return	An initialized UITableViewCell object or nil if the object could not be created.
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
			  reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
        
    }
	
    return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	Used to display the metadata.
 *
 *	@return	An initialised and customised label.
 */
- (UILabel *)metadataLabel
{
	if (!_metadataLabel)
	{
		_metadataLabel					= [[UILabel alloc] init];
		_metadataLabel.font				= [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
		_metadataLabel.textAlignment	= NSTextAlignmentLeft;
		_metadataLabel.textColor		= kYummlyColourMain;
		_metadataLabel.shadowColor		= kYummlyColourShadow;
		_metadataLabel.shadowOffset		= CGSizeMake(0.0f, 1.0f);
		
		_metadataLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_metadataLabel];
	}
	
	return _metadataLabel;
}

/**
 *	Used to display the type of the metadata.
 *
 *	@return	An initialised and customised label.
 */
- (UILabel *)metadataTypeLabel
{
	if (!_metadataTypeLabel)
	{
		_metadataTypeLabel				= [[UILabel alloc] init];
		_metadataTypeLabel.font			= [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
		_metadataTypeLabel.textAlignment= NSTextAlignmentLeft;
		_metadataTypeLabel.textColor	= kYummlyColourShadow;
		_metadataTypeLabel.shadowColor	= [[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
		_metadataTypeLabel.shadowOffset	= CGSizeMake(0.0f, 1.0f);
		
		_metadataTypeLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_metadataTypeLabel];
	}
	
	return _metadataTypeLabel;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"metadataLabel"		: self.metadataLabel,
				@"metadataTypeLabel"	: self.metadataTypeLabel	};
}

@end