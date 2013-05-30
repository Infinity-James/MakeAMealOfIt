//
//  RotaryWheel.m
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RotaryWheel.h"
#import "Sector.h"
#import "SegmentView.h"

#pragma mark - Defines

#define kMinimumAlpha					0.6f
#define kMaximumAlpha					1.0f
#define ImageMake(imageName)			[UIImage imageNamed:imageName]

#pragma mark - Rotary Wheel Class Extension

@interface RotaryWheel ()
{
	UIView								*_container;
	NSInteger							_currentSector;
	CGFloat								_deltaAngle;
	CGAffineTransform					_startTransform;
}

#pragma mark - Private Properties


@property (nonatomic, assign)	CGFloat			angleOfSegment;
@property (nonatomic, assign)	CGFloat			radius;
@property (nonatomic, strong)	NSMutableArray	*sectors;

@end

#pragma mark - Rotary Wheel Implementation

@implementation RotaryWheel {}

#pragma mark - Convenience & Helper Methods

/**
 *	build the sectors if there are an even number of them
 */
- (void)buildSectorsEven
{
	//	set the initialise first midpoint of 0
	CGFloat midPoint					= 0.0f;
	
	//	initialise each sector with all properties
	for (NSInteger index = 0; index < self.numberOfSections; index++)
	{
		Sector *sector					= [[Sector alloc] initWithMinimumValue:midPoint - (self.angleOfSegment / 2)
													  middleValue:midPoint
													 maximumValue:midPoint + (self.angleOfSegment / 2)
													  andSectorID:index];
		
		//	if the sector's maximum value will pass -pi next time, we know to recalculate the sector's mid and min values
		if (sector.maxiumValue - self.angleOfSegment < -M_PI)
			midPoint = M_PI, sector.middleValue = midPoint,	 sector.minimumValue = fabsf(sector.maxiumValue);
		
		//	go down to next midpoint
		midPoint						-= self.angleOfSegment;
		
		[self.sectors addObject:sector];
	}
}

/**
 *	build the sectors if there an odd number of them
 */
- (void)buildSectorsOdd
{
	//	set the initialise first midpoint of 0
	CGFloat midPoint					= 0.0f;
	
	//	initialise each sector with all properties
	for (NSInteger index = 0; index < self.numberOfSections; index++)
	{
		Sector *sector					= [[Sector alloc] initWithMinimumValue:midPoint - (self.angleOfSegment / 2)
																   middleValue:midPoint
																  maximumValue:midPoint + (self.angleOfSegment / 2)
																   andSectorID:index];
		
		//	go down to next midpoint
		midPoint						-= self.angleOfSegment;
		
		//	if the sector's minimum value is now less than -pi that's obviously wrong so we negate the midpoint and recalculate
		if (sector.minimumValue < -M_PI)
			midPoint = -midPoint,		midPoint -= self.angleOfSegment;
		
		[self.sectors addObject:sector];
	}
}

/**
 *	returns the sector of a given value
 *
 *	@param	value						value of the sector to return
 */
- (UIImageView *)getSectorByValue:(NSInteger)value
{
	UIImageView *sectorImage;
	
	for (UIImageView *image in _container.subviews)
		if (image.tag == value)
			sectorImage					= image;
	
	return sectorImage;
}

#pragma mark - Initialisation

/**
 *	initialises an instance of this rotary wheel with the amount of sections it should have as well as the delegate
 *
 *	@param	delegate					the delegate wanting to receive notifications from this wheel
 *	@param	sectionsNumber				the number of sections that this wheel should have
 */
- (instancetype)initWithDelegate:(id<RotaryProtocol>)delegate
					withSections:(NSInteger)sectionsNumber
{
	return [self initWithFrame:CGRectZero andDelegate:delegate withSections:sectionsNumber];
}

/**
 *	initializes and returns a newly allocated view object with the specified frame rectangle
 *
 *	@param	frame						frame rectangle for the view, measured in points
 *	@param	delegate					delegate for the rotary protocol
 *	@param	sectionsNumber				number of sections for the rotary wheel control
 */
- (instancetype)initWithFrame:(CGRect)frame
				  andDelegate:(id<RotaryProtocol>)delegate
				 withSections:(NSInteger)sectionsNumber
{
    if (self = [super initWithFrame:frame])
	{
		self.delegate					= delegate;
		self.numberOfSections			= sectionsNumber;
		
		self.sectors					= [NSMutableArray arrayWithCapacity:self.numberOfSections];
    }
	
    return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	returns the angle size of each section in radians
 */
- (CGFloat)angleOfSegment
{
	if (!_angleOfSegment)				_angleOfSegment = (2 * M_PI) / self.numberOfSections;
	
	return _angleOfSegment;
}

/**
 *	returns the desired radius for this wheel
 */
- (CGFloat)radius
{
	if (!_radius)						_radius = (self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width : self.bounds.size.height) * 0.45f;
	
	return _radius;
}

#pragma mark - UIControl Methods

/**
 *	sent to the control when a touch related to the given event enters the control’s bounds
 *
 *	@param	touch						uitouch object that represents a touch on the receiving control during tracking
 *	@param	event						event object encapsulating the information specific to the user event
 */
- (BOOL)beginTrackingWithTouch:(UITouch *)touch
					 withEvent:(UIEvent *)event
{
	[super beginTrackingWithTouch:touch withEvent:event];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSubviewTrackingTouch object:@YES];
	
	CGPoint touchPoint					= [touch locationInView:self];
	
	//	filter out touchs too close to centre of wheel
	CGFloat magnitudeFromCentre			= [self calculateDistanceFromCentre:touchPoint];
	
	if (magnitudeFromCentre < 40)		return NO;
	
	//	calculate distance from centre
	CGFloat deltaX						= touchPoint.x - _container.center.x;
	CGFloat deltaY						= touchPoint.y - _container.center.y;
	
	//	calculate the arctangent of the opposite (y axis) over the adjacent (x axis) to get the angle
	_deltaAngle							= atan2(deltaY, deltaX);
	
	_startTransform						= _container.transform;
	
	//	selection in limbo so set all sector image's to minimum value by changing current one
	[self getSectorByValue:_currentSector].alpha = kMinimumAlpha;
	
	return YES;
}

/**
 *	sent continuously to the control as it tracks a touch related to the given event within the control’s bounds
 *
 *	@param	touch						uitouch object that represents a touch on the receiving control during tracking
 *	@param	event						event object encapsulating the information specific to the user event
 */
- (BOOL)continueTrackingWithTouch:(UITouch *)touch
						withEvent:(UIEvent *)event
{
	[super continueTrackingWithTouch:touch withEvent:event];
	
	CGPoint touchPoint					= [touch locationInView:self];
	
	//	calculate distance from centre
	CGFloat deltaX						= touchPoint.x - _container.center.x;
	CGFloat deltaY						= touchPoint.y - _container.center.y;
	
	//	calculate the arctangent of the opposite (y axis) over the adjacent (x axis) to get the angle
	CGFloat angle						= atan2(deltaY, deltaX);
	
	//	calculate difference between angles
	CGFloat angleDifference				= _deltaAngle - angle;
	
	_container.transform				= CGAffineTransformRotate(_startTransform, -angleDifference);
	
	return YES;
}

/**
 *	sent to the control when the last touch for the given event completely ends, telling it to stop tracking
 *
 *	@param	touch						uitouch object that represents a touch on the receiving control during tracking
 *	@param	event						event object encapsulating the information specific to the user event
 */
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSubviewTrackingTouch object:@NO];
	
	//	get current container rotation and initialise new value
	CGFloat radians						= atan2f(_container.transform.b, _container.transform.a);
	CGFloat newValue					= 0.0f;
	
	//	iterate through each sector and check which one contains the readian value
	for (Sector *sector in self.sectors)
	{
		//	check for anomaly (even number sectors)
		if (sector.minimumValue > 0 && sector.maxiumValue < 0)
		{
			if (sector.maxiumValue > radians || sector.minimumValue < radians)
			{
				//	determine whether quadrant is positive or negative
				if (radians > 0)
					newValue			= radians - M_PI;
				else
					newValue			= radians + M_PI;
				
				_currentSector			= sector.sectorID;
			}
		}
		
		else if (radians > sector.minimumValue && radians < sector.maxiumValue)
			newValue = radians - sector.middleValue, _currentSector = sector.sectorID;
	}

	[self.delegate wheelDidChangeValue:[NSString stringWithFormat:@"Value is %i", _currentSector]];
	
	//	set up animation for final rotation and changing of current sector alpha
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2f];
	
	CGAffineTransform transform			= CGAffineTransformRotate(_container.transform, -newValue);
	_container.transform				= transform;
	[self getSectorByValue:_currentSector].alpha = kMaximumAlpha;
	
	[UIView commitAnimations];
}

#pragma mark - UIView Methods

/**
 *	lays out subviews
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
	if (self.frame.size.width > 0 && !self.drawnWheel)
		[self drawWheel], self.drawnWheel	= YES;
}

#pragma mark - Utility Methods

/**
 *	returns the magnitude from the centre to a point
 *
 *	@param	point						point to calculate magnitude relative to the centre
 */
- (CGFloat)calculateDistanceFromCentre:(CGPoint)point
{
	CGPoint centre						= CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
	CGFloat deltaX						= point.x - centre.x;
	CGFloat deltaY						= point.y - centre.y;
	
	//	return the magnitude of the hypotenuse using pythagoras' theorem
	return sqrtf((deltaX * deltaX) + (deltaY * deltaY));
}

#pragma mark - View Drawing Methods

/**
 *	draws the wheel with all of the segments and stuff
 */
- (void)drawWheel
{
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	//	create container view to put everything else inside
	_container							= [[UIView alloc] initWithFrame:self.bounds];
	
	//	we create a section label for each section requested
	for (NSInteger index = 0; index < self.numberOfSections; index++)
	{
		//	create the sector and set anchor point (pivot) to the middle right of this rectangle		
		UIView *sectorView				= [[SegmentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.radius, 90.0f)];
		sectorView.layer.anchorPoint	= CGPointMake(1.0f, 0.5f);
		
		//	position the label in the centre of the container view and rotate u=it according to it's number and the calculated angle
		sectorView.layer.position		= CGPointMake(_container.bounds.size.width / 2.0f,
													  _container.bounds.size.height / 2.0f);
		sectorView.transform			= CGAffineTransformMakeRotation(self.angleOfSegment * index);
		
		//	lower the alpha of every sector except for the selected one (by default this is 0)
		if (index == 0)
			sectorView.alpha			= kMaximumAlpha;
		else
			sectorView.alpha			= kMinimumAlpha;
		
		UIImageView *sectorIcon			= [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 15.0f, 40.0f, 40.f)];
		NSString *icon					= [NSString stringWithFormat:@"icon%i.png", index];
		sectorIcon.image				= ImageMake(icon);
		
		[sectorView addSubview:sectorIcon];
		
		[_container addSubview:sectorView];
	}
	
	_currentSector						= 0;
	
	_container.userInteractionEnabled	= NO;
	[self addSubview:_container];
		
	//	add a background image and a centre button
	UIImageView *background				= [[UIImageView alloc] initWithFrame:self.bounds];
	background.image					= [UIImage imageNamed:@"bg.png"];
	[self addSubview:background];
	
	UIImageView *centre					= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"centerButton.png"]];
	centre.center						= CGPointMake(_container.bounds.size.width / 2.0f,
													  _container.bounds.size.height / 2.0f + 3);
	centre.bounds						= CGRectMake(0, 0, 58, 58);
	[self addSubview:centre];
	
	if (self.numberOfSections % 2 == 0)
		[self buildSectorsEven];
	else
		[self buildSectorsOdd];
	
	[self.delegate wheelDidChangeValue:[NSString stringWithFormat:@"Value is %i", _currentSector]];
}

#pragma mark - View-Related Observation Methods

/**
 *	tells the view that its superview changed
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	[self drawWheel];
}

@end