//
//  GraphViewController.h
//  Calculator
//
//  Created by Martin Mandl on 18.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) CalculatorBrain *program;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

@end
