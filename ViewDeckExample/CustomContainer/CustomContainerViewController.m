//
// Created by Albert Schulz on 09.02.15.
// Copyright (c) 2015 Adriaenssen BVBA. All rights reserved.
//

#import "CustomContainerViewController.h"
#import "CustomChildViewController.h"

@interface CustomContainerViewController()

@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation CustomContainerViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.viewControllers = @[[CustomChildViewController new], [CustomChildViewController new]];
        NSLog(@"Childs are: %@", self.viewControllers);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak CustomContainerViewController *weakSelf = self;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop)
    {
        [weakSelf addChildViewController:viewController];

        CGRect frame;

        if (idx == 0)
        {
            // First
            frame = CGRectMake(0, 0, CGRectGetWidth(weakSelf.view.bounds), CGRectGetHeight(weakSelf.view.bounds)/2);
        }
        else
        {
            // Second
            frame = CGRectMake(0, CGRectGetHeight(weakSelf.view.bounds)/2, CGRectGetWidth(weakSelf.view.bounds), CGRectGetHeight(weakSelf.view.bounds)/2);
        }

        viewController.view.frame = frame;

        [weakSelf.view addSubview:viewController.view];

        if (idx == 0) viewController.view.backgroundColor = [UIColor yellowColor];
        else viewController.view.backgroundColor = [UIColor redColor];

        [viewController didMoveToParentViewController:weakSelf];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSLog(@"-viewWillAppear: on Container View Controller");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSLog(@"-viewWillDisappear: on Container View Controller");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    NSLog(@"-viewDidDisappear: on Container View Controller");
}


@end