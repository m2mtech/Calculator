//
//  GraphView.m
//  Calculator
//
//  Created by Martin Mandl on 18.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer/AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
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
    
    CGPoint touch = [gesture locationInView:self];
    CGPoint point = [self pointOfTouch:touch];    
    self.dataSource.scale *= gesture.scale;
    gesture.scale = 1; 
    [self setOriginFor:point forTouch:touch];
    
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state != UIGestureRecognizerStateChanged) &&
        (gesture.state != UIGestureRecognizerStateEnded)) return;
    CGPoint translation = [gesture translationInView:self];
    translation.x += self.dataSource.origin.x;
    translation.y += self.dataSource.origin.y;
    self.dataSource.origin = translation;    
    [gesture setTranslation:CGPointZero inView:self];
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
    for (NSInteger xPixel = 0; xPixel <= widthInPixel; xPixel++) {
        id result = [self.dataSource calculateYValueFromXValue:[self xValueFromPixel:xPixel inRect:area originAtPoint:origin scale:scale]];
        if (![result isKindOfClass:[NSNumber class]]) continue;
        double y = [result doubleValue];
        CGContextFillRect(context, CGRectMake([self xPointFromPixel:xPixel inRect:area] - 0.5, [self yPointFromValue:y inRect:area originAtPoint:origin scale:scale] - 0.5, 1.0 , 1.0));        
    }    
    
    CGContextStrokePath(context);
}    

@end
