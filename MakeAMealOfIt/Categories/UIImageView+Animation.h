//
//  UIImageView+Animation.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@import QuartzCore;

@interface UIImageView (Animation)

- (void)addShadow;
- (void)setImage:(UIImage *)image animated:(BOOL)animate;

@end