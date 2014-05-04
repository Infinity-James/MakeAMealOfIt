//
//  RotaryWheel.m
//  SpinningWheel
//
//  Created by James Valaitis on 28/02/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RotaryWheel.h"
#import "Sector.h"
#import "SegmentView.h"

@import QuartzCore;

#pragma mark - Constants & Static Variables

/**	The maximum value for the alpha level of a segment in the wheel.	*/
static CGFloat const RotaryWheelSegmentMaximumAlpha		= 1.0f;
/**	The minimum value for the alpha level of a segment in the wheel.	*/
static CGFloat const RotaryWheelSegmentMinimumAlpha		= 0.6f;

#pragma mark - Rotary Wheel Class Extension

@interface RotaryWheel ()

#pragma mark - Private Properties: State

/**	The angle for the segments in this wheel.	*/
@property (nonatomic, assign)	CGFloat				angleForSegments;
/**	The angle relative to the centre of the wheel where a gesture begins.	*/
@property (nonatomic, assign)	CGFloat				angleStartPoint;
/**	The transform of the container view at the beginning of a gesture.	*/
@property (nonatomic, assign)	CGAffineTransform	containerViewStartTransform;
/**	The radius of this wheel.	*/
@property (nonatomic, assign)	CGFloat				radius;
/**	The index of the currently selected sector.	*/
@property (nonatomic, assign)	NSUInteger			selectedSectorIndex;

#pragma mark - Private Properties: Subviews

/**	A view which acts as the container for all of the segments in the wheel.	*/
@property (nonatomic, strong)	UIView				*containerView;
/**	An array of the sectors being managed by this wheel.	*/
@property (nonatomic, strong)	NSMutableArray		*sectors;

@end

#pragma mark - Rotary Wheel Implementation

@implementation RotaryWheel {}

#pragma mark - Convenience & Helper Methods

/**
 *	Build the sectors if there are an even number of them.
 */
- (void)buildSectorsEven
{
	//	set the first midpoint to be 0π
	CGFloat midPoint = 0.0f;
	
	//	initialise each sector with all properties
	for (NSInteger index = 0; index < self.numberOfSegments; index++)
	{
		Sector *sector = [[Sector alloc] initWithMinimumAngle:midPoint - (self.angleForSegments / 2)
												  middleAngle:midPoint
												 maximumAngle:midPoint + (self.angleForSegments / 2)
												  andSectorID:index];
		
		//	if the next circle will pass the half way mark we recalculate the angles (a circle is -π to π)
		if (sector.maximumAngle - self.angleForSegments < -M_PI)
		{
			midPoint = M_PI;
			sector.middleAngle = midPoint;
			sector.minimumAngle = fabsf(sector.maximumAngle);
		}
		
		//	go down to next midpoint
		midPoint -= self.angleForSegments;
		
		[self.sectors addObject:sector];
	}
}

/**
 *	Build the sectors if there an odd number of them.
 */
- (void)buildSectorsOdd
{
	//	set the first midpoint to be 0π
	CGFloat midPoint = 0.0f;
	
	//	initialise each sector with all properties
	for (NSInteger index = 0; index < self.numberOfSegments; index++)
	{
		Sector *sector = [[Sector alloc] initWithMinimumAngle:midPoint - (self.angleForSegments / 2)
												  middleAngle:midPoint
												 maximumAngle:midPoint + (self.angleForSegments / 2)
												  andSectorID:index];
		
		//	go down to next midpoint
		midPoint						-= self.angleForSegments;
		
		//	if the sector is about to cross the half way mark (-π) of the circle we reset to π (a circle is -π to π)
		if (sector.minimumAngle < -M_PI)
		{
			midPoint = -midPoint;
			midPoint -= self.angleForSegments;
		}
		
		[self.sectors addObject:sector];
	}
}

/**
 *	Handles everything required to properly deselect a segment of this wheel.
 *
 *	@param	segmentView					The segment of the wheel to deselect.
 */
- (void)deselectSegment:(SegmentView *)segmentView
{
	segmentView.alpha = RotaryWheelSegmentMinimumAlpha;
	segmentView.selected = NO;
	segmentView.transform = CGAffineTransformMakeRotation(self.angleForSegments * segmentView.tag);
}

/**
 *	Returns the segment view for a given value.
 *
 *	@param	value						Value of the sector to return.
 *
 *	@return	 A SegmentView appropriate for the given value.
 */
- (SegmentView *)getSegementViewAtIndex:(NSUInteger)index
{
	SegmentView *segmentView;
	
	for (SegmentView *segment in self.containerView.subviews)
	{
		if (segment.tag == index)
		{
			segmentView					= segment;
		}
	}
	
	return segmentView;
}

/**
 *	Handles everything required to properly select a segment of this wheel.
 *
 *	@param	segmentView					The segment of the wheel to select.
 */
- (void)selectSegment:(SegmentView *)segmentView
{
	segmentView.alpha = RotaryWheelSegmentMaximumAlpha;
	segmentView.selected = YES;
	segmentView.transform = CGAffineTransformScale(segmentView.transform, 1.3f, 1.3f);
	[self.containerView bringSubviewToFront:segmentView];
}

/**
 *	Updates the delegate with the currently selected sector.
 */
- (void)updateDelegate
{
	[self.delegate wheelDidChangeValue:self.selectedSectorIndex];
}

#pragma mark - Initialisation

/**
 *	Initialises an instance of this rotary wheel with the amount of sections it should have as well as the delegate.
 *
 *	@param	delegate					The delegate wanting to receive notifications from this wheel.
 *	@param	sectionsNumber				The number of sections that this wheel should have.
 *
 *	@return	An initalised RotaryWheel object.
 */
- (instancetype)initWithDelegate:(id<RotaryWheelDelegate>)delegate
					withSections:(NSInteger)sectionsNumber
{
	return [self initWithFrame:CGRectZero andDelegate:delegate withSections:sectionsNumber];
}

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						Frame rectangle for the view, measured in points.
 *	@param	delegate					Delegate for the rotary protocol.
 *	@param	sectionsNumber				Number of sections for the rotary wheel control.
 *
 *	@return	An initalised RotaryWheel object.
 */
- (instancetype)initWithFrame:(CGRect)frame
				  andDelegate:(id<RotaryWheelDelegate>)delegate
				 withSections:(NSInteger)sectionsNumber
{
	//	give the wheel a equal width and height (and over 64.0f)
	CGFloat frameWidth = CGRectGetWidth(frame);
	CGFloat frameHeight = CGRectGetHeight(frame);
	CGFloat dimension = MAX(frameWidth, frameHeight);
	dimension = MAX(dimension, 64.0f);
	
	frame.size = CGSizeMake(dimension, dimension);
	
    if (self = [super initWithFrame:frame])
	{
		self.delegate					= delegate;
		self.numberOfSegments			= sectionsNumber;
		
		self.sectors					= [[NSMutableArray alloc] initWithCapacity:self.numberOfSegments];
    }
	
    return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	returns the angle size of each section in radians
 */
- (CGFloat)angleForSegments
{
	//	lazily calculate the anfle for the segments to be the radians in a circle divided by the number of segments
	if (!_angleForSegments)
	{
		_angleForSegments = (2 * M_PI) / self.numberOfSegments;
	}
	
	return _angleForSegments;
}

/**
 *	The radius of this wheel.
 *
 *	@return	The radius of this wheel.
 */
- (CGFloat)radius
{
	if (!_radius)
	{
		CGFloat dimension = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
		_radius = dimension * 0.45f;
	}
	
	return _radius;
}

/**
 *
 *
 *	@param	segmentTitles				The titles for each segment in this wheel.
 */
- (void)setSegmentTitles:(NSArray *)segmentTitles
{
	if (segmentTitles.count == self.numberOfSegments)
		_segmentTitles					= segmentTitles;
}

#pragma mark - UIControl Methods

/**
 *	Sent to the control when a touch related to the given event enters the control’s bounds.
 *
 *	@param	touch						A UITouch object that represents a touch on the receiving control during tracking.
 *	@param	event						An event object encapsulating the information specific to the user event.
 *
 *	@return	YES if the receiver is set to respond continuously or set to respond when a touch is dragged; otherwise NO.
 */
- (BOOL)beginTrackingWithTouch:(UITouch *)touch
					 withEvent:(UIEvent *)event
{
	[super beginTrackingWithTouch:touch withEvent:event];
	
	CGPoint touchPoint = [touch locationInView:self];
	
	//	filter out touchs too close to centre of wheel
	CGFloat magnitudeFromCentre = [self calculateDistanceFromCentre:touchPoint];
	
	if (magnitudeFromCentre < 40)
	{
		return NO;
	}
	
	//	calculate distance from centre
	CGFloat deltaX = touchPoint.x - self.containerView.center.x;
	CGFloat deltaY = touchPoint.y - self.containerView.center.y;
	
	//	calculate the arctangent of the opposite (y axis) over the adjacent (x axis) to get the angle
	self.angleStartPoint = atan2(deltaY, deltaX);
	
	self.containerViewStartTransform = self.containerView.transform;
	
	//	selection in limbo so deselect the currently selected sector
	[UIView animateWithDuration:0.2f animations:
	^{
		[self deselectSegment:[self getSegementViewAtIndex:self.selectedSectorIndex]];
	}];
	
	return YES;
}

/**
 *	Sent continuously to the control as it tracks a touch related to the given event within the control’s bounds.
 *
 *	@param	touch						A UITouch object that represents a touch on the receiving control during tracking.
 *	@param	event						An event object encapsulating the information specific to the user event.
 *
 *	@return	YES if touch tracking should continue; otherwise NO.
 */
- (BOOL)continueTrackingWithTouch:(UITouch *)touch
						withEvent:(UIEvent *)event
{
	[super continueTrackingWithTouch:touch withEvent:event];
	
	CGPoint touchPoint = [touch locationInView:self];
	
	//	calculate distance from centre
	CGFloat deltaX = touchPoint.x - self.containerView.center.x;
	CGFloat deltaY = touchPoint.y - self.containerView.center.y;
	
	//	calculate the arctangent of the opposite (y axis) over the adjacent (x axis) to get the angle
	CGFloat angle = atan2(deltaY, deltaX);
	
	//	calculate difference between angles
	CGFloat angleDelta = self.angleStartPoint - angle;
	
	//	rotate the segments to follow the gesture
	self.containerView.transform = CGAffineTransformRotate(self.containerViewStartTransform, -angleDelta);
	
	return YES;
}

/**
 *	Sent to the control when the last touch for the given event completely ends, telling it to stop tracking.
 *
 *	@param	touch						A UITouch object that represents a touch on the receiving control during tracking.
 *	@param	event						An event object encapsulating the information specific to the user event.
 */
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	
	//	get current container rotation
	CGFloat radians = atan2f(self.containerView.transform.b, self.containerView.transform.a);
	CGFloat restingRotationAngle = 0.0f;
	
	//	iterate through each sector and check which one contains the radian value
	for (Sector *sector in self.sectors)
	{
		//	check for anomaly (occurs with even number sectors)
		if (sector.minimumAngle > 0.0f && sector.maximumAngle < 0.0f)
		{
			if (sector.maximumAngle > radians || sector.minimumAngle < radians)
			{
				//	determine whether quadrant is positive or negative
				if (radians > 0)
					restingRotationAngle = radians - M_PI;
				else
					restingRotationAngle = radians + M_PI;
				
				self.selectedSectorIndex = sector.sectorID;
			}
		}
		
		//	in the usual case we check the nearest sector to the current rotation and select it
		else if (radians > sector.minimumAngle && radians < sector.maximumAngle)
		{
			restingRotationAngle = radians - sector.middleAngle;
			self.selectedSectorIndex = sector.sectorID;
		}
	}
	
	//	update the delegate on the new selection before we animate it
	[self updateDelegate];
	
	//	set up animation for final rotation and changing of current sector alpha
	[UIView animateWithDuration:0.2f animations:
	^{
		self.containerView.transform = CGAffineTransformRotate(self.containerView.transform, -restingRotationAngle);
		
		[self selectSegment:[self getSegementViewAtIndex:self.selectedSectorIndex]];
	}];
}

#pragma mark - UIView Methods

/**
 *	Lays out subviews.
 */
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (self.frame.size.width > 0.0f && !self.drawnWheel)
	{
		[self drawWheel];
		self.drawnWheel	= YES;
	}
}

#pragma mark - Utility Methods

/**
 *	Returns the magnitude from the centre to a point
 *
 *	@param	point						The point for which we calculate the magnitude relative to the centre.
 *
 *	@return	The magnituse of the given point from the centre of this wheel.
 */
- (CGFloat)calculateDistanceFromCentre:(CGPoint)point
{
	CGPoint centre = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
	CGFloat deltaX = point.x - centre.x;
	CGFloat deltaY = point.y - centre.y;
	
	//	return the magnitude of the hypotenuse using pythagoras' theorem
	CGFloat deltaXSquared = deltaX * deltaX;
	CGFloat deltaYSquared = deltaY * deltaY;
	CGFloat magnitude = sqrtf(deltaXSquared + deltaYSquared);
	
	return magnitude;
}

#pragma mark - View Drawing Methods

/**
 *	draws the wheel with all of the segments and stuff
 */
- (void)drawWheel
{
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	//	create container view to put everything else inside
	self.containerView							= [[UIView alloc] initWithFrame:self.bounds];
	
	//	we create a section label for each section requested
	for (NSInteger index = 0; index < self.numberOfSegments; index++)
	{
		//	create the sector and set anchor point (pivot) to the middle right of this rectangle		
		SegmentView *sectorView			= [[SegmentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.radius, 90.0f)];
		sectorView.angleOfSegment		= self.angleForSegments;
		sectorView.opaque				= NO;
		if (self.segmentTitles)
			sectorView.segmentTitle		= self.segmentTitles[index];
		sectorView.tag					= index;
		sectorView.layer.anchorPoint	= CGPointMake(1.0f, 0.5f);
		
		//	position the label in the centre of the container view and rotate u=it according to it's number and the calculated angle
		sectorView.layer.position		= CGPointMake(self.containerView.bounds.size.width / 2.0f,
													  self.containerView.bounds.size.height / 2.0f);
		sectorView.transform			= CGAffineTransformMakeRotation(self.angleForSegments * index);
		
		//	lower the alpha of every sector except for the selected one (by default this is 0)
		if (index == 0)
			[self selectSegment:sectorView];
		else
			sectorView.alpha			= RotaryWheelSegmentMinimumAlpha;
		
		[self.containerView addSubview:sectorView];
	}
	
	self.selectedSectorIndex						= 0;
	SegmentView *currentSegment			= [self getSegementViewAtIndex:self.selectedSectorIndex];
	[self.containerView bringSubviewToFront:currentSegment];
	
	self.containerView.userInteractionEnabled	= NO;
	[self addSubview:self.containerView];
		
	//	add a background image and a centre button
	UIImageView *background				= [[UIImageView alloc] initWithFrame:self.bounds];
	[self addSubview:background];
	
	UIImageView *centre					= [[UIImageView alloc] init];
	centre.center						= CGPointMake(self.containerView.bounds.size.width / 2.0f,
													  self.containerView.bounds.size.height / 2.0f);
	centre.bounds						= CGRectMake(0, 0, 58, 58);
	[self addSubview:centre];
	
	if (self.numberOfSegments % 2 == 0)
		[self buildSectorsEven];
	else
		[self buildSectorsOdd];
	
	[self updateDelegate];
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