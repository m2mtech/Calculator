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
@property (nonatomic, strong) CalculatorBrain *brain;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    // alternative notation
    //NSString *digit = [sender currentTitle];

    NSString *digit = sender.currentTitle;
    
    // output to console
    //NSLog(@"digit pressed = %@", digit);
    
    // alternative notation
    //UILabel *myDisplay = [self display];
    //NSString *currentText = [myDisplay text];
    //NSString *newText = [currentText stringByAppendingString:digit];
    //[myDisplay setText:newText];
        
    // alternative notation
    //UILabel *myDisplay = self.display;
    //NSString *currentText = myDisplay.text;
    //NSString *newText = [currentText stringByAppendingString:digit];    
    //myDisplay.text = newText;
    
    // one-line solution
    //self.display.text = [self.display.text stringByAppendingString:digit];    
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    double result = [self.brain performOperation:sender.currentTitle];
    self.display.text = [NSString stringWithFormat:@"%g", result]; 
}

@end
