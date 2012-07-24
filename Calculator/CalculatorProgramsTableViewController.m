//
//  CalculatorProgramsTableViewController.m
//  Calculator
//
//  Created by Martin Mandl on 23.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "CalculatorProgramsTableViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorProgramsTableViewController ()

@end

@implementation CalculatorProgramsTableViewController

@synthesize programs = _programs;
@synthesize delegate = _delegate;

// added after lecture to be sure table gets reloaded if Model changes
// you should always do this (i.e. reload table when Model changes)
// the Model getting out of synch with the contents of the table is bad
- (void)setPrograms:(NSArray *)programs
{
    _programs = programs;
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.programs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Calculator Program Description";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    id program = [self.programs objectAtIndex:indexPath.row];
    cell.textLabel.text = [@"y = " stringByAppendingString:[CalculatorBrain descriptionOfProgram:program]];    
    return cell;
}

// this method added after lecture to support deletion
// simply delegates deletion
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id program = [self.programs objectAtIndex:indexPath.row];
        [self.delegate calculatorProgramsTableViewController:self deletedProgram:program];
    }   
}

// added after lecture
// don't allow deletion if the delegate does not support it too!
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate respondsToSelector:@selector(calculatorProgramsTableViewController:deletedProgram:)];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id program = [self.programs objectAtIndex:indexPath.row];
    [self.delegate calculatorProgramsTableViewController:self choseProgram:program];
}

@end
