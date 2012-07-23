//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Martin Mandl on 14.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringAFloat;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@property (weak, nonatomic) IBOutlet UISwitch *drawLinesSwitch;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize usedVariables = _usedVariables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userIsInTheMiddleOfEnteringAFloat;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;
@synthesize drawLinesSwitch = _drawLinesSwitch;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) detailVC = nil;
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
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
    
    self.display.text = [NSString stringWithFormat:@"%@",
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
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
        [segue.destinationViewController setDrawDots:!self.drawLinesSwitch.on];
        [segue.destinationViewController setProgram:self.brain.program];
    }        
}

- (IBAction)graphButtonPressed {
    id gVC = [self.splitViewController.viewControllers lastObject];
    if (![gVC isKindOfClass:[GraphViewController class]]) return;
    [gVC setDrawDots:!self.drawLinesSwitch.on];
    [gVC setProgram:self.brain.program];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.splitViewController) return YES; 
    else return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)viewDidUnload {
    [self setHistory:nil];
    [self setUsedVariables:nil];
    [self setDrawLinesSwitch:nil];
    [super viewDidUnload];
}
@end
