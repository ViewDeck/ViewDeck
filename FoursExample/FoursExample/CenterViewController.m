//
//  CenterViewController.m
//  FoursExample
//
//  Created by Tom Adriaenssen on 12/09/12.
//  Copyright (c) 2012 Interface Implemenation. All rights reserved.
//

#import "CenterViewController.h"
#import "IIViewDeckController.h"

@interface CenterViewController ()

@end

@implementation CenterViewController

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
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)openLeft:(id)sender {
    [self.viewDeckController openLeftView];
}

- (IBAction)openRight:(id)sender {
    [self.viewDeckController openRightView];
}

- (IBAction)openTop:(id)sender {
    [self.viewDeckController openTopView];
}

- (IBAction)openBottom:(id)sender {
    [self.viewDeckController openBottomView];
}

- (IBAction)openLeftBouncing:(id)sender {
    [self.viewDeckController openLeftViewBouncing:nil];
}

- (IBAction)openRightBouncing:(id)sender {
    [self.viewDeckController openRightViewBouncing:nil];
}

- (IBAction)openTopBouncing:(id)sender {
    [self.viewDeckController openTopViewBouncing:nil];
}

- (IBAction)openBottomBouncing:(id)sender {
    [self.viewDeckController openBottomViewBouncing:nil];
}

@end
