//
// Created by Albert Schulz on 09.02.15.
// Copyright (c) 2015 Adriaenssen BVBA. All rights reserved.
//

#import "CustomChildViewController.h"


@implementation CustomChildViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSLog(@"-viewDidAppear: on Child=%@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSLog(@"-viewWillAppear: on Child=%@", self);
}

@end