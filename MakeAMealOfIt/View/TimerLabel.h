//
//  TimerLabel.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 22/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Timer Label Public Interface

@interface TimerLabel : UIView {}

#pragma mark - Public Properties

/**	The font of the text.	*/
@property (nonatomic, strong)	UIFont		*font;
/**	The maximum number of lines to use for rendering text.	*/
@property (nonatomic, assign)	NSUInteger	numberOfLines;
/**	The text displayed by the label.	*/
@property (nonatomic, strong)	NSString	*text;
/**	The colour of the text.	*/
@property (nonatomic, strong)	UIColor		*textColour;

@end