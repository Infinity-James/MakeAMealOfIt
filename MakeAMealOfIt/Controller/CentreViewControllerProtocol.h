//
//  CentreViewControllerProtocol.h
//  Slide-Out Navigation
//
//  Created by James Valaitis on 13/05/2013.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#pragma mark - Constants & Static Variables

/**	Indicates a button is currently in use.	*/
static NSUInteger const kButtonInUse		= 1;
/**	Indicates a button is currently not in use.	*/
static NSUInteger const kButtonNotInUse		= 0;

#pragma mark - Type Definitions

typedef NS_ENUM (NSUInteger, MoveDestination)
{
	/**	Indicates the centre view is sliding to the left.	*/
	MovingViewLeft,
	/**	Indicates the centre view is sliding to the right.	*/
	MovingViewRight,
	/**	Indicates the centre view is sliding to the centre.	*/
	MovingViewOriginalPosition
};



/**	A block to be used when the centre view wants to slide in a direction.	*/
typedef void(^MovingView)(MoveDestination movingDestination);
typedef void(^SetMenuState)(SideControllerState desiredMenuState);

#pragma mark - Centre View Controller Protocol

@protocol CentreViewControllerProtocol <NSObject>

@required

#pragma mark - Required Properties

/**	The button that will indicate a view has been pushed on top of another view	*/
@property (nonatomic, strong)	UIBarButtonItem		*backButton;
/**	The current state of the main view controller.	*/
@property (nonatomic, assign)	SideControllerState	menuState;
/**	A block to be used when the centre view wants to slide in a direction.	*/
@property (nonatomic, copy)		MovingView			movingViewBlock;
@property (nonatomic, copy)		SetMenuState		setMenuState;

#pragma mark - Requires Methods

/**
 *	A convenient way to get the left button's tag.
 *
 *	@return	kButtonInUse if the button is in use and kButtonNotInUse if it is not.
 */
- (NSUInteger)leftButtonTag;
/**
 *	A convenient way to get the right button's tag.
 *
 *	@return	kButtonInUse if the button is in use and kButtonNotInUse if it is not.
 */
- (NSUInteger)rightButtonTag;
/**
 *	Sets the tag of the button to the left of the toolbar.
 *
 *	@param	tag							Should be kButtonInUse for when button has been tapped, and kButtonNotInUse otherwise.
 */
- (void)setLeftButtonTag:(NSUInteger)tag;
/**
 *	Sets the tag of the button to the right of the toolbar.
 *
 *	@param	tag							Should be kButtonInUse for when button has been tapped, and kButtonNotInUse otherwise.
 */
- (void)setRightButtonTag:(NSUInteger)tag;

@end