//
//  Defines.h
//  CoolTable
//
//  Created by James Valaitis on 26/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#ifndef CoolTable_Defines_h
#define CoolTable_Defines_h

//	button constants
#define	kButtonBevelMargin				3.0f
#define	kButtonHighlightMargin			2.0f
#define kButtonHighlightedStartColour	[UIColor colorWithWhite:1.0f alpha:0.4f]
#define kButtonHighlightedStopColour	[UIColor colorWithWhite:1.0f alpha:0.1f]
#define	kButtonMargin					5.0f
#define kButtonCornerRadius				6.0f

//	convenience
#define appDelegate						((AppDelegate *)[UIApplication sharedApplication].delegate)
#define isFiveInchDevice				([UIScreen mainScreen].bounds.size.width > 480 || [UIScreen mainScreen].bounds.size.height > 480)

//	general view constants
static CGFloat const kPanelWidth		= 60.00f;
#define kShadowBlur						3.0f
#define kShadowColour					[UIColor colorWithWhite:0.2f alpha:0.5f]
#define kShadowOffset					CGSizeMake(0.0f, 2.0f)

//	notification names
#define kSubviewTrackingTouch				@"NotificationSubviewTrackingTouch"
#define kThemeChanged						@"NotificationThemeChanged"
static NSString *const kNotificationYummlyRequestChanged		= @"NotificationYummlyRequestChanged";

//	yummly theme constants
#define	kYummlyColourMain				[UIColor colorWithRed:218.0f / 255.0f green:074.0f / 255.0f blue:011.0f / 255.0f alpha:1.000f]
#define	kYummlyColourShadow				[UIColor colorWithRed:130.0f / 255.0f green:034.0f / 255.0f blue:006.0f / 255.0f alpha:1.000f]
#define	kYummlyColourMainWithAlpha(x)	[UIColor colorWithRed:218.0f / 255.0f green:074.0f / 255.0f blue:011.0f / 255.0f alpha:x]
#define	kYummlyColourShadowWithAlpha(x)	[UIColor colorWithRed:130.0f / 255.0f green:034.0f / 255.0f blue:006.0f / 255.0f alpha:x]

#endif