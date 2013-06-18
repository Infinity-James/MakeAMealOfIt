//
//  LoadMoreResultsCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 18/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Result Management Cell Public Interface

@interface ResultManagementCell : UICollectionViewCell {}

/**
 *	Publicly allows the setting of the instruction label text.
 *
 *	@param	text						The text for the instruction label to present.
 */
- (void)setInstructionLabelText:(NSString *)text;
/**
 *	Starts the activity indicator of this view spinning.
 */
- (void)startLoading;
/**
 *	Stop the activity indicator view spinning.
 */
- (void)stopLoading;

@end