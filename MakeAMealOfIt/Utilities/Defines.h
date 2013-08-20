//
//  Defines.h
//  CoolTable
//
//  Created by James Valaitis on 26/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

//	customisation defines
#define	FULLSCREENCENTRE

//	button constants
#define	kButtonBevelMargin				3.0f
#define	kButtonHighlightMargin			2.0f
#define kButtonHighlightedStartColour	[UIColor colorWithWhite:1.0f alpha:0.4f]
#define kButtonHighlightedStopColour	[UIColor colorWithWhite:1.0f alpha:0.1f]
#define	kButtonMargin					5.0f
#define kButtonCornerRadius				6.0f

//	convenience
#define appDelegate						((AppDelegate *)[UIApplication sharedApplication].delegate)
#define isFourInchDevice				([UIScreen mainScreen].bounds.size.width > 480 || [UIScreen mainScreen].bounds.size.height > 480)

//	general view constants
static CGFloat const kPanelWidth		= 50.00f;
#define kShadowBlur						3.0f
#define kShadowColour					[UIColor colorWithWhite:0.2f alpha:0.5f]
#define kShadowOffset					CGSizeMake(0.0f, 2.0f)

//	notification names
static NSString *const kNotificationInternetConnectionLost	= @"NotificationGuysNoMoreInternet";
static NSString *const kNotificationInternetReconnected		= @"NotificationGuysWeHaveInternet";
static NSString *const kNotificationThemeChanged			= @"NotificationThemeChanged";
static NSString *const kNotificationYummlyRequestChanged	= @"NotificationYummlyRequestChanged";
static NSString *const kNotificationYummlyRequestEmpty		= @"NotificationYummlyRequestEmpty";
static NSString *const kNotificationYummlyRequestReset		= @"NotificationYummlyRequestReset";
static NSString *const kNotificationTextSizeChanged			= @"NotificationTextSizeChanged";

//	yummly theme constants
#define kDarkGreyColour					[UIColor colorWithRed:030.0f / 255.0f green:030.0f / 255.0f blue:030.0f / 255.0f alpha:1.000f]
#define kDarkGreyColourWithAlpha(x)		[UIColor colorWithRed:030.0f / 255.0f green:030.0f / 255.0f blue:030.0f / 255.0f alpha:x]
#define kLightGreyColour				[[UIColor alloc] initWithRed:165.0f / 255.0f green:165.0f / 255.0f blue:165.0f / 255.0f alpha:1.0f]
#define kLightGreyColourWithAlpha(x)	[[UIColor alloc] initWithRed:165.0f / 255.0f green:165.0f / 255.0f blue:165.0f / 255.0f alpha:x]
#define	kYummlyColourMain				[UIColor colorWithRed:218.0f / 255.0f green:074.0f / 255.0f blue:011.0f / 255.0f alpha:1.000f]
#define	kYummlyColourShadow				[UIColor colorWithRed:130.0f / 255.0f green:034.0f / 255.0f blue:006.0f / 255.0f alpha:1.000f]
#define	kYummlyColourMainWithAlpha(x)	[UIColor colorWithRed:218.0f / 255.0f green:074.0f / 255.0f blue:011.0f / 255.0f alpha:x]
#define	kYummlyColourShadowWithAlpha(x)	[UIColor colorWithRed:130.0f / 255.0f green:034.0f / 255.0f blue:006.0f / 255.0f alpha:x]
#define kYummlyFontWithSize(x)			[UIFont fontWithName:@"AvenirNext-Regular" size:x]
#define kYummlyBolderFontWithSize(x)	[UIFont fontWithName:@"AvenirNext-Medium" size:x]
#define FontSizeForTextStyle(textStyle) [[UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle].fontAttributes[UIFontDescriptorSizeAttribute] floatValue]

#endif	//	Defines_h