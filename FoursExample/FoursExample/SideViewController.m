//
//  SideViewController.m
//  FoursExample
//
//  Created by Tom Adriaenssen on 12/09/12.
//  Copyright (c) 2012 Interface Implemenation. All rights reserved.
//

#import "SideViewController.h"
#import "IIViewDeckController.h"

@interface SideViewController ()

@end

@implementation SideViewController

@synthesize color = _color;

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
    self.view.backgroundColor = self.color;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)close:(id)sender {
    [self.viewDeckController closeOpenView];
}

-(IBAction)closeBouncing:(id)sender {
    [self.viewDeckController closeOpenViewBouncing:nil];
}

-(IBAction)toggle:(id)sender {
    [self.viewDeckController toggleOpenView];
}

-(IBAction)openLeft:(id)sender {
    [self.viewDeckController openLeftView];
}

-(IBAction)openRight:(id)sender {
    [self.viewDeckController openRightView];
}

-(IBAction)openTop:(id)sender {
    [self.viewDeckController openTopView];
}

-(IBAction)openBottom:(id)sender {
    [self.viewDeckController openBottomView];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ will appear", NSStringFromIIViewDeckSide([self.viewDeckController sideForController:self]));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ did appear", NSStringFromIIViewDeckSide([self.viewDeckController sideForController:self]));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ will disappear", NSStringFromIIViewDeckSide([self.viewDeckController sideForController:self]));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@ did disappear", NSStringFromIIViewDeckSide([self.viewDeckController sideForController:self]));
}

@end
