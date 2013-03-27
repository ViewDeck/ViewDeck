//
//  CenterViewController.m
//  NavigationExample
//
//  Created by Tom Adriaenssen on 30/05/12.
//  Copyright (c) 2012 Adriaenssen BVBA, 10to1. All rights reserved.
//

#import "CenterViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "DeeperViewController.h"

@interface CenterViewController ()

@end

@implementation CenterViewController

@synthesize behavior = _behavior;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"1";
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goOnPressed:(id)sender {
    DeeperViewController* deeperController = [[DeeperViewController alloc] initWithNibName:@"DeeperViewController" bundle:nil];
    UIViewController* controller = nil;
    if (self.viewDeckController) {
        controller = deeperController;
    }
    else {
        LeftViewController* leftController = [[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil];
        RightViewController* rightController = [[RightViewController alloc] initWithNibName:@"RightViewController" bundle:nil];
        IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:deeperController 
                                                                                       leftViewController:leftController 
                                                                                      rightViewController:rightController];
        deckController.navigationControllerBehavior = self.behavior;
        deckController.delegateMode = IIViewDeckDelegateAndSubControllers;
        controller = deckController;
    }
    
    if (controller)
        [self.navigationController pushViewController:controller animated:YES];
}




@end
