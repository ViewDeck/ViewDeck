//
//  IIViewDeckController.m
//  IIViewDeck
//
//  Copyright (C) 2011-2016, ViewDeck
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

#import "IIViewDeckController+Private.h"

#import "IIEnvironment+Private.h"
#import "IIViewDeckLayoutSupport.h"
#import "UIViewController+Private.h"
#import "IIDelegateProxy.h"
#import "IIViewDeckDefaultTransitionAnimator.h"
#import "IIViewDeckTransition.h"


NS_ASSUME_NONNULL_BEGIN

NSString* NSStringFromIIViewDeckSide(IIViewDeckSide side) {
    switch (side) {
        case IIViewDeckSideLeft:
            return @"left";
            
        case IIViewDeckSideRight:
            return @"right";
            
        default:
            return @"unknown";
    }
}


// View subclasses for easier view debugging:
@interface IIViewDeckView : UIView @end

@implementation IIViewDeckView @end


@interface IIViewDeckController () <UIGestureRecognizerDelegate> {
    struct {
        unsigned int isInSideChange: 1;
        unsigned int isPanningEnabled: 1;
    } _flags;
}

@property (nonatomic) id<IIViewDeckControllerDelegate> delegateProxy;

@property (nonatomic) IIViewDeckLayoutSupport *layoutSupport;
@property (nonatomic, nullable) IIViewDeckTransition *currentTransition;
@property (nonatomic, nullable) UIGestureRecognizer *currentInteractiveGesture;

@property (nonatomic) UIScreenEdgePanGestureRecognizer *leftEdgeGestureRecognizer;
@property (nonatomic) UIScreenEdgePanGestureRecognizer *rightEdgeGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *decorationTapGestureRecognizer;

@property (nonatomic) UIView *currentDecorationView;

@end


@implementation IIViewDeckController

II_DELEGATE_PROXY(IIViewDeckControllerDelegate);

#pragma mark - Object Initialization

- (instancetype)initWithCenterViewController:(UIViewController*)centerViewController {
    return [self initWithCenterViewController:centerViewController leftViewController:nil rightViewController:nil];
}

- (instancetype)initWithCenterViewController:(UIViewController*)centerViewController leftViewController:(nullable UIViewController*)leftViewController {
    return [self initWithCenterViewController:centerViewController leftViewController:leftViewController rightViewController:nil];
}

- (instancetype)initWithCenterViewController:(UIViewController*)centerViewController rightViewController:(nullable UIViewController*)rightViewController {
    return [self initWithCenterViewController:centerViewController leftViewController:nil rightViewController:rightViewController];
}

- (instancetype)initWithCenterViewController:(UIViewController*)centerViewController leftViewController:(nullable UIViewController*)leftViewController rightViewController:(nullable UIViewController*)rightViewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSParameterAssert(centerViewController);

        // Default flags
        _flags.isInSideChange = NO;
        _flags.isPanningEnabled = YES;

        _layoutSupport = [[IIViewDeckLayoutSupport alloc] initWithViewDeckController:self];

        // Trigger the setter as they keep track of the view controller hierarchy!
        self.centerViewController = centerViewController;
        self.leftViewController = leftViewController;
        self.rightViewController = rightViewController;

        // Trigget setter as this creates the correct proxy!
        self.delegate = nil;
    }
    return self;
}



#pragma mark - Init Overrides

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _layoutSupport = [[IIViewDeckLayoutSupport alloc] initWithViewDeckController:self];

        // Trigget setter as this creates the correct proxy!
        self.delegate = nil;
    }
    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    return [self initWithCenterViewController:[UIViewController new] leftViewController:nil rightViewController:nil];
}



#pragma mark - View Lifecycle

- (void)loadView {
    CGRect screenFrame = UIScreen.mainScreen.bounds;
    self.view = [[IIViewDeckView alloc] initWithFrame:screenFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    let view = self.view;
    [view addGestureRecognizer:self.leftEdgeGestureRecognizer];
    [view addGestureRecognizer:self.rightEdgeGestureRecognizer];

    [self ii_exchangeViewFromController:nil toController:self.centerViewController inContainerView:self.view];
}



#pragma mark - Custom Accessors

- (void)setPanningEnabled:(BOOL)panningEnabled {
    _flags.isPanningEnabled = panningEnabled;
    [self updateSideGestureRecognizer];
}

- (BOOL)isPanningEnabled {
    return _flags.isPanningEnabled;
}



#pragma mark - Child Controller Lifecycle

- (nullable UITraitCollection *)overrideTraitCollectionForChildViewController:(UIViewController *)childViewController {
    if (childViewController == _leftViewController || childViewController == _rightViewController) {
        UITraitCollection *traitCollection = [super overrideTraitCollectionForChildViewController:childViewController];
        UITraitCollection *forcedTraits = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
        return [UITraitCollection traitCollectionWithTraitsFromCollections:(traitCollection ? @[traitCollection, forcedTraits] : @[forcedTraits])];
    } else {
        return [super overrideTraitCollectionForChildViewController:childViewController];
    }
}

- (void)setCenterViewController:(UIViewController *)centerViewController {
    if (_centerViewController && _centerViewController == centerViewController) {
        return;
    }
    
    let oldViewController = _centerViewController;
    _centerViewController = centerViewController;

    [self ii_exchangeViewController:oldViewController withViewController:centerViewController viewTransition:^{
        [self ii_exchangeViewFromController:oldViewController toController:centerViewController inContainerView:self.view];
    }];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setLeftViewController:(nullable UIViewController *)leftViewController {
    if (_leftViewController && _leftViewController == leftViewController) {
        return;
    }
    NSAssert(_leftViewController == nil || self.openSide != IIViewDeckSideLeft, @"You can not exchange a side view controller while it is being presented.");
    let oldViewController = _leftViewController;
    _leftViewController = leftViewController;

    [self ii_exchangeViewController:oldViewController withViewController:leftViewController viewTransition:NULL];

    [self updateSideGestureRecognizer];
}

- (void)setRightViewController:(nullable UIViewController *)rightViewController {
    if (_rightViewController && _rightViewController == rightViewController) {
        return;
    }
    NSAssert(_rightViewController == nil || self.openSide != IIViewDeckSideRight, @"You can not exchange a side view controller while it is being presented.");
    let oldViewController = _rightViewController;
    _rightViewController = rightViewController;

    [self ii_exchangeViewController:oldViewController withViewController:rightViewController viewTransition:NULL];

    [self updateSideGestureRecognizer];
}



#pragma mark - Managing Transitions

static inline BOOL IIIsAllowedTransition(IIViewDeckSide fromSide, IIViewDeckSide toSide) {
    return (fromSide == toSide) || (IIViewDeckSideIsValid(fromSide) && !IIViewDeckSideIsValid(toSide)) || (!IIViewDeckSideIsValid(fromSide) && IIViewDeckSideIsValid(toSide));
}

- (void)setOpenSide:(IIViewDeckSide)openSide {
    [self openSide:openSide animated:NO];
}

- (void)openSide:(IIViewDeckSide)side animated:(BOOL)animated {
    [self openSide:side animated:animated notify:NO completion:NULL];
}

- (void)openSide:(IIViewDeckSide)side animated:(BOOL)animated notify:(BOOL)notify completion:(nullable void(^)(BOOL cancelled))completion {
    if (side == _openSide) {
        return;
    }
    NSAssert(self->_flags.isInSideChange == NO, @"A side change is currently taking place. You can not switch the side while already transitioning from or to a side.");
    NSAssert(IIIsAllowedTransition(_openSide, side), @"Open and close transitions are only allowed between a side and the center. You can not transition straight from one side to another side.");

    self->_flags.isInSideChange = YES;

    IIViewDeckSide oldSide = _openSide;

    BOOL shouldContinue = YES;
    if (notify) {
        if (oldSide == IIViewDeckSideNone) {
            shouldContinue = [[(id)self.delegateProxy copyThatDefaultsToYES] viewDeckController:self willOpenSide:side];
        } else {
            shouldContinue = [[(id)self.delegateProxy copyThatDefaultsToYES] viewDeckController:self willCloseSide:oldSide];
        }
    }
    if (!shouldContinue) {
        if (completion) {
            completion(YES);
        }
        self->_flags.isInSideChange = NO;
        return;
    }

    void(^innerComplete)(BOOL) = ^(BOOL cancelled){
        self.currentTransition = nil;
        if (cancelled) {
            self->_openSide = oldSide;
        } else {
            self->_openSide = side;
            NSAssert(IIIsAllowedTransition(oldSide, self->_openSide), @"A transition has taken place that is unexpected and unsupported. We are probably in an invalid state right now.");
        }

        [self updateSideGestureRecognizer];

        if (completion) { completion(cancelled); }

        if (notify) {
            if (cancelled) {
                if (oldSide == IIViewDeckSideNone) {
                    [self.delegateProxy viewDeckController:self didCloseSide:side];
                } else {
                    [self.delegateProxy viewDeckController:self didOpenSide:oldSide];
                }
            } else {
                if (oldSide == IIViewDeckSideNone) {
                    [self.delegateProxy viewDeckController:self didOpenSide:side];
                } else {
                    [self.delegateProxy viewDeckController:self didCloseSide:oldSide];
                }
            }
        }
        
        self->_flags.isInSideChange = NO;
    };
    if (side != IIViewDeckSideNone) {
        // If we are closing, the current side is still visible until it is fully closed,
        // so in this case the state change is only done *after* the closing completes.
        // If we however are currently opening a side, this side is visible from the
        // first moment on, therefore we change the state immediately.
        _openSide = side;
    }

    if (let recognizer = self.currentInteractiveGesture) {
        let transition = [[IIViewDeckTransition alloc] initWithViewDeckController:self from:oldSide to:side];
        self.currentTransition = transition;
        transition.completionHandler = innerComplete;
        [transition beginInteractiveTransition:recognizer];
    } else {
        let transition = [[IIViewDeckTransition alloc] initWithViewDeckController:self from:oldSide to:side];
        self.currentTransition = transition;
        transition.completionHandler = innerComplete;
        [transition performTransition:animated];
    }
}

- (void)closeSide:(BOOL)animated {
    [self closeSide:animated notify:NO completion:NULL];
}

- (void)closeSide:(BOOL)animated notify:(BOOL)notify completion:(nullable void(^)(BOOL cancelled))completion {
    [self openSide:IIViewDeckSideNone animated:animated notify:notify completion:completion];
}



#pragma mark - Interactive Transitioning

- (UIScreenEdgePanGestureRecognizer *)_screenEdgeGestureRecognizerWithEdges:(UIRectEdge)edges {
    let recognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(interactiveTransitionRecognized:)];
    recognizer.edges = edges;
    recognizer.delegate = self;
    if (self.isViewLoaded) {
        [self.view addGestureRecognizer:recognizer];
    }
    return recognizer;
}

- (UIScreenEdgePanGestureRecognizer *)leftEdgeGestureRecognizer {
    if (_leftEdgeGestureRecognizer) {
        return _leftEdgeGestureRecognizer;
    }

    _leftEdgeGestureRecognizer = [self _screenEdgeGestureRecognizerWithEdges:UIRectEdgeLeft];
    return _leftEdgeGestureRecognizer;
}

- (UIScreenEdgePanGestureRecognizer *)rightEdgeGestureRecognizer {
    if (_rightEdgeGestureRecognizer) {
        return _rightEdgeGestureRecognizer;
    }

    _rightEdgeGestureRecognizer = [self _screenEdgeGestureRecognizerWithEdges:UIRectEdgeRight];
    return _rightEdgeGestureRecognizer;
}

- (UITapGestureRecognizer *)decorationTapGestureRecognizer {
    if (_decorationTapGestureRecognizer) {
        return _decorationTapGestureRecognizer;
    }

    let recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeGestureRecognized:)];
    _decorationTapGestureRecognizer = recognizer;
    return _decorationTapGestureRecognizer;
}

- (void)interactiveTransitionRecognized:(UIGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSParameterAssert(!self.currentInteractiveGesture);
            self.currentInteractiveGesture = recognizer;

            IIViewDeckSide side = IIViewDeckSideNone;
            if (recognizer == self.leftEdgeGestureRecognizer) {
                side = IIViewDeckSideLeft;
            } else if (recognizer == self.rightEdgeGestureRecognizer) {
                side = IIViewDeckSideRight;
            } else {
                NSAssert(NO, @"A gesture recognizer (%@) triggered an interactive view transition that is not controlled by this istance of %@, (%@).", recognizer, NSStringFromClass(self.class), self);
                return;
            }

            [self openSide:side animated:YES notify:YES completion:^(BOOL cancelled){
                // cancel gesture recognizer:
                if (cancelled) {
                    BOOL recognizerState = recognizer.enabled;
                    recognizer.enabled = NO;
                    recognizer.enabled = recognizerState;
                }
                self.currentInteractiveGesture = nil;
            }];
        } break;
        case UIGestureRecognizerStateChanged: {
            NSParameterAssert(recognizer == self.currentInteractiveGesture);
            [self.currentTransition updateInteractiveTransition:recognizer];
        } break;
        case UIGestureRecognizerStateCancelled: {
            NSParameterAssert(recognizer == self.currentInteractiveGesture);
            [self.currentTransition endInteractiveTransition:recognizer];
        } break;
        case UIGestureRecognizerStateEnded: {
            NSParameterAssert(recognizer == self.currentInteractiveGesture);
            [self.currentTransition endInteractiveTransition:recognizer];
        } break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}

- (void)closeGestureRecognized:(UIGestureRecognizer *)recognizer {
    [self closeSide:YES notify:YES completion:NULL];
}

- (void)updateSideGestureRecognizer {
    BOOL panningEnabled = self.isPanningEnabled;
    self.leftEdgeGestureRecognizer.enabled = (panningEnabled && self.leftViewController && self.openSide == IIViewDeckSideNone);
    self.rightEdgeGestureRecognizer.enabled = (panningEnabled && self.rightViewController && self.openSide == IIViewDeckSideNone);
    self.decorationTapGestureRecognizer.enabled = (self.openSide != IIViewDeckSideNone);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![self.delegate respondsToSelector:@selector(viewDeckController:shouldStartPanningToSide:)]) {
        // default value if delegate is not implemented
        return YES;
    }

    IIViewDeckSide side = IIViewDeckSideNone;
    if (gestureRecognizer == self.leftEdgeGestureRecognizer) {
        side = IIViewDeckSideLeft;
    } else if (gestureRecognizer == self.rightEdgeGestureRecognizer) {
        side = IIViewDeckSideRight;
    }
    return [self.delegate viewDeckController:self shouldStartPanningToSide:side];
}



#pragma mark - Customizing Transitions

- (id<IIViewDeckTransitionAnimator>)animatorForTransitionWithContext:(id<IIViewDeckTransitionContext>)context {
    return [IIViewDeckDefaultTransitionAnimator new];
}

- (nullable UIView *)decorationViewForTransitionWithContext:(id<IIViewDeckTransitionContext>)context {
    if (let decorationView = self.currentDecorationView) {
        return decorationView;
    }

    let decorationView = [[UIView alloc] initWithFrame:self.view.bounds];
    decorationView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    [decorationView addGestureRecognizer:self.decorationTapGestureRecognizer];
    self.currentDecorationView = decorationView;
    return decorationView;
}

@end

NS_ASSUME_NONNULL_END
