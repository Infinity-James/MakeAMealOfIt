//
//  IntroductionHeaderView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 15/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Introduction Header View Public Interface

@interface IntroductionHeaderView : UIView {}

#pragma mark - Private Properties

/**	The image to be displayed in this header view.	*/
@property (nonatomic, strong)	UIImage		*headerImage;
/**	The text to be displayed in this header view.	*/
@property (nonatomic, strong)	NSString	*headerText;

@end