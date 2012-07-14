//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Martin Mandl on 14.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *operandStack;

@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *)operandStack
{
    if (!_operandStack) 
        _operandStack = [[NSMutableArray alloc] init];
    return _operandStack;
}

- (void)setOperandStack:(NSMutableArray *)operandStack
{
    _operandStack = operandStack;
}

- (void)pushOperand:(double)operand
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];
}

- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
    } else if ([@"*" isEqualToString:operation]) {
        result = [self popOperand] * [self popOperand];        
    } else if ([@"-" isEqualToString:operation]) {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;        
    } else if ([@"/" isEqualToString:operation]) {
        double divisor = [self popOperand];
        if (!divisor) return 0;
        result = [self popOperand] / divisor;        
    } else if ([operation isEqualToString:@"sin"]) 
        result = sin([self popOperand]);
    else if ([operation isEqualToString:@"cos"]) result = cos([self popOperand]);
    else if ([operation isEqualToString:@"sqrt"]) {
        double number = [self popOperand];
        if (number < 0) return 0;
        result = sqrt(number);
    } else if ([operation isEqualToString:@"π"]) result = M_PI;

    
    [self pushOperand:result];
    
    return result;
}


- (void) clearStack
{
    [self.operandStack removeAllObjects];
}

@end
