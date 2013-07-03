//
//  IngredientTableViewCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 02/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IngredientTableViewCell.h"
#import "YummlyMetadata.h"

#pragma mark - Ingredient Table View Cell Private Class Extension

@interface IngredientTableViewCell () {}

#pragma mark - Private Properties

@property (nonatomic, assign)	BOOL	excludeOnDragRelease;
@property (nonatomic, assign)	CGPoint	originalCentre;

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
	
	//	determine whether the cell has been dragged enough to initiate an exclude
	self.excludeOnDragRelease			= self.frame.origin.x < -self.frame.size.width / 2;
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
	
	if (!self.excludeOnDragRelease)
		[UIView animateWithDuration:0.2f
						 animations:
		^{
			self.frame					= originalFrame;
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
		self.selectionStyle				= UITableViewCellSelectionStyleNone;
		self.textLabel.backgroundColor	= [UIColor clearColor];
    }
	
    return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	The setter for the ingredient dictionary
 *
 *	@param	ingredientDictionary		The ingredient dictionary that this table view renders.
 */
- (void)setIngredientDictionary:(NSDictionary *)ingredientDictionary
{
	_ingredientDictionary				= ingredientDictionary;
	
	self.textLabel.text					= [_ingredientDictionary[kYummlyMetadataDescriptionKey] capitalizedString];
}

#pragma mark - UIGestureRecognizer Methods

/**
 *	Asks the view if the gesture recognizer should be allowed to continue tracking touch events.
 *
 *	@param	gestureRecognizer			The gesture recognizer that is attempting to transition out of the UIGestureRecognizerStatePossible state.
 *
 *	@return	YES if the gesture recognizer should continue tracking touch events and use them to trigger a gesture, NO otherwise.
 */
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
	CGPoint translation					= [gestureRecognizer translationInView:self.superview];
	
	//	check for horizontal gesture
	if (fabsf(translation.x) > fabsf(translation.y))
		return YES;
	
	return NO;
}

@end