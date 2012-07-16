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

+ (NSString *)stripUnneccessaryParenthesis:(NSString *)string for:(NSString *)operation
{
    if (!string) return @"0"; // empty string equals 0
    if (![string hasPrefix:@"["]) return string; // nothing to do
    NSString *result = [string substringWithRange:NSMakeRange(1, [string length] - 2)];
    if ([operation isEqualToString:@"+"]) return result; 
    if ([operation isEqualToString:@"-"]) return result;
    if ([self isSingleOperandOperation:operation]) return result;
    return [NSString stringWithFormat:@"(%@)", result];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *result = @"";    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    if ([topOfStack isKindOfClass:[NSNumber class]]) 
        result = [topOfStack stringValue];
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([self isSingleOperandOperation:operation]) {
            result = [NSString stringWithFormat:@"%@(%@)", operation, 
                [self stripUnneccessaryParenthesis:[self descriptionOfTopOfStack:stack]for:operation]];            
        } else if ([self isTwoOperandOperation:operation]) {
            NSString *secondOperand = [self descriptionOfTopOfStack:stack];
            secondOperand =[self stripUnneccessaryParenthesis:secondOperand for:operation];
            NSString *firstOperand = [self descriptionOfTopOfStack:stack];
            firstOperand = [self stripUnneccessaryParenthesis:firstOperand for:operation];
            result = [NSString stringWithFormat:@"%@ %@ %@", firstOperand, operation, secondOperand];            
            if ([operation isEqualToString:@"+"] || [operation isEqualToString:@"-"])
                result = [NSString stringWithFormat:@"[%@]", result];            
        } else if ([operation isEqualToString:@"+/-"]) {
            NSString *operand = [self descriptionOfTopOfStack:stack];
            if (!operand) operand = @"0";
            if ([operand hasPrefix:@"-"])
                result = [operand substringFromIndex:1];
            else
                result = [NSString stringWithFormat:@"-%@", operand];
        } else result = operation;
    }
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *result = @"";
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        result = [self stripUnneccessaryParenthesis:[self descriptionOfTopOfStack:stack] for:@"+"];
        if ([stack count])
            result = [NSString stringWithFormat:@"%@, %@", result, [self descriptionOfProgram:stack]];
    }
    return result;
}

+ (id)popOperandOffStack:(id)stack
{
    double result = 0;
    id topOffStack = [stack lastObject];
    if (topOffStack) [stack removeLastObject];
    if ([topOffStack isKindOfClass:[NSNumber class]]) {
        result = [topOffStack doubleValue];
    } else if ([topOffStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOffStack;
        id firstOperand;
        double firstNumber;
        id secondOperand;
        double secondNumber;
        if ([self isTwoOperandOperation:operation]) {
            firstOperand = [self popOperandOffStack:stack];
            if ([firstOperand isKindOfClass:[NSString class]]) return firstOperand;
            secondOperand = [self popOperandOffStack:stack];
            if ([secondOperand isKindOfClass:[NSString class]]) return secondOperand;
            firstNumber = [firstOperand doubleValue];
            secondNumber = [secondOperand doubleValue];
        }
        if ([self isSingleOperandOperation:operation]) {
            firstOperand = [self popOperandOffStack:stack];
            if ([firstOperand isKindOfClass:[NSString class]]) return firstOperand;
            firstNumber = [firstOperand doubleValue];
        }                        
        if ([operation isEqualToString:@"+"]) result = firstNumber + secondNumber;
        else if ([operation isEqualToString:@"*"]) result = firstNumber * secondNumber;
        else if ([operation isEqualToString:@"-"]) result = secondNumber - firstNumber;
        else if ([operation isEqualToString:@"/"]) {
            if (!firstNumber) return @"division by zero";
            result = secondNumber / firstNumber;
        } else if ([operation isEqualToString:@"sin"]) result = sin(firstNumber);
        else if ([operation isEqualToString:@"cos"]) result = cos(firstNumber);
        else if ([operation isEqualToString:@"sqrt"]) {
            if (firstNumber < 0) return @"sqrt of negative number";
            result = sqrt(firstNumber);
        } else if ([operation isEqualToString:@"π"]) result = M_PI;
        else if ([operation isEqualToString:@"+/-"]) result = -firstNumber;        
    }    
    return [NSNumber numberWithDouble:result];
}

+ (id)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (id)runProgram:(id)program 
 usingVariableValues:(NSDictionary *)variableValues 
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        NSInteger stackSize = [stack count];
        NSNumber *varibleValue;
        NSSet *usedVariables = [CalculatorBrain variablesUsedInProgram:stack];
        for (NSInteger i = 0; i < stackSize; i++) {
            id currentItem = [stack objectAtIndex:i];
            if (![usedVariables containsObject:currentItem]) continue;
            varibleValue = [variableValues objectForKey:currentItem];
            if (varibleValue)
                [stack replaceObjectAtIndex:i withObject:varibleValue];
            else [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
        }        
    }        
    return [self runProgram:stack];
}

+ (BOOL)isOperation:(NSString *)operation
{
    NSSet *operators = [NSSet setWithObjects: @"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt", @"π", @"+/-", nil];
    return [operators containsObject:operation];
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    NSSet *operators = [NSSet setWithObjects: @"+", @"*", @"-", @"/", nil];
    return [operators containsObject:operation];
}

+ (BOOL)isSingleOperandOperation:(NSString *)operation
{
    NSSet *operators = [NSSet setWithObjects: @"sin", @"cos", @"sqrt", nil];
    return [operators containsObject:operation];
}

+ (NSSet *)variablesUsedInProgram:(id)program 
{
    if (![program isKindOfClass:[NSArray class]]) return nil;    
    NSMutableSet *usedVariables = [NSMutableSet set];    
    for (id obj in program) {
        if ([obj isKindOfClass:[NSNumber class]]) continue;
        if ([self isOperation:obj]) continue;
        [usedVariables addObject:obj];        
    }        
    if (!usedVariables) return nil;
    return usedVariables;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushOperation:(NSString *)operation {
    [self.programStack addObject:operation];    
}

- (void)pushVariable:(NSString *)variable {
    [self.programStack addObject:variable];    
}

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)performOperation:(NSString *)operation 
       usingVariableValues:(NSDictionary *)variableValues
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];    
}

- (void) clearStack
{
    [self.programStack removeAllObjects];
}

- (void) clearLastItem
{
    [self.programStack removeLastObject];
}


@end
