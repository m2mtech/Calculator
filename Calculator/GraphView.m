//
//  GraphView.m
//  Calculator
//
//  Created by Martin Mandl on 18.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer/AxesDrawer.h"

@interface GraphView ()

@property (nonatomic) BOOL userIsInTheMiddleOfGesture;
@property (nonatomic, strong) NSMutableArray *valueCache;

@end

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize userIsInTheMiddleOfGesture = _userIsInTheMiddleOfGesture;
@synthesize valueCache = _valueCache;

- (NSMutableArray *)valueCache
{
    if (!_valueCache) _valueCache = [[NSMutableArray alloc] init];
    return _valueCache;
}

- (CGPoint)pointOfTouch:(CGPoint)touch
{
    CGPoint point;
    point.x = (touch.x - self.dataSource.origin.x) 
    / self.dataSource.scale;
    point.y = (touch.y - self.dataSource.origin.y) 
    / self.dataSource.scale;    
    return point;
}

- (void)setOriginFor:(CGPoint)point forTouch:(CGPoint)touch
{
    CGPoint origin;
    origin.x = touch.x - point.x * self.dataSource.scale;
    origin.y = touch.y - point.y * self.dataSource.scale;
    self.dataSource.origin = origin;    
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state != UIGestureRecognizerStateChanged) &&
        (gesture.state != UIGestureRecognizerStateEnded)) return;
    if (gesture.state == UIGestureRecognizerStateEnded) self.userIsInTheMiddleOfGesture = NO;
    else if (!self.userIsInTheMiddleOfGesture) self.userIsInTheMiddleOfGesture = YES;    
    CGPoint touch = [gesture locationInView:self];
    CGPoint point = [self pointOfTouch:touch];    
    self.dataSource.scale *= gesture.scale;
    gesture.scale = 1; 
    [self setOriginFor:point forTouch:touch];
    if (gesture.state == UIGestureRecognizerStateEnded) [self setNeedsDisplay];    
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state != UIGestureRecognizerStateChanged) &&
        (gesture.state != UIGestureRecognizerStateEnded)) return;
    if (gesture.state == UIGestureRecognizerStateEnded) self.userIsInTheMiddleOfGesture = NO;
    else if (!self.userIsInTheMiddleOfGesture) self.userIsInTheMiddleOfGesture = YES;    
    CGPoint translation = [gesture translationInView:self];
    translation.x += self.dataSource.origin.x;
    translation.y += self.dataSource.origin.y;
    self.dataSource.origin = translation;    
    [gesture setTranslation:CGPointZero inView:self];
    if (gesture.state == UIGestureRecognizerStateEnded) [self setNeedsDisplay];
}

- (void)center:(UITapGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateEnded) return;
    CGPoint location = [gesture locationInView:self];
    self.dataSource.origin = location;
}

- (CGFloat)xPointFromPixel:(NSInteger)xPixel inRect:(CGRect)bounds
{
    return xPixel / self.contentScaleFactor + bounds.origin.x;
}

- (double)xValueFromPixel:(NSInteger)xPixel inRect:(CGRect)bounds originAtPoint:(CGPoint)origin scale:(CGFloat)pointsPerUnit 
{
    return ([self xPointFromPixel:xPixel inRect:bounds] - origin.x) / pointsPerUnit;
}

- (CGFloat)xPointFromValue:(double)x inRect:(CGRect)bounds originAtPoint:(CGPoint)origin scale:(CGFloat)pointsPerUnit
{
    return origin.x + x * pointsPerUnit;
}

- (CGFloat)yPointFromValue:(double)y inRect:(CGRect)bounds originAtPoint:(CGPoint)origin scale:(CGFloat)pointsPerUnit
{
    return origin.y - y * pointsPerUnit;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    [[UIColor grayColor] setStroke];
    CGRect area = self.bounds;
    CGFloat scale = self.dataSource.scale;
    CGPoint origin = self.dataSource.origin;
    [AxesDrawer drawAxesInRect:area originAtPoint:origin scale:scale];

    [[UIColor blackColor] setStroke];
    NSInteger widthInPixel = area.size.width * self.contentScaleFactor;        
    CGContextSetLineWidth(context, 2);
    CGContextBeginPath(context);
    NSInteger pixelDelta = 1;
    //if (self.userIsInTheMiddleOfGesture) pixelDelta = 10;
    BOOL start = YES;
    CGPoint value, point;
    for (NSInteger xPixel = 0; xPixel <= widthInPixel; xPixel += pixelDelta) {
        if (self.userIsInTheMiddleOfGesture) {
            value = [[self.valueCache objectAtIndex:xPixel] CGPointValue];
            point.x = [self xPointFromValue:value.x inRect:area originAtPoint:origin scale:scale];
            point.y = [self yPointFromValue:value.y inRect:area originAtPoint:origin scale:scale];
        } else {
            value.x = [self xValueFromPixel:xPixel inRect:area 
                              originAtPoint:origin scale:scale];
            id result = [self.dataSource calculateYValueFromXValue:value.x];
            if (![result isKindOfClass:[NSNumber class]]) {
                start = YES;
                continue;
            }
            value.y = [result doubleValue];
            point.x = [self xPointFromPixel:xPixel inRect:area];
            point.y = [self yPointFromValue:value.y inRect:area originAtPoint:origin scale:scale];
            if (xPixel == 0) [self.valueCache removeAllObjects];            
            [self.valueCache addObject:[NSValue valueWithCGPoint:value]];
        }
        if (self.dataSource.drawDots) {                        
            CGContextFillRect(context, CGRectMake(point.x - 0.5, point.y - 0.5, 1.0 , 1.0));
        } else {
            if (start) {
                CGContextMoveToPoint(context, point.x, point.y);
                start = NO;
            } else CGContextAddLineToPoint(context, point.x, point.y);                        
        }
    }    
    CGContextStrokePath(context);
}   

@end
