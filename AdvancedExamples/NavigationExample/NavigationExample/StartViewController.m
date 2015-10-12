//
//  StartViewController.m
//  NavigationExample
//
//  Created by Tom Adriaenssen on 27/05/12.
//  Copyright (c) 2012 Adriaenssen BVBA, 10to1. All rights reserved.
//

#import "StartViewController.h"
#import "CenterViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "IIViewDeckController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)viewDeckAroundPressed:(id)sender {
    CenterViewController* centerController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    LeftViewController* leftController = [[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil];
    RightViewController* rightController = [[RightViewController alloc] initWithNibName:@"RightViewController" bundle:nil];
    
    IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:[[UINavigationController alloc] initWithRootViewController:centerController]
                                                                                   leftViewController:leftController  
                                                                                  rightViewController:rightController];
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    deckController.delegateMode = IIViewDeckDelegateAndSubControllers;
    
    [self presentViewController:deckController animated:YES completion:nil];
}

- (IBAction)integratedViewDeckInPressed:(id)sender {
    CenterViewController* centerController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    centerController.behavior = IIViewDeckNavigationControllerIntegrated;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:centerController] animated:YES completion:nil];
}

- (IBAction)containedViewDeckInPressed:(id)sender {
    CenterViewController* centerController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    centerController.behavior = IIViewDeckNavigationControllerContained;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:centerController] animated:YES completion:nil];
}

@end
