//
//  StarRatingView.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 31/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Star Rating View Public Interface

@interface StarRatingView : UIView {}

#pragma mark - Public Properties

@property (nonatomic, assign)	CGFloat	rating;

#pragma mark - Public Methods

- (instancetype)initWithRating:(CGFloat)rating;

@end