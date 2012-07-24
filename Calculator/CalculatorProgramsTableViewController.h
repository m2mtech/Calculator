//
//  CalculatorProgramsTableViewController.h
//  Calculator
//
//  Created by Martin Mandl on 23.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorProgramsTableViewController;

// added <NSObject> after lecture so we can do respondsToSelector: on the delegate
@protocol CalculatorProgramsTableViewControllerDelegate <NSObject> 

@optional
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender 
                                 choseProgram:(id)program;
// added after lecture to support deleting from table
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                               deletedProgram:(id)program; 
@end

@interface CalculatorProgramsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *programs; // of CalculatorBrain programs
@property (nonatomic, weak) id <CalculatorProgramsTableViewControllerDelegate> delegate;

@end
