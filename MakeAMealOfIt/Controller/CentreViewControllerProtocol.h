//
//  CentreViewControllerProtocol.h
//  Slide-Out Navigation
//
//  Created by James Valaitis on 13/05/2013.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#pragma mark - Constants & Static Variables

static NSUInteger const kButtonInUse		= 0;
static NSUInteger const kButtonNotInUse		= 1;

#pragma mark - Type Definitions

typedef NS_ENUM (NSUInteger, MoveDestination)
{
	MovingViewLeft,
	MovingViewRight,
	MovingViewOriginalPosition
};

typedef void(^MovingView)(MoveDestination movingDestination);

#pragma mark - Centre View Controller Protocol

@protocol CentreViewControllerProtocol <NSObject>

@required

#pragma mark - Required Properties

@property (nonatomic, strong)	UIBarButtonItem	*backButton;
@property (nonatomic, copy)		MovingView		movingViewBlock;

#pragma mark - Requires Methods

- (NSUInteger)leftButtonTag;
- (NSUInteger)rightButtonTag;
- (void)setLeftButtonTag:(NSUInteger)tag;
- (void)setRightButtonTag:(NSUInteger)tag;

@end