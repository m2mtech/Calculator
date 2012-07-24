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
- (void)pushOperation:(NSString *)operation;
- (void)pushVariable:(NSString *)variable;

- (id)performOperation:(NSString *)operation;
- (id)performOperation:(NSString *)operation
   usingVariableValues:(NSDictionary *)variableValues;
- (void)clearStack;
- (void)clearLastItem;

// program is always guaranteed to be a Property List
@property (readonly) id program;

+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program 
   usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;
+ (BOOL)isOperation:(NSString *)operation;

@end
