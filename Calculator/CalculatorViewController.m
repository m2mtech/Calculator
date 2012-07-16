//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Martin Mandl on 14.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringAFloat;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize usedVariables = _usedVariables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userIsInTheMiddleOfEnteringAFloat;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (BOOL)userIsInTheMiddleOfEnteringAFloat
{
    NSRange range = [self.display.text rangeOfString:@"."];
    if (range.location == NSNotFound) return NO;
    return YES;
}

- (void)updateCalculatorView
{
    NSSet *usedVariables = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    NSString *result = @"";    
    
    for (NSString *variableName in usedVariables) {
        NSNumber *value = [self.testVariableValues objectForKey:variableName];
        if (!value) value = [NSNumber numberWithInt:0];
        result = [result stringByAppendingFormat:@"%@ = %@   ", variableName, value];
    }
    self.usedVariables.text = result;
    
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    self.display.text = [NSString stringWithFormat:@"%g",
        [CalculatorBrain runProgram:self.brain.program 
                usingVariableValues:self.testVariableValues]];    
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([digit isEqualToString:@"."])
            if (self.userIsInTheMiddleOfEnteringAFloat) digit = @"";        
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        if ([digit isEqualToString:@"."])
            digit = @"0.";
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateCalculatorView];
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber 
        && [sender.currentTitle isEqualToString:@"+/-"]) {
        NSString *display = [self.display.text copy];
        if ([display hasPrefix:@"-"])
            self.display.text = [display substringFromIndex:1];
        else if ([display doubleValue])
            self.display.text = [NSString stringWithFormat:@"-%@", display];
        return;
    }
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:sender.currentTitle];
    [self updateCalculatorView];
}

- (IBAction)variablePressed:(UIButton *)sender {
    [self.brain pushVariable:sender.currentTitle];
    [self updateCalculatorView];
}

- (IBAction)clearPressed {
    self.display.text = @"0";
    self.history.text = @"";
    self.usedVariables.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearStack];
}

- (IBAction)backSpace {
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain clearLastItem];
        [self updateCalculatorView];
        return;
    }
    NSString *display = [self.display.text copy];
    NSInteger lengthDisplay = [display length];
    if (lengthDisplay > 1) {
        self.display.text = [display substringToIndex:(lengthDisplay - 1)];
    } else {
        self.userIsInTheMiddleOfEnteringANumber = NO;
        [self updateCalculatorView];
    }    
}

- (IBAction)testButtonPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Test 1"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:5], @"x",
            [NSNumber numberWithDouble:-4.8], @"y",
            [NSNumber numberWithInt:0], @"foo",
            nil];
    }
    if ([sender.currentTitle isEqualToString:@"Test 2"]) {
        self.testVariableValues = nil;        
    }
    [self updateCalculatorView];
}

- (void)viewDidUnload {
    [self setHistory:nil];
    [self setUsedVariables:nil];
    [super viewDidUnload];
}
@end
