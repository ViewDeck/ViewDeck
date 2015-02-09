//
// Created by Albert Schulz on 09.02.15.
// Copyright (c) 2015 Adriaenssen BVBA. All rights reserved.
//

#import "CustomLeftViewController.h"
#import "CustomModalViewController.h"


@implementation CustomLeftViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blueColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Show Modal" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 20, 100, 40);
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonPressed:(id)buttonPressed
{
    CustomModalViewController *modalViewController = [CustomModalViewController new];

    [self presentViewController:modalViewController animated:YES completion:nil];
}

@end