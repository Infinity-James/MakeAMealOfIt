//
//  SegmentView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SegmentView.h"

#pragma mark - Segment View Private Class Extension

@interface SegmentView () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UILabel	*segmentLabel;

@end

#pragma mark - Segment View Implementation

@implementation SegmentView {}

#pragma mark - Setter & Getter Methods

/**
 *	Used to display the title of this segment.
 *
 *	@return	The label used to tell the user what this segment represents.
 */
- (UILabel *)segmentLabel
{
	if (!_segmentLabel)
	{
		_segmentLabel					= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f,
																	self.bounds.size.width - 10.0f, self.bounds.size.height - 40.0f)];
		_segmentLabel.alpha				= 0.0f;
		_segmentLabel.backgroundColor	= kDarkGreyColourWithAlpha(0.8f);
		_segmentLabel.font				= kYummlyBolderFontWithSize(FontSizeForTextStyle(UIFontTextStyleCaption2));
		_segmentLabel.lineBreakMode		= NSLineBreakByWordWrapping;
		_segmentLabel.numberOfLines		= 0;
		_segmentLabel.text				= self.segmentTitle;
		_segmentLabel.textAlignment		= NSTextAlignmentCenter;
		_segmentLabel.textColor			= [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
		_segmentLabel.transform			= CGAffineTransformMakeRotation(-self.angleOfSegment / 2.0f);
		
		[_segmentLabel sizeToFit];
		
		[self addSubview:_segmentLabel];
	}
	
	return _segmentLabel;
}

/**
 *	Used to alert the view that it is the selected view.
 *
 *	@param	selected					Whether this segment is selected or not.
 */
- (void)setSelected:(BOOL)selected
{
	_selected							= selected;
	if (selected)
		self.segmentLabel.alpha				= 1.0f;
	else
		self.segmentLabel.alpha				= 0.0f;
}

#pragma mark - UIView Methods

/**
 *	Draws the receiver’s image within the passed-in rectangle.
 *
 *	@param	rect						Portion of the view’s bounds that needs to be updated.
 */
- (void)drawRect:(CGRect)rect
{
	//	get the context
	CGContextRef context				= UIGraphicsGetCurrentContext();
	
	//	----	get the points we need for ease	----
	
	CGPoint originPoint					= CGPointMake(rect.size.width, CGRectGetMidY(rect));
	
	CGFloat halfAngle					= self.angleOfSegment / 2.0f;
	CGFloat magnitude					= rect.size.width / cos(halfAngle);
	CGFloat xComponent					= magnitude * cos(halfAngle);
	CGFloat yComponent					= magnitude * sin(halfAngle);
	
	CGPoint topPoint					= CGPointMake(originPoint.x - xComponent, originPoint.x - yComponent);
	CGPoint bottomPoint					= CGPointMake(originPoint.x - xComponent, originPoint.x + yComponent);
	
	[kYummlyColourMain setStroke];
	CGContextMoveToPoint(context, originPoint.x, originPoint.y);
	CGContextAddLineToPoint(context, topPoint.x, topPoint.y);
	CGContextAddLineToPoint(context, bottomPoint.x, bottomPoint.y);
	CGContextAddLineToPoint(context, originPoint.x, originPoint.y);
	
	CGContextSetLineWidth(context, 10.0f);
	CGContextStrokePath(context);
}

@end