//
//  IIViewDeckController.m
//  IIViewDeck
//
//  Copyright (C) 2011, Tom Adriaenssen
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


#import "IIViewDeckController.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#define DURATION_FAST 0.3
#define DURATION_SLOW 0.3
#define SLIDE_DURATION(animated,duration) ((animated) ? (duration) : 0)
#define OPEN_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_FAST)
#define CLOSE_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_SLOW)

@interface IIViewDeckController () <UIGestureRecognizerDelegate> {
    CGFloat _panOrigin;
    BOOL _viewAppeared;
}

@property (nonatomic, retain) UIView* referenceView;
@property (nonatomic, readonly) CGRect referenceBounds;
@property (nonatomic, retain) UIPanGestureRecognizer* panner;
@property (nonatomic, assign) CGFloat originalShadowRadius;
@property (nonatomic, assign) CGFloat originalShadowOpacity;
@property (nonatomic, retain) UIColor* originalShadowColor;
@property (nonatomic, assign) CGSize originalShadowOffset;
@property (nonatomic, retain) UIBezierPath* originalShadowPath;

- (void)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;
- (void)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;
- (void)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;
- (void)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options;

- (CGRect)slidingRectForOffset:(CGFloat)offset;
- (CGSize)slidingSizeForOffset:(CGFloat)offset;

- (void)setSlidingAndReferenceViews;
- (void)applyShadowToSlidingView;
- (void)restoreShadowToSlidingView;

- (void)addPanner;
- (void)removePanner;

@end 

@interface UIViewController (UIViewDeckItem_Internal) 

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController;

@end

@implementation IIViewDeckController

@synthesize panningMode = _panningMode;
@synthesize panner = _panner;
@synthesize referenceView = _referenceView;
@synthesize slidingController = _slidingController;
@synthesize centerController = _centerController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;
@synthesize leftLedge = _leftLedge;
@synthesize rightLedge = _rightLedge;
@synthesize resizesCenterView = _resizesCenterView;
@synthesize leftGap = _leftMargin;
@synthesize rightGap = _rightMargin;
@synthesize originalShadowOpacity = _originalShadowOpacity;
@synthesize originalShadowPath = _originalShadowPath;
@synthesize originalShadowRadius = _originalShadowRadius;
@synthesize originalShadowColor = _originalShadowColor;
@synthesize originalShadowOffset = _originalShadowOffset;

#pragma mark - Initalisation and deallocation

- (id)initWithCenterViewController:(UIViewController*)centerController {
    if ((self = [super init])) {
        self.centerController = centerController;
        [self.centerController setViewDeckController:self];
        _slidingController = nil;
        self.leftController = nil;
        self.rightController = nil;
        self.leftLedge = 44;
        self.rightLedge = 44;
        self.leftGap = 0;
        self.rightGap = 0;
        _panningMode = IIViewDeckFullViewPanning;
        _viewAppeared = NO;
        _resizesCenterView = NO;

        self.originalShadowRadius = 0;
        self.originalShadowOffset = CGSizeZero;
        self.originalShadowColor = nil;
        self.originalShadowOpacity = 0;
        self.originalShadowPath = nil;
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
    _slidingController = nil;
    self.referenceView = nil;
    self.centerController.viewDeckController = nil;
    self.centerController = nil;
    self.leftController.viewDeckController = nil;
    self.leftController = nil;
    self.rightController.viewDeckController = nil;
    self.rightController = nil;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.centerController didReceiveMemoryWarning];
    [self.leftController didReceiveMemoryWarning];
    [self.rightController didReceiveMemoryWarning];
}

#pragma mark - Bookkeeping

- (CGRect)referenceBounds {
    return self.referenceView.bounds;
}

- (CGRect)slidingRectForOffset:(CGFloat)offset {
    return (CGRect) { self.resizesCenterView && offset < 0 ? 0 : offset, 0, [self slidingSizeForOffset:offset] };
}

- (CGSize)slidingSizeForOffset:(CGFloat)offset {
    if (!self.resizesCenterView || offset == 0) return self.referenceBounds.size;
    
    if (offset < 0) 
        return (CGSize) { self.referenceBounds.size.width + offset, self.referenceBounds.size.height };

    return (CGSize) { self.referenceBounds.size.width - offset, self.referenceBounds.size.height };
}

#pragma mark - ledges

- (void)setLeftLedge:(CGFloat)leftLedge {
    leftLedge = MAX(leftLedge, MIN(self.referenceBounds.size.width, leftLedge));
    if (_viewAppeared && self.slidingController.view.frame.origin.x == self.referenceBounds.size.width - _leftLedge) {
        if (leftLedge < _leftLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                self.slidingController.view.frame = [self slidingRectForOffset:self.referenceBounds.size.width - leftLedge];
            }];
        }
        else if (leftLedge > _leftLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                self.slidingController.view.frame = [self slidingRectForOffset:self.referenceBounds.size.width - leftLedge];
            }];
        }
    }
    _leftLedge = leftLedge;
}

- (void)setRightLedge:(CGFloat)rightLedge {
    rightLedge = MAX(rightLedge, MIN(self.referenceBounds.size.width, rightLedge));
    if (_viewAppeared && self.slidingController.view.frame.origin.x == _rightLedge - self.referenceBounds.size.width) {
        if (rightLedge < _rightLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                self.slidingController.view.frame = [self slidingRectForOffset:rightLedge - self.referenceBounds.size.width];
            }];
        }
        else if (rightLedge > _rightLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                self.slidingController.view.frame = [self slidingRectForOffset:rightLedge - self.referenceBounds.size.width];
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

    self.originalShadowRadius = 0;
    self.originalShadowOpacity = 0;
    self.originalShadowColor = nil;
    self.originalShadowOffset = CGSizeZero;
    self.originalShadowPath = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [self restoreShadowToSlidingView];
    
    self.originalShadowRadius = 0;
    self.originalShadowOpacity = 0;
    self.originalShadowColor = nil;
    self.originalShadowOffset = CGSizeZero;
    self.originalShadowPath = nil;

    _slidingController = nil;
    self.referenceView = nil;
    [self.centerController.view removeFromSuperview];
    [self.leftController.view removeFromSuperview];
    [self.rightController.view removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setSlidingAndReferenceViews];

    [self.centerController.view removeFromSuperview];
    [self.view addSubview:self.centerController.view];
    [self.leftController.view removeFromSuperview];
    [self.referenceView insertSubview:self.leftController.view belowSubview:self.slidingController.view];
    [self.rightController.view removeFromSuperview];
    [self.referenceView insertSubview:self.rightController.view belowSubview:self.slidingController.view];

    self.slidingController.view.frame = self.referenceBounds;
    self.slidingController.view.hidden = NO;
    self.leftController.view.frame = self.referenceBounds;
    self.leftController.view.hidden = YES;
    self.rightController.view.frame = self.referenceBounds;
    self.rightController.view.hidden = YES;

    [self applyShadowToSlidingView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewAppeared = YES;
    self.panningMode = self.panningMode;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.slidingController.view removeGestureRecognizer:self.panner];
    self.panner = nil;
    
    [self closeLeftView];
    [self closeRightView];
    
    _viewAppeared = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.centerController.view removeFromSuperview];
    [self.leftController.view removeFromSuperview];
    [self.rightController.view removeFromSuperview];

    _viewAppeared = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.centerController)
        return [self.centerController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    return YES;
}

- (BOOL)leftControllerIsClosed {
    return !self.leftController || CGRectGetMinX(self.slidingController.view.frame) <= self.leftGap;
}

- (BOOL)rightControllerIsClosed {
    return !self.rightController || CGRectGetMaxX(self.slidingController.view.frame) >= self.referenceBounds.size.width-self.rightGap;
}

- (void)showCenterView {
    [self showCenterView:YES];
}

- (void)showCenterView:(BOOL)animated {
    if (!self.leftController.view.hidden) 
        [self closeLeftViewAnimated:animated];
    if (!self.rightController.view.hidden) 
        [self closeRightViewAnimated:animated];
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
    if ([self leftControllerIsClosed]) 
        [self openLeftViewAnimated:animated];
    else
        [self closeLeftViewAnimated:animated];
}

- (void)openLeftViewAnimated:(BOOL)animated {
    [self openLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    if (!self.leftController || CGRectGetMinX(self.slidingController.view.frame) == self.leftLedge) return;

    [self closeRightViewAnimated:animated options:options];
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.leftController.view.hidden = NO;
        self.slidingController.view.frame = [self slidingRectForOffset:self.referenceBounds.size.width - self.leftLedge];
    } completion:^(BOOL finished) {
    }];
}

- (void)closeLeftViewAnimated:(BOOL)animated {
    [self closeLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    if (self.leftControllerIsClosed) return;
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingController.view.frame = [self slidingRectForOffset:0];
    } completion:^(BOOL finished) {
        self.leftController.view.hidden = YES;
    }];
}

- (void)closeLeftViewBouncing:(void(^)(IIViewDeckController* controller))bounced {
    if (self.leftControllerIsClosed) return;
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingController.view.frame = [self slidingRectForOffset:self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        if (bounced) {
            bounced(self);
        }
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            self.slidingController.view.frame = [self slidingRectForOffset:0];
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
    if ([self rightControllerIsClosed]) 
        [self openRightViewAnimated:animated];
    else
        [self closeRightViewAnimated:animated];
}

- (void)openRightViewAnimated:(BOOL)animated {
    [self openRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    if (!self.rightController || CGRectGetMaxX(self.slidingController.view.frame) == self.rightLedge) return;

    [self closeLeftViewAnimated:animated options:options];
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.rightController.view.hidden = NO;
        self.slidingController.view.frame = [self slidingRectForOffset:self.rightLedge - self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
    }];
}

- (void)closeRightViewAnimated:(BOOL)animated {
    [self closeRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut];
}

- (void)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options {
    if (self.rightControllerIsClosed) return;
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingController.view.frame = [self slidingRectForOffset:0];
    } completion:^(BOOL finished) {
        self.rightController.view.hidden = YES;
    }];
}

- (void)closeRightViewBouncing:(void(^)(IIViewDeckController* controller))bounced {
    if (self.rightControllerIsClosed) return;
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingController.view.frame = [self slidingRectForOffset:-self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        if (bounced) {
            bounced(self);
        }
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            self.slidingController.view.frame = [self slidingRectForOffset:0];
        } completion:^(BOOL finished) {
            self.rightController.view.hidden = YES;
        }];
    }];
}


#pragma mark - Panning

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    _panOrigin = self.slidingController.view.frame.origin.x;
    return YES;
}

- (void)panned:(UIPanGestureRecognizer*)panner {
    CGPoint pan = [panner translationInView:self.referenceView];
    
    // restarts
    CGFloat x = pan.x + _panOrigin;
    
    if (!self.leftController) x = MIN(0, x);
    if (!self.rightController) x = MAX(0, x);

    x = MAX(x, -self.referenceBounds.size.width+self.rightLedge);
    x = MIN(x, self.referenceBounds.size.width-self.leftLedge);
    self.slidingController.view.frame = [self slidingRectForOffset:x];

    self.rightController.view.hidden = x > 0;
    self.leftController.view.hidden = x < 0;
    
    if (panner.state == UIGestureRecognizerStateEnded) {
        if ([panner velocityInView:self.referenceView].x > 0) {
            if (x > (self.referenceBounds.size.width-self.leftLedge)/3.0) 
                [self openLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut];
            else 
                [self showCenterView:YES];
        }
        else if ([panner velocityInView:self.referenceView].x < 0) {
            if (x < -(self.referenceBounds.size.width-self.rightLedge)/3.0) 
                [self openRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut];
            else 
                [self showCenterView:YES];
        }
    }
}


- (void)addPanner {
    switch (_panningMode) {
        case IIViewDeckNoPanning: 
            break;
            
        case IIViewDeckFullViewPanning:
            self.panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
            self.panner.delegate = self;
            [self.slidingController.view addGestureRecognizer:self.panner];
            break;
            
        case IIViewDeckNavigationBarPanning:
            if (self.navigationController) {
                self.panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
                self.panner.delegate = self;
                [self.navigationController.navigationBar addGestureRecognizer:self.panner];
            }
            break;
    }
}


- (void)removePanner {
    if (!self.panner) 
        return;
    
    [self.slidingController.view removeGestureRecognizer:self.panner];
    [self.navigationController.navigationBar removeGestureRecognizer:self.panner];
    self.panner = nil;
}



#pragma mark - Properties

- (void)setPanningMode:(IIViewDeckPanningMode)panningMode {
    _panningMode = panningMode;
    if (_viewAppeared) {
        [self removePanner];
        [self addPanner];
    }
}

- (void)setLeftController:(UIViewController *)leftController {
    if (!_viewAppeared) {
        _leftController = leftController;
        return;
    }

    if (_leftController == leftController) return;
    
    if (_leftController) {
        [_leftController.view removeFromSuperview];
        _leftController.viewDeckController = nil;
    }
    
    if (leftController) {
        if (leftController == self.centerController) self.centerController = nil;
        if (leftController == self.rightController) self.rightController = nil;
        leftController.viewDeckController = self;
        
        if (self.slidingController)
            [self.referenceView insertSubview:leftController.view belowSubview:self.slidingController.view];
        else
            [self.referenceView addSubview:leftController.view];
        leftController.view.hidden = self.slidingController.view.frame.origin.x <= 0;
        leftController.view.frame = self.referenceBounds;
    }
    _leftController = leftController;
}

- (void)setCenterController:(UIViewController *)centerController {
    if (!_viewAppeared) {
        _centerController = centerController;
        return;
    }

    if (_centerController == centerController) return;
    
    [self removePanner];
    CGRect currentFrame = self.referenceBounds;
    if (_centerController) {
        [self restoreShadowToSlidingView];
        currentFrame = _centerController.view.frame;
        [_centerController.view removeFromSuperview];
        _centerController.viewDeckController = nil;
        _centerController = nil;
    }
    
    if (centerController) {
        if (centerController == self.leftController) self.leftController = nil;
        if (centerController == self.rightController) self.rightController = nil;
        centerController.viewDeckController = self;
        _centerController = centerController;
        [self setSlidingAndReferenceViews];
        [self.view addSubview:centerController.view];
        centerController.view.frame = currentFrame;
        centerController.view.hidden = NO;
        [self addPanner];
        [self applyShadowToSlidingView];
    }
    else {
        _centerController = centerController;
    }
}

- (void)setRightController:(UIViewController *)rightController {
    if (!_viewAppeared) {
        _rightController = rightController;
        return;
    }

    if (_rightController == rightController) return;
    
    if (_rightController) {
        [_rightController.view removeFromSuperview];
        _rightController.viewDeckController = nil;
    }
    
    if (rightController) {
        if (rightController == self.centerController) self.centerController = nil;
        if (rightController == self.leftController) self.leftController = nil;
        
        rightController.viewDeckController = self;
        if (self.slidingController) 
            [self.referenceView insertSubview:rightController.view belowSubview:self.slidingController.view];
        else
            [self.referenceView addSubview:rightController.view];
        rightController.view.hidden = self.slidingController.view.frame.origin.x >= 0;
        rightController.view.frame = self.referenceBounds;
    }
    _rightController = rightController;
}

- (void)setSlidingAndReferenceViews {
    if (self.navigationController) {
        _slidingController = self.navigationController;
        self.referenceView = [self.navigationController.view superview];
    }
    else {
        _slidingController = self.centerController;
        self.referenceView = self.view;
    }
}

#pragma mark - Shadow

- (void)restoreShadowToSlidingView {
    if (!self.slidingController.view) return;

    self.slidingController.view.layer.shadowRadius = self.originalShadowRadius;
    self.slidingController.view.layer.shadowOpacity = self.originalShadowOpacity;
    self.slidingController.view.layer.shadowColor = [self.originalShadowColor CGColor]; 
    self.slidingController.view.layer.shadowOffset = self.originalShadowOffset;
    self.slidingController.view.layer.shadowPath = [self.originalShadowPath CGPath];
}

- (void)applyShadowToSlidingView {
    if (!self.slidingController.view) return;
    
    self.originalShadowRadius = self.slidingController.view.layer.shadowRadius;
    self.originalShadowOpacity = self.slidingController.view.layer.shadowOpacity;
    self.originalShadowColor = self.slidingController.view.layer.shadowColor ? [UIColor colorWithCGColor:self.slidingController.view.layer.shadowColor] : nil;
    self.originalShadowOffset = self.slidingController.view.layer.shadowOffset;
    self.originalShadowPath = self.slidingController.view.layer.shadowPath ? [UIBezierPath bezierPathWithCGPath:self.slidingController.view.layer.shadowPath] : nil;
    
    self.slidingController.view.layer.masksToBounds = NO;
    self.slidingController.view.layer.shadowRadius = 10;
    self.slidingController.view.layer.shadowOpacity = 0.5;
    self.slidingController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.slidingController.view.layer.shadowOffset = CGSizeZero;
    self.slidingController.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.referenceBounds] CGPath];
}


@end

#pragma mark -

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

