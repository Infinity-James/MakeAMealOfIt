//
//  IngredientTableViewCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 02/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IngredientTableViewCell.h"
#import "YummlyMetadata.h"

#pragma mark - Constants & Static Variables

static CGFloat const kCuesMargin				= 10.00f;
static CGFloat const kCuesWidth					= 50.00f;
static NSTimeInterval const kSelectionDuration	= 00.50f;

#define kExcludeColour					[[UIColor alloc] initWithRed:185.0f / 255.0f green:046.0f / 255.0f blue:000.0f alpha:1.0f]
#define kIncludeColour					[[UIColor alloc] initWithRed:046.0f / 255.0f green:136.0f / 255.0f blue:128.0f / 255.0f alpha:1.0f]

#pragma mark - Ingredient Table View Cell Private Class Extension

@interface IngredientTableViewCell () {}

#pragma mark - Private Properties

/**	A label used to contextually cue the user that their drag will exclude this item.	*/
@property (nonatomic, strong)	UILabel	*excludeLabel;
/**	This layer is used to show that this cell has been excluded.	*/
@property (nonatomic, strong)	CALayer	*excludedLayer;
/**	Whether or not once the user stops dragging the cell itshould be excluded.	*/
@property (nonatomic, assign)	BOOL	excludeOnDragRelease;
/**	A label used to contextually cue the user that their drag will include this item.	*/
@property (nonatomic, strong)	UILabel	*includeLabel;
/**	This layer is used to show that this cell has been included.	*/
@property (nonatomic, strong)	CALayer	*includedLayer;
/**	Whether or not once the user stops dragging the cell itshould be included.	*/
@property (nonatomic, assign)	BOOL	includeOnDragRelease;
/**	The original centre point of the cell before it was moved.	*/
@property (nonatomic, assign)	CGPoint	originalCentre;
/**	A label used to contextually cue the user that their drag will stop including this item.	*/
@property (nonatomic, strong)	UILabel	*removeLabelLeft;
/**	A label used to contextually cue the user that their drag will stop excluding this item.	*/
@property (nonatomic, strong)	UILabel	*removeLabelRight;

@end

#pragma mark - Ingredient Table View Cell Implementation

@implementation IngredientTableViewCell {}

#pragma mark - Action & Selector Methods

/**
 *	Handles a pan gesture recogniser.
 *
 *	@param	panGestureRecogniser		The recogniser sending this message.
 */
- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecogniser
{
	//	handle the gesture depending on what state it is in
	switch (panGestureRecogniser.state)
	{
		case UIGestureRecognizerStateBegan:		[self panGestureBegan:panGestureRecogniser];		break;
		case UIGestureRecognizerStateChanged:	[self panGestureChanged:panGestureRecogniser];		break;
		case UIGestureRecognizerStateEnded:		[self panGestureEnded:panGestureRecogniser];		break;
		default:																					break;
	}
}

/**
 *	Handles a tap gesture recogniser.
 *
 *	@param	tapGestureRecogniser		The recogniser sending this message.
 */
- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecogniser
{
	//	create the frames for the various positions of the cell throughout the animation
	CGRect originalFrame				= self.frame;
	CGRect leftFrame					= originalFrame;
	CGRect rightFrame					= originalFrame;
	
	leftFrame.origin.x					+= 100.0f;
	rightFrame.origin.x					-= 100.0f;
	
	//	start the animation by showing the left cue of the cell
	[UIView animateWithDuration:0.3f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut
					 animations:
	^{
		self.frame						= leftFrame;
	}
					 completion:^(BOOL finished)
	{
		//	return the cell to the original position
		[UIView animateWithDuration:0.3f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseIn
						 animations:
		^{
			 self.frame					= originalFrame;
		}
						 completion:^(BOOL finished)
		{
			//	now show the right cue of the cell
			[UIView animateWithDuration:0.3f
								  delay:0.0f
								options:UIViewAnimationOptionCurveEaseOut
							 animations:
			^{
				self.frame				= rightFrame;
			}
							 completion:^(BOOL finished)
			{
				//	return the cell to the original position
				[UIView animateWithDuration:0.3f
									  delay:0.0f
									options:UIViewAnimationOptionCurveEaseIn
								 animations:
				^{
					self.frame			= originalFrame;
				}
								 completion:NULL];
			}];
		 }];
	}];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Style this cell to make it look like a default cell.
 */
- (void)customiseTableViewCellDefault
{
	self.backgroundColor				= [UIColor whiteColor];
	[ThemeManager customiseTableViewCell:self withTheme:nil];
}

/**
 *	Style this cell to show it has been excluded.
 */
- (void)customiseTableViewCellExcluded
{
	self.backgroundColor				= kExcludeColour;
	self.textLabel.textColor			= [UIColor whiteColor];
}

/**
 *	Style this cell to show that it has been included.
 */
- (void)customiseTableViewCellIncluded
{
	self.backgroundColor				= kIncludeColour;
	self.textLabel.textColor			= [UIColor whiteColor];
}

#pragma mark - Gesture Handling Methods

/**
 *	Called by the UIGestureRecogniser delegate when it's pan gesture recogniser is in state UIGestureRecognizerStateBegan
 *
 *	@param	panGestureRecogniser		The UIPanGestureRecogniser that has begun sending messages.
 */
- (void)panGestureBegan:(UIPanGestureRecognizer *)panGestureRecogniser
{
	//	if the gesture has started we record the current centre location
	self.originalCentre					= self.center;
}

/**
 *	Called by the UIGestureRecogniser delegate when it's pan gesture recogniser is in state UIGestureRecognizerStateChanged
 *
 *	@param	panGestureRecogniser		The UIPanGestureRecogniser that has changed in some way.
 */
- (void)panGestureChanged:(UIPanGestureRecognizer *)panGestureRecogniser
{
	//	translate the centre of this cell along the x axis
	CGPoint translation					= [panGestureRecogniser translationInView:self];
	self.center							= CGPointMake(self.originalCentre.x + translation.x, self.originalCentre.y);
	
	//	determine whether the cell has been dragged enough to initiate an exclude or include
	self.excludeOnDragRelease			= self.frame.origin.x < -self.frame.size.width / 2.5f;
	self.includeOnDragRelease			= self.frame.origin.x > self.frame.size.width / 2.5f;
	
	//	fade the contextual cues appropriately
	CGFloat cueAlpha					= fabsf(self.frame.origin.x) / (self.frame.size.width / 2.0f);
	self.excludeLabel.alpha = self.includeLabel.alpha = self.removeLabelLeft.alpha = self.removeLabelRight.alpha = cueAlpha;
	
	//	indicate whether the item has been pulled far enough to trigger something
	self.excludeLabel.textColor = self.removeLabelRight.textColor	= self.excludeOnDragRelease ? kExcludeColour : [UIColor blackColor];
	self.includeLabel.textColor = self.removeLabelLeft.textColor	= self.includeOnDragRelease ? kIncludeColour : [UIColor blackColor];
}

/**
 *	Called by the UIGestureRecogniser delegate when it's pan gesture recogniser is in state UIGestureRecognizerStateEnded
 *
 *	@param	panGestureRecogniser		The UIPanGestureRecogniser that has finished sending messages.
 */
- (void)panGestureEnded:(UIPanGestureRecognizer *)panGestureRecogniser
{
	//	the frame this cell would have had before being dragged.
	CGRect originalFrame				= CGRectMake(0.0f, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
	
	if (self.excludeOnDragRelease)
		[self setExcluded:!self.excluded updated:YES animated:YES];
	if (self.includeOnDragRelease)
		[self setIncluded:!self.included updated:YES animated:YES];
	
	self.excludeOnDragRelease			= NO;
	self.includeOnDragRelease			= NO;
	
	[UIView animateWithDuration:0.2f
					 animations:
	^{
		self.frame						= originalFrame;
	}];
}

#pragma mark - Initialisation

/**
 *	Adds a pan gesture recogniser to this table view cell.
 */
- (void)addPanGestureRecogniser
{
	UIGestureRecognizer *recogniser		= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	recogniser.delegate					= self;
	[self addGestureRecognizer:recogniser];
	
	recogniser							= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	recogniser.delegate					= self;
	[self addGestureRecognizer:recogniser];
}

/**
 *	A convenience method to get a label set up in such a way to use it as a contextual cue label.
 *
 *	@return A fully initialised label to contextually cue the user.
 */
- (UILabel *)createCueLabel
{
	UILabel *cueLabel					= [[UILabel alloc] initWithFrame:CGRectNull];
	cueLabel.backgroundColor			= [UIColor clearColor];
    cueLabel.font						= [UIFont fontWithName:@"Futura" size:FontSizeForTextStyle(UIFontTextStyleCaption1)];
	cueLabel.textColor					= [UIColor blackColor];
    return cueLabel;
}

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
        [self addPanGestureRecogniser];
		[ThemeManager customiseTableViewCell:self withTheme:nil];
		self.clipsToBounds				= NO;
		for (UIView *subview in self.subviews)
			subview.clipsToBounds		= NO;
		self.layer.borderWidth			= 1.0f;
		self.layer.borderColor			= kDarkGreyColourWithAlpha(0.1f).CGColor;
		self.opaque						= YES;
		self.selectionStyle				= UITableViewCellSelectionStyleNone;
		self.textLabel.backgroundColor	= [UIColor clearColor];
	}
	
    return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	A label used to contextually cue the user that their drag will exclude this item.
 *
 *	@return A fully initialised label to contextually cue the user.
 */
- (UILabel *)excludeLabel
{
	if (!_excludeLabel)
	{
		_excludeLabel					= [self createCueLabel];
		_excludeLabel.hidden			= self.excluded;
		_excludeLabel.text				= @"exclude";
		_excludeLabel.textAlignment		= NSTextAlignmentLeft;
		
		[self addSubview:_excludeLabel];
	}
	
	return _excludeLabel;
}

/**
 *	A layer to show that this cell had been excluded.
 *
 *	@return	A layer customised to tell the user the state of this cell (excluded).
 */
- (CALayer *)excludedLayer
{
	if (!_excludedLayer)
	{
		_excludedLayer					= [[CALayer alloc] init];
		_excludedLayer.backgroundColor	= [[UIColor alloc] initWithRed:185.0f / 255.0f green:46.0f / 255.0f blue:0.0f alpha:1.0f].CGColor;
		_excludedLayer.hidden			= YES;
		
		[self.layer insertSublayer:_excludedLayer atIndex:0];
	}
	
	return _excludedLayer;
}

/**
 *	A label used to contextually cue the user that their drag will include this item.
 *
 *	@return A fully initialised label to contextually cue the user.
 */
- (UILabel *)includeLabel
{
	if (!_includeLabel)
	{
		_includeLabel					= [self createCueLabel];
		_includeLabel.hidden			= self.included;
		_includeLabel.text				= @"include";
		_includeLabel.textAlignment		= NSTextAlignmentRight;
		
		[self addSubview:_includeLabel];
	}
	
	return _includeLabel;
}

/**
 *	A layer to show that this cell had been included.
 *
 *	@return	A layer customised to tell the user the state of this cell (included).
 */
- (CALayer *)includedLayer
{
	if (!_includedLayer)
	{
		_includedLayer					= [[CALayer alloc] init];
		_includedLayer.backgroundColor	= kYummlyColourMain.CGColor;
		_includedLayer.hidden			= YES;
		
		[self.layer insertSublayer:_includedLayer atIndex:0];
	}
	
	return _includedLayer;
}

/**
 *	A label used to contextually cue the user that their drag will stop including this item.
 *
 *	@return A fully initialised label to contextually cue the user.
 */
- (UILabel *)removeLabelLeft
{
	if (!_removeLabelLeft)
	{
		_removeLabelLeft					= [self createCueLabel];
		_removeLabelLeft.hidden				= !self.included;
		_removeLabelLeft.text				= @"\u2717";
		_removeLabelLeft.textAlignment		= NSTextAlignmentRight;
		
		[self addSubview:_removeLabelLeft];
	}
	
	return _removeLabelLeft;
}

/**
 *	A label used to contextually cue the user that their drag will stop including this item.
 *
 *	@return A fully initialised label to contextually cue the user.
 */
- (UILabel *)removeLabelRight
{
	if (!_removeLabelRight)
	{
		_removeLabelRight					= [self createCueLabel];
		_removeLabelRight.hidden			= !self.excluded;
		_removeLabelRight.text				= @"\u2717";
		_removeLabelRight.textAlignment		= NSTextAlignmentLeft;
		
		[self addSubview:_removeLabelRight];
	}
	
	return _removeLabelRight;
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	The basic setter for the excluded property of this cell.
 *
 *	@param	excluded					Whether or not the user wants to exclude this ingredient from the search.
 */
- (void)setExcluded:(BOOL)excluded
{
	[self setExcluded:excluded updated:NO animated:NO];
}

/**
 *	A special setter for the excluded property of this cell.
 *
 *	@param	excluded					Whether or not the user wants to exclude this ingredient from the search.
 *	@param	updateDelegate				Whether or not to inform the delegate that this cell has been updated.
 */
- (void)setExcluded:(BOOL)excluded
			updated:(BOOL)updateDelegate
		   animated:(BOOL)animated
{
	_excluded							= excluded;
	self.excludeLabel.hidden			= _excluded;
	self.removeLabelRight.hidden		= !_excluded;
	
	if (_excluded)
	{
		if (self.included)
			self.included				= NO;
		
		if (animated)
			[UIView animateWithDuration:kSelectionDuration animations:
			^{
				[self customiseTableViewCellExcluded];
			}];
		else
			[self customiseTableViewCellExcluded];
			
	}
	
	else if (!self.included)
	{
		if (animated)
			[UIView animateWithDuration:kSelectionDuration animations:
			^{
				[self customiseTableViewCellDefault];
			}];
		else
			[self customiseTableViewCellDefault];
	}
	
	if (updateDelegate)
		[self.delegate ingredientCellUpdated:self];
}

/**
 *	The basic setter for the included property of this cell.
 *
 *	@param	included					Whether or not the user wants to include this ingredient from the search.
 */
- (void)setIncluded:(BOOL)included
{
	[self setIncluded:included updated:NO animated:NO];
}

/**
 *	A special setter for the included property of this cell.
 *
 *	@param	included					Whether or not the user wants to include this ingredient from the search.
 *	@param	updateDelegate				Whether or not to inform the delegate that this cell has been updated.
 */
- (void)setIncluded:(BOOL)included
			updated:(BOOL)updateDelegate
		   animated:(BOOL)animated
{
	_included							= included;
	self.includeLabel.hidden			= _included;
	self.removeLabelLeft.hidden			= !_included;
	
	if (_included)
	{
		if (self.excluded)
			self.excluded				= NO;
		
		if (animated)
			[UIView animateWithDuration:kSelectionDuration animations:
			 ^{
				 [self customiseTableViewCellIncluded];
			 }];
		else
			[self customiseTableViewCellIncluded];
	}
	
	else if (!self.excluded)
	{
		if (animated)
			[UIView animateWithDuration:kSelectionDuration animations:
			 ^{
				 [self customiseTableViewCellDefault];
			 }];
		else
			[self customiseTableViewCellDefault];
	}
	
	if (updateDelegate)
		[self.delegate ingredientCellUpdated:self];
}

/**
 *	The setter for the ingredient dictionary
 *
 *	@param	ingredientDictionary		The ingredient dictionary that this table view renders.
 */
- (void)setIngredientDictionary:(NSDictionary *)ingredientDictionary
{
	_ingredientDictionary				= ingredientDictionary;
	
	self.textLabel.text					= [_ingredientDictionary[kYummlyMetadataDescriptionKey] capitalizedString];
	
	if (self.excluded)
		self.excluded					= NO;
	if (self.included)
		self.included					= NO;
}

#pragma mark - UIGestureRecognizerDelegate Methods

/**
 *	Asks the view if the gesture recognizer should be allowed to continue tracking touch events.
 *
 *	@param	gestureRecognizer			The gesture recognizer that is attempting to transition out of the UIGestureRecognizerStatePossible state.
 *
 *	@return	YES if the gesture recognizer should continue tracking touch events and use them to trigger a gesture, NO otherwise.
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
	{
		CGPoint translation					= [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.superview];
		
		//	check for horizontal gesture
		if (fabsf(translation.x) >= fabsf(translation.y))
			return YES;
	}
	
	else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
		return YES;
	
	return NO;
}

#pragma mark - UITableViewCell Methods

/**
 *	Prepares a reusable cell for reuse by the table view's delegate.
 */
- (void)prepareForReuse
{
	[super prepareForReuse];
	NSLog(@"Ingredient reused.");
}

#pragma mark - UIView Methods

/**
 *	Lays out subviews.
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//	ensure the the layers are the same size as our main layer
	//self.excludedLayer.frame			= self.bounds;
	//self.includedLayer.frame			= self.bounds;
	
	//	add the labels to the sides of the cell
	self.excludeLabel.frame				= CGRectMake(self.bounds.size.width + kCuesMargin, 0.0f, kCuesWidth, self.bounds.size.height);
	self.includeLabel.frame				= CGRectMake(-(kCuesMargin + kCuesWidth), 0.0f, kCuesWidth, self.bounds.size.height);
	self.removeLabelLeft.frame			= self.includeLabel.frame;
	self.removeLabelRight.frame			= self.excludeLabel.frame;
}

#pragma mark - Utility Methods

/**
 *
 *
 *	@return	A CGFloat for the height of this cell.
 */
+ (CGFloat)desiredHeightForCell
{
	return 30.0f;
}

@end