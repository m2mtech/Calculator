//
//  GraphViewController.m
//  Calculator
//
//  Created by Martin Mandl on 18.07.12.
//  Copyright (c) 2012 m2m. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorProgramsTableViewController.h"

#define DEFAULT_NUMBER_OF_POINTS_PER_UNIT 50.0
#define FAVORITES_KEY @"GraphViewController.Favorites"

@interface GraphViewController () <GraphViewDataSource, CalculatorProgramsTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formula;
// added after lecture to prevent multiple popovers
@property (nonatomic, strong) UIPopoverController *popoverController; 


@end

@implementation GraphViewController
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize formula = _formula;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize popoverController;

@synthesize program = _program;
@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize drawDots = _drawDots;

- (CGFloat)scale 
{
    if (!_scale) return DEFAULT_NUMBER_OF_POINTS_PER_UNIT;
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    if (scale == _scale) return;
    _scale = scale;
    [self.graphView setNeedsDisplay];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults setFloat:self.scale 
                forKey:[NSString stringWithFormat:@"graphViewScale%i", 
                        self.graphView.tag]];
    [defaults synchronize];    
    
}

- (void)setOrigin:(CGPoint)origin
{
    if (CGPointEqualToPoint(origin, _origin)) return;
    _origin = origin;
    [self.graphView setNeedsDisplay];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults setObject:
        [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:self.origin.x], 
            [NSNumber numberWithFloat:self.origin.y], 
            nil]                 
            forKey:[NSString stringWithFormat:@"graphViewOrigin%i", 
                self.graphView.tag]];
    [defaults synchronize];    
}

- (void)setProgram:(id)program {
    _program = program;
    NSString *formula = [CalculatorBrain descriptionOfProgram:program];
    if ([formula isEqualToString:@""]) formula = @"Graph";
    else formula = [NSString stringWithFormat:@"y = %@", formula];
    self.title = formula;
    self.formula.title = formula;
    [self.graphView setNeedsDisplay];
}

- (void)setGraphView:(GraphView *)graphView
{
    if (graphView == _graphView) return;
    _graphView = graphView;
    graphView.dataSource = self;
    [graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] 
        initWithTarget:self.graphView action:@selector(pinch:)]];
    [graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] 
        initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
        initWithTarget:self.graphView action:@selector(center:)];
    tap.numberOfTapsRequired = 3;
    [graphView addGestureRecognizer:tap];
    
    CGPoint point;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultOrigin = [defaults arrayForKey:[NSString stringWithFormat:@"graphViewOrigin%i", self.graphView.tag]];    
    if (defaultOrigin) {
        point.x = [[defaultOrigin objectAtIndex:0] floatValue];
        point.y = [[defaultOrigin objectAtIndex:1] floatValue];
    } else {
        point.x = self.graphView.bounds.origin.x + self.graphView.bounds.size.width / 2;
        point.y = self.graphView.bounds.origin.y + self.graphView.bounds.size.height / 2;
    }
    self.origin = point;
    CGFloat defaultScale = [defaults floatForKey:[NSString stringWithFormat:@"graphViewScale%i", self.graphView.tag]];
    if (defaultScale) self.scale = defaultScale;
}

- (id)calculateYValueFromXValue:(double)xValue
{
    return [CalculatorBrain runProgram:self.program usingVariableValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xValue], @"x", nil]];
}

- (IBAction)addToFavorites 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    [favorites addObject:self.program];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorites Graphs"]) {
        // this if statement added after lecture to prevent multiple popovers
        // appearing if the user keeps touching the Favorites button over and over
        // simply remove the last one we put up each time we segue to a new one
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *) segue;
            [self.popoverController dismissPopoverAnimated:YES];
            // might want to be popover's delegate and self.popoverController = nil on dismiss?
            self.popoverController = popoverSegue.popoverController;
        }
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender choseProgram:(id)program
{
    self.program = program;
    // if you wanted to close the popover when a graph was selected
    // you could uncomment the following line
    // you'd probably want to set self.popoverController = nil after doing so
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
    
    // added after lecture to support iPhone
    [self.navigationController popViewControllerAnimated:YES]; 
}

// added after lecture to support deletion from the table
// deletes the given program from NSUserDefaults (including duplicates)
// then resets the Model of the sender
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                               deletedProgram:(id)program
{
    NSString *deletedProgramDescription = [CalculatorBrain descriptionOfProgram:program];
    NSMutableArray *favorites = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (id program in [defaults objectForKey:FAVORITES_KEY]) {
        if (![[CalculatorBrain descriptionOfProgram:program] 
              isEqualToString:deletedProgramDescription]) {
            [favorites addObject:program];
        }
    }
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
    sender.programs = favorites;
}


- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)viewDidUnload
{
    [self setGraphView:nil];
    [self setToolbar:nil];
    [self setFormula:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
