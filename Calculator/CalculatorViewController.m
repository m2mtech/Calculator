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

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userIsInTheMiddleOfEnteringAFloat;
@synthesize brain = _brain;

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

- (void)removeEqualSignFromHistory;
{
    NSRange range = [self.history.text rangeOfString:@"="];
    if (range.location == NSNotFound) return;
    NSString *history = [self.history.text copy];
    self.history.text = [history substringToIndex:([history length] - 2)];        
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([digit isEqualToString:@"."])
            if (self.userIsInTheMiddleOfEnteringAFloat) digit = @"";        
        self.display.text = [self.display.text stringByAppendingString:digit];
        self.history.text = [self.history.text stringByAppendingString:digit];
    } else {
        if ([digit isEqualToString:@"."])
            digit = @"0.";
        self.display.text = digit;
        [self removeEqualSignFromHistory];
        self.history.text = [self.history.text stringByAppendingFormat:@" %@", digit];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed {
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self removeEqualSignFromHistory];
        self.history.text = [self.history.text stringByAppendingFormat:@" %@", self.display.text];
    }
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber && [sender.currentTitle isEqualToString:@"+/-"]) {
        NSString *display = [self.display.text copy];
        NSString *history = [self.history.text copy];
        NSInteger lengthDisplay = [display length];
        NSInteger lengthHistory = [history length];
        if ([display hasPrefix:@"-"])
            self.display.text = [display substringFromIndex:1];
        else if ([display doubleValue])
            self.display.text = [NSString stringWithFormat:@"-%@", display];
        self.history.text = [[history substringToIndex:lengthHistory - lengthDisplay] stringByAppendingString:self.display.text];
        return;
    }
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    double result = [self.brain performOperation:sender.currentTitle];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self removeEqualSignFromHistory];
    self.history.text = [self.history.text stringByAppendingFormat:@" %@ =", sender.currentTitle];
}

- (IBAction)clearPressed {
    self.display.text = @"0";
    self.history.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearStack];
}

- (IBAction)backSpace {
    if (!self.userIsInTheMiddleOfEnteringANumber) return;
    NSString *display = [self.display.text copy];
    NSString *history = [self.history.text copy];
    NSInteger lengthDisplay = [display length];
    NSInteger lengthHistory = [history length];
    if (lengthDisplay > 1) {
        self.display.text = [display substringToIndex:(lengthDisplay - 1)];
        self.history.text = [history substringToIndex:(lengthHistory - 1)];
    } else {
        self.display.text = @"0";
        self.history.text = [history substringToIndex:(lengthHistory - 2)];
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }    
}

- (void)viewDidUnload {
    [self setHistory:nil];
    [super viewDidUnload];
}
@end
