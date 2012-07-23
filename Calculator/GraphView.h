//
//  GraphView.h
//  Calculator
//
//  Created by Martin Mandl on 18.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphViewDataSource

- (id)calculateYValueFromXValue:(double)xValue; // NSNumber or string with error

@property (nonatomic) CGFloat scale; // 1 = 100%
@property (nonatomic) CGPoint origin; // point to place in the middle of the screen
@property (nonatomic) BOOL drawDots; // YES: draw dots; NO: draw lines

@end

@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)center:(UITapGestureRecognizer *)gesture;

@end
