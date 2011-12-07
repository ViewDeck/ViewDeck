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

#define DURATION_FAST 0.2
#define DURATION_SLOW 0.4
#define SLIDE_DURATION(animated,duration) ((animated) ? (duration) : 0)
#define OPEN_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_FAST)
#define CLOSE_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_SLOW)

@interface IIViewDeckController () <UIGestureRecognizerDelegate> {
    CGFloat _panOrigin;
    BOOL _viewAppeared;
}

//@property (nonatomic, retain) UIViewController* topController;
//@property (nonatomic, retain) UIViewController* bottomController;

- (void)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;
- (void)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;
- (void)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;
- (void)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;

@end 

@interface UIViewController (UIViewDeckItem_Internal) 

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController;

@end

@implementation IIViewDeckController

@synthesize centerController = _centerController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;
@synthesize leftLedge = _leftLedge;
@synthesize rightLedge = _rightLedge;

#pragma mark - Initalisation and deallocation

- (id)initWithCenterViewController:(UIViewController*)centerController {
    if ((self = [self init])) {
        self.centerController = centerController;
        [self.centerController setViewDeckController:self];
        self.leftController = nil;
        self.rightController = nil;
        self.leftLedge = 44;
        self.rightLedge = 44;
        _viewAppeared = NO;
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

- (id)initWithCenterViewController:(UIViewController*)centerController rightViewController:(UIViewController*)rightController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.rightController = rightController;
        [self.rightController setViewDeckController:self];
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

#pragma mark - ledges

- (void)setLeftLedge:(CGFloat)leftLedge {
    leftLedge = MAX(leftLedge, MIN(self.view.bounds.size.width, leftLedge));
    if (_viewAppeared && self.centerController.view.frame.origin.x == self.view.bounds.size.width - _leftLedge) {
        if (leftLedge < _leftLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                self.centerController.view.frame = (CGRect) { self.view.bounds.size.width - leftLedge, 0, self.view.bounds.size };
            }];
        }
        else if (leftLedge > _leftLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                self.centerController.view.frame = (CGRect) { self.view.bounds.size.width - leftLedge, 0, self.view.bounds.size };
            }];
        }
    }
    _leftLedge = leftLedge;
}

- (void)setRightLedge:(CGFloat)rightLedge {
    rightLedge = MAX(rightLedge, MIN(self.view.bounds.size.width, rightLedge));
    if (_viewAppeared && self.centerController.view.frame.origin.x == _rightLedge - self.view.bounds.size.width) {
        if (rightLedge < _rightLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                self.centerController.view.frame = (CGRect) { rightLedge - self.view.bounds.size.width, 0, self.view.bounds.size };
            }];
        }
        else if (rightLedge > _rightLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                self.centerController.view.frame = (CGRect) { rightLedge - self.view.bounds.size.width, 0, self.view.bounds.size };
            }];
        }
    }
    _rightLedge = rightLedge;
}

#pragma mark - View lifecycle

- (void)loadView
{
    _viewAppeared = NO;
    self.view = [[UIView alloc] init];
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
    
    [self.leftController.view removeFromSuperview];
    [self.view addSubview:self.leftController.view];
    [self.rightController.view removeFromSuperview];
    [self.view addSubview:self.rightController.view];
    [self.centerController.view removeFromSuperview];
    [self.view addSubview:self.centerController.view];

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
    
    UIPanGestureRecognizer* panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panner.delegate = self;
    [self.centerController.view addGestureRecognizer:panner];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewAppeared = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _viewAppeared = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.centerController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    // todo check slidden out controller
}

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
    [self openLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options animations:^{
        self.leftController.view.hidden = NO;
        self.centerController.view.frame = (CGRect) { self.view.bounds.size.width - self.leftLedge, 0, self.view.bounds.size };
    } completion:^(BOOL finished) {
    }];
}

- (void)closeLeftViewAnimated:(BOOL)animated {
    [self closeLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options animations:^{
        self.centerController.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        self.leftController.view.hidden = YES;
    }];
}

- (void)closeLeftViewBouncing:(void(^)(IIViewDeckController* controller))bounced {
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.centerController.view.frame = (CGRect) { self.view.bounds.size.width, 0, self.view.bounds.size };
    } completion:^(BOOL finished) {
        if (bounced) {
            bounced(self);
        }
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.centerController.view.frame = self.view.bounds;
        } completion:^(BOOL finished) {
            self.leftController.view.hidden = YES;
        }];
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
    [self openRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options animations:^{
        self.rightController.view.hidden = NO;
        self.centerController.view.frame = (CGRect) { self.rightLedge - self.view.bounds.size.width, 0, self.view.bounds.size };
    } completion:^(BOOL finished) {
    }];
}

- (void)closeRightViewAnimated:(BOOL)animated {
    [self closeRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options animations:^{
        self.centerController.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        self.rightController.view.hidden = YES;
    }];
}

- (void)closeRightViewBouncing:(void(^)(IIViewDeckController* controller))bounced {
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.centerController.view.frame = (CGRect) { -self.view.bounds.size.width, 0, self.view.bounds.size };
    } completion:^(BOOL finished) {
        if (bounced) {
            bounced(self);
        }
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.centerController.view.frame = self.view.bounds;
        } completion:^(BOOL finished) {
            self.rightController.view.hidden = YES;
        }];
    }];
}
#pragma mark - Panning

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    _panOrigin = self.centerController.view.frame.origin.x;
    
    NSLog(@"panorigin = %f (%f)", _panOrigin, self.centerController.view.frame.origin.x);
    return YES;
}

- (void)panned:(UIPanGestureRecognizer*)panner {
    CGPoint pan = [panner translationInView:self.view];
    
    // restarts
    CGFloat x = pan.x + _panOrigin;
    if (ABS(x) < 10) return;
    
    if (!self.leftController) x = MIN(0, x);
    if (!self.rightController) x = MAX(0, x);

    x = MAX(x, -self.view.bounds.size.width+self.rightLedge);
    x = MIN(x, self.view.bounds.size.width-self.leftLedge);
    self.centerController.view.frame = (CGRect) { x, 0, self.view.bounds.size };

    self.rightController.view.hidden = x > 0;
    self.leftController.view.hidden = x < 0;
    
    if (panner.state == UIGestureRecognizerStateEnded) {
        if ([panner velocityInView:self.view].x > 0) {
            if (x > self.view.bounds.size.width/3.0) 
                [self openLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut];
            else
                [self closeRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut];
        }
        else if ([panner velocityInView:self.view].x < 0) {
            if (x < -self.view.bounds.size.width/3.0) 
                [self openRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut];
            else
                [self closeLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut];
        }
    }
}


@end


@implementation UIViewController (UIViewDeckItem) 

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

