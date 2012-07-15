//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Martin Mandl on 14.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) 
        _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program
{    
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in Assignment 2";
}

+ (double)popOperandOffStack:(id)stack
{
    double result = 0;
    id topOffStack = [stack lastObject];
    if (topOffStack) [stack removeLastObject];
    if ([topOffStack isKindOfClass:[NSNumber class]]) {
        result = [topOffStack doubleValue];
    } else if ([topOffStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOffStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];        
        } else if ([@"-" isEqualToString:operation]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;        
        } else if ([@"/" isEqualToString:operation]) {
            double divisor = [self popOperandOffStack:stack];
            if (!divisor) return 0;
            result = [self popOperandOffStack:stack] / divisor;        
        } else if ([operation isEqualToString:@"sin"]) 
            result = sin([self popOperandOffStack:stack]);
        else if ([operation isEqualToString:@"cos"]) result = cos([self popOperandOffStack:stack]);
        else if ([operation isEqualToString:@"sqrt"]) {
            double number = [self popOperandOffStack:stack];
            if (number < 0) return 0;
            result = sqrt(number);
        } else if ([operation isEqualToString:@"π"]) result = M_PI;
        else if ([operation isEqualToString:@"+/-"]) 
            result = -[self popOperandOffStack:stack];        
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (void) clearStack
{
    [self.programStack removeAllObjects];
}

@end
