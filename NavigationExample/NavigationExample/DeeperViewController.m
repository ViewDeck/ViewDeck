//
//  DeeperViewController.m
//  NavigationExample
//
//  Created by Tom Adriaenssen on 30/05/12.
//  Copyright (c) 2012 Adriaenssen BVBA, 10to1. All rights reserved.
//

#import "DeeperViewController.h"
#import "IIViewDeckController.h"
#import "LeftViewController.h"
#import "RightViewController.h"

@interface DeeperViewController () <IIViewDeckControllerDelegate>

@property (nonatomic, retain) IBOutlet UILabel* counterLabel;
@property (nonatomic, retain) IBOutlet UILabel* disabledLabel;

@end

@implementation DeeperViewController

@synthesize counterLabel = _counterLabel;
@synthesize disabledLabel = _disabledLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_counterLabel setText:[NSString stringWithFormat:@"%d", self.navigationController.viewControllers.count]];
    self.title = _counterLabel.text;
    if (self.viewDeckController)
        [_disabledLabel setText:(self.navigationController.viewControllers.count % 2 != 0 ? @"right disabled" : @"")];
    else
        [_disabledLabel setText:@"no viewdeck"];
}

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldOpenViewSide:(IIViewDeckSide)viewDeckSide {
    return viewDeckSide != IIViewDeckRightSide || self.navigationController.viewControllers.count % 2 == 0;
}

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    return viewDeckSide != IIViewDeckRightSide || self.navigationController.viewControllers.count % 2 == 0;
}

- (IBAction)goOnPressed:(id)sender {
    DeeperViewController* deeperController = [[DeeperViewController alloc] initWithNibName:@"DeeperViewController" bundle:nil];
    [self.navigationController pushViewController:deeperController animated:YES];
}

- (IBAction)replaceLeftPressed:(id)sender {
    if (!self.viewDeckController)
        return;

    LeftViewController* leftController = [[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil];
    
    CGFloat red = (CGFloat)((arc4random() % 256) / 255.0);
    CGFloat green = (CGFloat)((arc4random() % 256) / 255.0);
    CGFloat blue = (CGFloat)((arc4random() % 256) / 255.0);
    leftController.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    self.viewDeckController.leftController = leftController;
}


- (IBAction)replaceRightPressed:(id)sender {
    if (!self.viewDeckController)
        return;
    
    RightViewController* rightController = [[RightViewController alloc] initWithNibName:@"RightViewController" bundle:nil];
    
    CGFloat red = (CGFloat)((arc4random() % 256) / 255.0);
    CGFloat green = (CGFloat)((arc4random() % 256) / 255.0);
    CGFloat blue = (CGFloat)((arc4random() % 256) / 255.0);
    rightController.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    self.viewDeckController.rightController = rightController;
}
@end
