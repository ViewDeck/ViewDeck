//
//  IIViewDeckController.m
//  ViewDeckExample
//
//  Created by Tom Adriaenssen on 03/12/11.
//  Copyright (c) 2011 Adriaenssen BVBA. All rights reserved.
//

#import "IIViewDeckController.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface IIViewDeckController () {
}

@property (nonatomic, retain) UIViewController* centerController;
@property (nonatomic, retain) UIViewController* leftController;
@property (nonatomic, retain) UIViewController* rightController;
//@property (nonatomic, retain) UIViewController* topController;
//@property (nonatomic, retain) UIViewController* bottomController;

@end 

@interface UIViewController (Stuff_Internal) 

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController;

@end

@implementation IIViewDeckController

@synthesize centerController = _centerController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;

#pragma mark - Initalisation and deallocation

- (id)initWithCenterViewController:(UIViewController*)centerController {
    if ((self = [self init])) {
        self.centerController = centerController;
        [self.centerController setViewDeckController:self];
        self.leftController = nil;
        self.rightController = nil;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.leftController = leftController;
        [self.leftController setViewDeckController:self];
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.leftController = leftController;
        [self.leftController setViewDeckController:self];

        self.rightController = rightController;
        [self.rightController setViewDeckController:self];
    }
    return self;
}

- (void)dealloc {
    self.centerController.viewDeckController = nil;
    self.leftController.viewDeckController = nil;
    self.rightController.viewDeckController = nil;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.centerController didReceiveMemoryWarning];
    [self.leftController didReceiveMemoryWarning];
    [self.rightController didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    [self.view addSubview:self.leftController.view];
    [self.view addSubview:self.rightController.view];
    [self.view addSubview:self.centerController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [self.centerController.view removeFromSuperview];
    [self.leftController.view removeFromSuperview];
    [self.rightController.view removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.centerController.view.frame = self.view.bounds;
    self.centerController.view.hidden = NO;
    self.leftController.view.frame = self.view.bounds;
    self.leftController.view.hidden = YES;
    self.rightController.view.frame = self.view.bounds;
    self.rightController.view.hidden = YES;

    self.centerController.view.layer.shadowRadius = 10;
    self.centerController.view.layer.shadowOpacity = 0.5;
    self.centerController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.centerController.view.layer.shadowOffset = CGSizeZero;
    self.centerController.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.view.bounds] CGPath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.centerController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    // todo check slidden out controller
}

#define SLIDE_DURATION(animated) ((animated) ? 0.3 : 0)

- (void)toggleLeftView {
    [self toggleLeftViewAnimated:YES];
}

- (void)openLeftView {
    [self openLeftViewAnimated:YES];
}

- (void)closeLeftView {
    [self closeLeftViewAnimated:YES];
}

- (void)toggleLeftViewAnimated:(BOOL)animated {
    NSLog(@"left(%@).view.hidden = %d", self.leftController, self.leftController.view.hidden);
    if (self.leftController.view.hidden) 
        [self openLeftViewAnimated:animated];
    else
        [self closeLeftViewAnimated:animated];
}

- (void)openLeftViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:SLIDE_DURATION(animated) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        int leftMargin = 44;
        self.leftController.view.hidden = NO;
        self.centerController.view.frame = (CGRect) { self.view.bounds.size.width - leftMargin, 0, self.view.bounds.size };
    } completion:^(BOOL finished) {
    }];
}

- (void)closeLeftViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:SLIDE_DURATION(animated) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.centerController.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        self.leftController.view.hidden = YES;
    }];
}

- (void)toggleRightView {
    [self toggleRightViewAnimated:YES];
}

- (void)openRightView {
    [self openRightViewAnimated:YES];
}

- (void)closeRightView {
    [self closeRightViewAnimated:YES];
}

- (void)toggleRightViewAnimated:(BOOL)animated {
    if (self.rightController.view.hidden) 
        [self openRightViewAnimated:animated];
    else
        [self closeRightViewAnimated:animated];
}

- (void)openRightViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:SLIDE_DURATION(animated) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        int rightMargin = 44;
        self.rightController.view.hidden = NO;
        self.centerController.view.frame = (CGRect) { rightMargin - self.view.bounds.size.width, 0, self.view.bounds.size };
    } completion:^(BOOL finished) {
    }];
}

- (void)closeRightViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:SLIDE_DURATION(animated) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.centerController.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        self.rightController.view.hidden = YES;
    }];
}

@end


@implementation UIViewController (Stuff) 

@dynamic viewDeckController;

static char* viewDeckControllerKey = "ViewDeckController";

- (IIViewDeckController*)viewDeckController {
    id result = objc_getAssociatedObject(self, viewDeckControllerKey);
    if (!result && self.navigationController) 
        return [self.navigationController viewDeckController];

    NSLog(@"Getting view deck controller %@ from object %@ (key = %p)", result, self, viewDeckControllerKey);
    return result;
}

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController {
    NSLog(@"Setting view deck controller %@ on object %@ (key = %p)", viewDeckController, self, viewDeckControllerKey);
    objc_setAssociatedObject(self, viewDeckControllerKey, viewDeckController, OBJC_ASSOCIATION_RETAIN);
}

@end

