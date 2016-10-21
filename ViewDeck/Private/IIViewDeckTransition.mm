//
//  IIViewDeckTransition.m
//  IIViewDeck
//
//  Copyright (C) 2016, ViewDeck
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "IIViewDeckTransition.h"

#import "IIEnvironment+Private.h"
#import "IIViewDeckController+Private.h"
#import "IIViewDeckLayoutSupport.h"

NS_ASSUME_NONNULL_BEGIN

@interface IIViewDeckTransition () {
    struct {
        unsigned int appearingTransition:1;
        unsigned int interactive:1;
        unsigned int cancelled:1;
    } _flags;
}

@property (nonatomic, assign) IIViewDeckController *viewDeckController; // this is not weak as it is a required link! If the corresponding view deck controller will be removed, this class can no longer fullfill its purpose!

@property (nonatomic) UIViewController *centerViewController;
@property (nonatomic) UIViewController *sideViewController;

@property (nonatomic) id<IIViewDeckTransitionAnimator> animator;

@property (nonatomic) IIViewDeckSide openSide;

@end


@implementation IIViewDeckTransition

@synthesize centerView = _centerView, initialCenterFrame = _initialCenterFrame, finalCenterFrame = _finalCenterFrame;
@synthesize sideView = _sideView, initialSideFrame = _initialSideFrame, finalSideFrame = _finalSideFrame;
@synthesize decorationView = _decorationView;

- (instancetype)initWithViewDeckController:(IIViewDeckController *)viewDeckController from:(IIViewDeckSide)fromSide to:(IIViewDeckSide)toSide {
    NSParameterAssert(viewDeckController);
    NSParameterAssert(fromSide ^ toSide); // we need exactly one of these to be IIViewDeckSideNone for a valid transition
    self = [super init];
    if (self) {
        _viewDeckController = viewDeckController;

        let layoutSupport = viewDeckController.layoutSupport;

        _centerViewController = viewDeckController.centerViewController;
        _centerView = _centerViewController.view;
        _initialCenterFrame = [layoutSupport frameForSide:IIViewDeckSideNone openSide:fromSide];
        _finalCenterFrame = [layoutSupport frameForSide:IIViewDeckSideNone openSide:toSide];

        IIViewDeckSide side = (IIViewDeckSide)(fromSide | toSide);
        _openSide = side;

        _sideViewController = (side == IIViewDeckSideLeft ? viewDeckController.leftViewController : viewDeckController.rightViewController);
        _sideView = _sideViewController.view;
        _initialSideFrame = [layoutSupport frameForSide:side openSide:fromSide];
        _finalSideFrame = [layoutSupport frameForSide:side openSide:toSide];

        _flags.appearingTransition = (toSide == side);
    }
    return self;
}

- (id<IIViewDeckTransitionAnimator>)animator {
    if (_animator) {
        return _animator;
    }
    _animator = [self.viewDeckController animatorForTransitionWithContext:self];
    return _animator;
}

- (nullable UIView *)decorationView {
    if (_decorationView) {
        return _decorationView;
    }
    _decorationView = [self.viewDeckController decorationViewForTransitionWithContext:self];
    return _decorationView;
}

- (BOOL)isInteractive {
    return _flags.interactive;
}

- (BOOL)isCancelled {
    return _flags.cancelled;
}

- (BOOL)isAppearing {
    return _flags.appearingTransition;
}



#pragma mark - Controller and View Hierarchy

- (void)prepareControllerAndViewHierarchy:(BOOL)animated {
    let containerView = self.viewDeckController.view;
    let decorationView = self.decorationView;

    decorationView.frame = containerView.bounds;
    decorationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.centerView.frame = self.initialCenterFrame;

    self.sideView.frame = self.initialSideFrame;
    if (self->_flags.appearingTransition) {
        NSParameterAssert(!decorationView.superview);
        NSParameterAssert(!self.sideView.superview);

        decorationView.alpha = 0.0;
        [containerView addSubview:decorationView];

        [self.sideViewController beginAppearanceTransition:YES animated:animated];

        UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleHeight;
        if (self.openSide == IIViewDeckSideLeft) {
            autoresizingMask |= UIViewAutoresizingFlexibleRightMargin;
        } else {
            autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin;
        }
        self.sideView.autoresizingMask = autoresizingMask;

         // add the view AFTER `beginAppearanceTransition:animated:`, otherwise adding the view generates appearance calls itself which results in 'Unbalanced calls to begin/end appearance transitions' warnings
        [containerView addSubview:self.sideView];
    } else {
        decorationView.alpha = 1.0;
        [self.sideViewController beginAppearanceTransition:NO animated:animated];
    }
}

- (void)cleanupControllerAndViewHierarchy {
    let containerView = self.viewDeckController.view;
    let decorationView = self.decorationView;

    self.centerView.frame = (self.cancelled ? self.initialCenterFrame : self.finalCenterFrame);

    self.sideView.frame = (self.cancelled ? self.initialSideFrame : self.finalSideFrame);
    if (self->_flags.appearingTransition ^ self->_flags.cancelled) {
        decorationView.alpha = 1.0;
    } else {
        [decorationView removeFromSuperview];
        [self.sideView removeFromSuperview];
    }
    [self.sideViewController endAppearanceTransition];

    if (self.isCancelled) {
        [self.sideViewController beginAppearanceTransition:CGRectContainsRect(containerView.bounds, self.sideView.frame) animated:NO];
        [self.sideViewController endAppearanceTransition];
    }
}



#pragma mark - Interactive Transitions

- (void)beginInteractiveTransition:(UIGestureRecognizer *)recognizer {
    self->_flags.interactive = YES;
    [self prepareControllerAndViewHierarchy:YES];
    [self.animator prepareForTransition:self];
}

- (void)updateInteractiveTransition:(UIGestureRecognizer *)recognizer {
    let containerView = self.viewDeckController.view;
    CGPoint point = [recognizer locationInView:containerView];
    CGFloat overallDistance = CGRectGetMinX(self.finalSideFrame) - CGRectGetMinX(self.initialSideFrame);
    CGFloat relevantEdgePositionForDistanceCovered = (CGRectGetMinX(self.initialSideFrame) < CGRectGetMinX(self.finalSideFrame) ? CGRectGetMaxX(self.initialSideFrame) : CGRectGetMinX(self.initialSideFrame));
    CGFloat distanceCovered = point.x - relevantEdgePositionForDistanceCovered;
    double fractionComplete = IILimitFraction(distanceCovered / overallDistance);
    [self.animator updateInteractiveTransition:self fractionCompleted:fractionComplete];
}

- (void)endInteractiveTransition:(UIGestureRecognizer *)recognizer {
    CGPoint velocity = CGPointZero;
    if ([recognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        let panRecognizer = (UIPanGestureRecognizer *)recognizer;
        velocity = [panRecognizer velocityInView:self.viewDeckController.view];
    }

    CGFloat nativeTransitionDirection = (CGRectGetMinX(self.initialSideFrame) < CGRectGetMinX(self.finalSideFrame) ? 1.0 : -1.0);
    BOOL completeSuccessful = ((nativeTransitionDirection > 0) == (velocity.x > 0));
    self->_flags.cancelled = !completeSuccessful;

    [self.animator animateTransition:self velocity:velocity];
}


#pragma mark - Animated Transitions

- (void)performTransition:(BOOL)animated {
    [self prepareControllerAndViewHierarchy:animated];
    if (animated) {
        [self.animator prepareForTransition:self];
        [self.animator animateTransition:self velocity:CGPointZero];
    }
}

- (void)completeTransition {
    [self cleanupControllerAndViewHierarchy];
    if (self.completionHandler) {
        self.completionHandler(self.cancelled);
    }
}

@end

NS_ASSUME_NONNULL_END
