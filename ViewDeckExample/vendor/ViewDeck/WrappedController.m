//
//  WrappedController.m
//  JoeyPOC
//
//  Created by Tom Adriaenssen on 13/12/11.
//  Copyright (c) 2011 Adriaenssen BVBA. All rights reserved.
//

#import "WrappedController.h"

@implementation WrappedController

@synthesize wrappedController = _wrappedController;

#pragma mark - View lifecycle

- (id)initWithViewController:(UIViewController *)controller {
    if ((self = [super init])) {
        _wrappedController = controller;
    }
          
    return self;
}
          
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:self.wrappedController.view.frame];
    self.view.autoresizingMask = self.wrappedController.view.autoresizingMask;
    self.wrappedController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.wrappedController.view removeFromSuperview];
    self.wrappedController.view.frame = self.view.bounds;
    [self.view addSubview:self.wrappedController.view];
    
    [self.view setNeedsLayout];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.wrappedController viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self.wrappedController viewDidAppear:animated];
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.wrappedController.view removeFromSuperview];
}

- (void)dealloc {
    _wrappedController = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.wrappedController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    [self.wrappedController didReceiveMemoryWarning];
}

@end
