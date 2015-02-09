//
// Created by Albert Schulz on 09.02.15.
// Copyright (c) 2015 Adriaenssen BVBA. All rights reserved.
//

#import "CustomModalViewController.h"


@implementation CustomModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor greenColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 20, 100, 40);
    [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)dismiss:(id)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

@end