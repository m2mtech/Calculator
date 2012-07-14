//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Martin Mandl on 14.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;

@end
