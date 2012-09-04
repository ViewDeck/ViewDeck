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

// define some LLVM3 macros if the code is compiled with a different compiler (ie LLVMGCC42)
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define II_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

#if II_ARC_ENABLED
#define II_RETAIN(xx)  ((void)(0))
#define II_RELEASE(xx)  ((void)(0))
#define II_AUTORELEASE(xx)  (xx)
#else
#define II_RETAIN(xx)           [xx retain]
#define II_RELEASE(xx)          [xx release]
#define II_AUTORELEASE(xx)      [xx autorelease]
#endif

#define II_FLOAT_EQUAL(x, y) (((x) - (y)) == 0.0f)
#define II_STRING_EQUAL(a, b) ((a == nil && b == nil) || (a != nil && [a isEqualToString:b]))

#define II_CGRectOffsetRightAndShrink(rect, offset)         \
({                                                        \
__typeof__(rect) __r = (rect);                          \
__typeof__(offset) __o = (offset);                      \
(CGRect) {  { __r.origin.x, __r.origin.y },            \
{ __r.size.width - __o, __r.size.height }  \
};                                            \
})
#define II_CGRectOffsetTopAndShrink(rect, offset)           \
({                                                        \
__typeof__(rect) __r = (rect);                          \
__typeof__(offset) __o = (offset);                      \
(CGRect) { { __r.origin.x,   __r.origin.y    + __o },   \
{ __r.size.width, __r.size.height - __o }    \
};                                             \
})
#define II_CGRectOffsetBottomAndShrink(rect, offset)        \
({                                                        \
__typeof__(rect) __r = (rect);                          \
__typeof__(offset) __o = (offset);                      \
(CGRect) { { __r.origin.x, __r.origin.y },              \
{ __r.size.width, __r.size.height - __o}     \
};                                             \
})
#define II_CGRectShrink(rect, w, h)                             \
({                                                            \
__typeof__(rect) __r = (rect);                              \
__typeof__(w) __w = (w);                                    \
__typeof__(h) __h = (h);                                    \
(CGRect) {  __r.origin,                                     \
{ __r.size.width - __w, __r.size.height - __h}   \
};                                                 \
})

#import "IIViewDeckController.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>
#import "WrapController.h"

#define DURATION_FAST 0.3
#define DURATION_SLOW 0.3
#define SLIDE_DURATION(animated,duration) ((animated) ? (duration) : 0)
#define OPEN_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_FAST)
#define CLOSE_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_SLOW)

@interface IIViewDeckController () <UIGestureRecognizerDelegate>


@property (nonatomic, retain) UIView* referenceView;
@property (nonatomic, readonly) CGRect referenceBounds;
@property (nonatomic, readonly) CGRect centerViewBounds;
@property (nonatomic, readonly) CGRect sideViewBounds;
@property (nonatomic, retain) NSMutableArray* panners;
@property (nonatomic, assign) CGFloat originalShadowRadius;
@property (nonatomic, assign) CGFloat originalShadowOpacity;
@property (nonatomic, retain) UIColor* originalShadowColor;
@property (nonatomic, assign) CGSize originalShadowOffset;
@property (nonatomic, retain) UIBezierPath* originalShadowPath;
@property (nonatomic, retain) UIButton* centerTapper;
@property (nonatomic, retain) UIView* centerView;
@property (nonatomic, readonly) UIView* slidingControllerView;

- (void)cleanup;

- (BOOL)closeLeftViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;

- (CGRect)slidingRectForOffset:(CGFloat)offset;
- (CGSize)slidingSizeForOffset:(CGFloat)offset;
- (void)setSlidingFrameForOffset:(CGFloat)frame;
- (void)hideAppropriateSideViews;

- (void)reapplySideController:(__strong UIViewController **)controllerStore;
- (BOOL)setSlidingAndReferenceViews;
- (void)applyShadowToSlidingView;
- (void)restoreShadowToSlidingView;
- (void)arrangeViewsAfterRotation;
- (CGFloat)relativeStatusBarHeight;

- (void)centerViewVisible;
- (void)centerViewHidden;
- (void)centerTapped;

- (void)addPanners;
- (void)removePanners;

- (BOOL)checkDelegate:(SEL)selector animated:(BOOL)animated;
- (void)performDelegate:(SEL)selector animated:(BOOL)animated;
- (void)performOffsetDelegate:(SEL)selector offset:(CGFloat)offset;

- (void)relayAppearanceMethod:(void(^)(UIViewController* controller))relay;
- (void)relayAppearanceMethod:(void(^)(UIViewController* controller))relay forced:(BOOL)forced;

@end 


@interface UIViewController (UIViewDeckItem_Internal) 

// internal setter for the viewDeckController property on UIViewController
- (void)setViewDeckController:(IIViewDeckController*)viewDeckController;

@end

@interface UIViewController (UIViewDeckController_ViewContainmentEmulation) 

- (void)addChildViewController:(UIViewController *)childController;
- (void)removeFromParentViewController;
- (void)willMoveToParentViewController:(UIViewController *)parent;
- (void)didMoveToParentViewController:(UIViewController *)parent;

- (BOOL)vdc_shouldRelay;
- (void)vdc_viewWillAppear:(bool)animated;
- (void)vdc_viewDidAppear:(bool)animated;
- (void)vdc_viewWillDisappear:(bool)animated;
- (void)vdc_viewDidDisappear:(bool)animated;

@end


@implementation IIViewDeckController

@synthesize panningMode = _panningMode;
@synthesize panners = _panners;
@synthesize referenceView = _referenceView;
@synthesize slidingController = _slidingController;
@synthesize centerController = _centerController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;
@synthesize leftLedge = _leftLedge;
@synthesize rightLedge = _rightLedge;
@synthesize maxLedge = _maxLedge;
@synthesize resizesCenterView = _resizesCenterView;
@synthesize originalShadowOpacity = _originalShadowOpacity;
@synthesize originalShadowPath = _originalShadowPath;
@synthesize originalShadowRadius = _originalShadowRadius;
@synthesize originalShadowColor = _originalShadowColor;
@synthesize originalShadowOffset = _originalShadowOffset;
@synthesize delegate = _delegate;
@synthesize navigationControllerBehavior = _navigationControllerBehavior;
@synthesize panningView = _panningView; 
@synthesize centerhiddenInteractivity = _centerhiddenInteractivity;
@synthesize centerTapper = _centerTapper;
@synthesize centerView = _centerView;
@synthesize rotationBehavior = _rotationBehavior;
@synthesize enabled = _enabled;
@synthesize elastic = _elastic;
@synthesize automaticallyUpdateTabBarItems = _automaticallyUpdateTabBarItems;
@synthesize panningGestureDelegate = _panningGestureDelegate;

#pragma mark - Initalisation and deallocation

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithCenterViewController:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithCenterViewController:nil];
}

- (id)initWithCenterViewController:(UIViewController*)centerController {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _elastic = YES;
        _panningMode = IIViewDeckFullViewPanning;
        _navigationControllerBehavior = IIViewDeckNavigationControllerContained;
        _centerhiddenInteractivity = IIViewDeckCenterHiddenUserInteractive;
        _rotationBehavior = IIViewDeckRotationKeepsLedgeSizes;
        _viewAppeared = NO;
        _resizesCenterView = NO;
        _automaticallyUpdateTabBarItems = NO;
        self.panners = [NSMutableArray array];
        self.enabled = YES;
        
        self.originalShadowRadius = 0;
        self.originalShadowOffset = CGSizeZero;
        self.originalShadowColor = nil;
        self.originalShadowOpacity = 0;
        self.originalShadowPath = nil;
        
        _slidingController = nil;
        self.centerController = centerController;
        self.leftController = nil;
        self.rightController = nil;
        self.leftLedge = 44;
        self.rightLedge = 44;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.leftController = leftController;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController rightViewController:(UIViewController*)rightController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.rightController = rightController;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.leftController = leftController;
        self.rightController = rightController;
    }
    return self;
}

- (void)cleanup {
    self.originalShadowRadius = 0;
    self.originalShadowOpacity = 0;
    self.originalShadowColor = nil;
    self.originalShadowOffset = CGSizeZero;
    self.originalShadowPath = nil;
    
    _slidingController = nil;
    self.referenceView = nil;
    self.centerView = nil;
    self.centerTapper = nil;
}

- (void)dealloc {
    [self cleanup];
    
    self.centerController.viewDeckController = nil;
    self.centerController = nil;
    self.leftController.viewDeckController = nil;
    self.leftController = nil;
    self.rightController.viewDeckController = nil;
    self.rightController = nil;
    self.panners = nil;
    
#if !II_ARC_ENABLED
    [super dealloc];
#endif
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

- (NSArray*)controllers {
    NSMutableArray *result = [NSMutableArray array];
    if (self.centerController) [result addObject:self.centerController];
    if (self.leftController) [result addObject:self.leftController];
    if (self.rightController) [result addObject:self.rightController];
    return [NSArray arrayWithArray:result];
}

- (CGRect)referenceBounds {
    return self.referenceView.bounds;
}

- (CGFloat)relativeStatusBarHeight {
    if (![self.referenceView isKindOfClass:[UIWindow class]]) 
        return 0;
    
    return [self statusBarHeight];
}

- (CGFloat)statusBarHeight {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) 
    ? [UIApplication sharedApplication].statusBarFrame.size.width 
    : [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGRect)centerViewBounds {
    if (self.navigationControllerBehavior == IIViewDeckNavigationControllerContained)
        return self.referenceBounds;
    
    return II_CGRectShrink(self.referenceBounds, 0, [self relativeStatusBarHeight] + (self.navigationController.navigationBarHidden ? 0 : self.navigationController.navigationBar.frame.size.height));
}

- (CGRect)sideViewBounds {
    if (self.navigationControllerBehavior == IIViewDeckNavigationControllerContained)
        return self.referenceBounds;
    
    return II_CGRectOffsetTopAndShrink(self.referenceBounds, [self relativeStatusBarHeight]);
}

- (CGFloat)limitOffset:(CGFloat)offset {
    if (_leftController && _rightController) return offset;
    
    if (_leftController && self.maxLedge > 0) {
        CGFloat left = self.referenceBounds.size.width - self.maxLedge;
        offset = MAX(offset, left);
    }
    else if (_rightController && self.maxLedge > 0) {
        CGFloat right = self.maxLedge - self.referenceBounds.size.width;
        offset = MIN(offset, right);
    }
    
    return offset;
}

- (CGRect)slidingRectForOffset:(CGFloat)offset {
    offset = [self limitOffset:offset];
    return (CGRect) { {self.resizesCenterView && offset < 0 ? 0 : offset, 0}, [self slidingSizeForOffset:offset] };
}

- (CGSize)slidingSizeForOffset:(CGFloat)offset {
    if (!self.resizesCenterView) return self.referenceBounds.size;
    
    offset = [self limitOffset:offset];
    if (offset < 0) 
        return (CGSize) { self.centerViewBounds.size.width + offset, self.centerViewBounds.size.height };
    
    return (CGSize) { self.centerViewBounds.size.width - offset, self.centerViewBounds.size.height };
}

-(void)setSlidingFrameForOffset:(CGFloat)offset {
    _offset = [self limitOffset:offset];
    self.slidingControllerView.frame = [self slidingRectForOffset:_offset];
    [self performOffsetDelegate:@selector(viewDeckController:slideOffsetChanged:) offset:_offset];
}

- (void)hideAppropriateSideViews {
    self.leftController.view.hidden = CGRectGetMinX(self.slidingControllerView.frame) <= 0;
    self.rightController.view.hidden = CGRectGetMaxX(self.slidingControllerView.frame) >= self.referenceBounds.size.width;
}

#pragma mark - ledges

- (void)setLeftLedge:(CGFloat)leftLedge {
    // Compute the final ledge in two steps. This prevents a strange bug where
    // nesting MAX(X, MIN(Y, Z)) with miniscule referenceBounds returns a bogus near-zero value.
    CGFloat minLedge = MIN(self.referenceBounds.size.width, leftLedge);
    leftLedge = MAX(leftLedge, minLedge);
    if (_viewAppeared && II_FLOAT_EQUAL(self.slidingControllerView.frame.origin.x, self.referenceBounds.size.width - _leftLedge)) {
        if (leftLedge < _leftLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:self.referenceBounds.size.width - leftLedge];
            }];
        }
        else if (leftLedge > _leftLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:self.referenceBounds.size.width - leftLedge];
            }];
        }
    }
    _leftLedge = leftLedge;
}

- (void)setLeftLedge:(CGFloat)leftLedge completion:(void(^)(BOOL finished))completion {
    // Compute the final ledge in two steps. This prevents a strange bug where
    // nesting MAX(X, MIN(Y, Z)) with miniscule referenceBounds returns a bogus near-zero value.
    CGFloat minLedge = MIN(self.referenceBounds.size.width, leftLedge);
    leftLedge = MAX(leftLedge, minLedge);
    if (_viewAppeared && II_FLOAT_EQUAL(self.slidingControllerView.frame.origin.x, self.referenceBounds.size.width - _leftLedge)) {
        if (leftLedge < _leftLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:self.referenceBounds.size.width - leftLedge];
            } completion:completion];
        }
        else if (leftLedge > _leftLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:self.referenceBounds.size.width - leftLedge];
            } completion:completion];
        }
    }
    _leftLedge = leftLedge;
}


- (void)setRightLedge:(CGFloat)rightLedge {
    // Compute the final ledge in two steps. This prevents a strange bug where
    // nesting MAX(X, MIN(Y, Z)) with miniscule referenceBounds returns a bogus near-zero value.
    CGFloat minLedge = MIN(self.referenceBounds.size.width, rightLedge);
    rightLedge = MAX(rightLedge, minLedge);
    if (_viewAppeared && II_FLOAT_EQUAL(self.slidingControllerView.frame.origin.x, _rightLedge - self.referenceBounds.size.width)) {
        if (rightLedge < _rightLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:rightLedge - self.referenceBounds.size.width];
            }];
        }
        else if (rightLedge > _rightLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:rightLedge - self.referenceBounds.size.width];
            }];
        }
    }
    _rightLedge = rightLedge;
}

- (void)setRightLedge:(CGFloat)rightLedge completion:(void(^)(BOOL finished))completion {
    // Compute the final ledge in two steps. This prevents a strange bug where
    // nesting MAX(X, MIN(Y, Z)) with miniscule referenceBounds returns a bogus near-zero value.
    CGFloat minLedge = MIN(self.referenceBounds.size.width, rightLedge);
    rightLedge = MAX(rightLedge, minLedge);
    if (_viewAppeared && II_FLOAT_EQUAL(self.slidingControllerView.frame.origin.x, _rightLedge - self.referenceBounds.size.width)) {
        if (rightLedge < _rightLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:rightLedge - self.referenceBounds.size.width];
            } completion:completion];
        }
        else if (rightLedge > _rightLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                [self setSlidingFrameForOffset:rightLedge - self.referenceBounds.size.width];
            } completion:completion];
        }
    }
    _rightLedge = rightLedge;
}


- (void)setMaxLedge:(CGFloat)maxLedge {
    _maxLedge = maxLedge;
    if (_leftController && _rightController) {
        NSLog(@"IIViewDeckController: warning: setting maxLedge with 2 side controllers. Value will be ignored.");
        return;
    }
    
    if (_leftController && _leftLedge > _maxLedge) {
        self.leftLedge = _maxLedge;
    }
    else if (_rightController && _rightLedge > _maxLedge) {
        self.rightLedge = _maxLedge;
    }
    
    [self setSlidingFrameForOffset:_offset];
}

#pragma mark - View lifecycle

- (void)loadView
{
    _offset = 0;
    _viewAppeared = NO;
    self.view = II_AUTORELEASE([[UIView alloc] init]);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.centerView = II_AUTORELEASE([[UIView alloc] init]);
    self.centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.centerView.autoresizesSubviews = YES;
    self.centerView.clipsToBounds = YES;
    [self.view addSubview:self.centerView];
    
    self.originalShadowRadius = 0;
    self.originalShadowOpacity = 0;
    self.originalShadowColor = nil;
    self.originalShadowOffset = CGSizeZero;
    self.originalShadowPath = nil;
}

- (void)viewDidUnload
{
    [self cleanup];
    [super viewDidUnload];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL wasntAppeared = !_viewAppeared;
    [self.view addObserver:self forKeyPath:@"bounds" options:NSKeyValueChangeSetting context:nil];

    void(^applyViews)(void) = ^{        
        [self.centerController.view removeFromSuperview];
        [self.centerView addSubview:self.centerController.view];
        [self.leftController.view removeFromSuperview];
        [self.referenceView insertSubview:self.leftController.view belowSubview:self.slidingControllerView];
        [self.rightController.view removeFromSuperview];
        [self.referenceView insertSubview:self.rightController.view belowSubview:self.slidingControllerView];
        
        [self reapplySideController:&_leftController];
        [self reapplySideController:&_rightController];
        
        [self setSlidingFrameForOffset:_offset];
        self.slidingControllerView.hidden = NO;
        
        self.centerView.frame = self.centerViewBounds;
        self.centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerController.view.frame = self.centerView.bounds;
        self.leftController.view.frame = self.sideViewBounds;
        self.leftController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.rightController.view.frame = self.sideViewBounds;
        self.rightController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self applyShadowToSlidingView];
    };

    if ([self setSlidingAndReferenceViews]) 
        applyViews();
    _viewAppeared = YES;

    // after 0.01 sec, since in certain cases the sliding view is reset.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        if (!self.referenceView) {
            [self setSlidingAndReferenceViews];
            applyViews();
        }
        [self setSlidingFrameForOffset:_offset];
        [self hideAppropriateSideViews];
    });
    
    [self addPanners];
    
    if (self.slidingControllerView.frame.origin.x == 0.0f) 
        [self centerViewVisible];
    else
        [self centerViewHidden];
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller viewWillAppear:animated];
    } forced:wasntAppeared];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller viewDidAppear:animated];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller viewWillDisappear:animated];
    }];
    
    [self removePanners];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    @try {
        [self.view removeObserver:self forKeyPath:@"bounds"];
    } @catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller viewDidDisappear:animated];
    }];
}

#pragma mark - rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _preRotationWidth = self.referenceBounds.size.width;
    _preRotationCenterWidth = self.centerView.bounds.size.width;
    
    if (self.rotationBehavior == IIViewDeckRotationKeepsViewSizes) {
        _leftWidth = self.leftController.view.frame.size.width;
        _rightWidth = self.rightController.view.frame.size.width;
    }
    
    BOOL should = YES;
    if (self.centerController)
        should = [self.centerController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    return should;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }];
    
    [self arrangeViewsAfterRotation];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self restoreShadowToSlidingView];
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self applyShadowToSlidingView];
    
    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }];
}

- (void)arrangeViewsAfterRotation {
    if (_preRotationWidth <= 0) return;
    
    CGFloat offset = self.slidingControllerView.frame.origin.x;
    if (self.resizesCenterView && offset == 0) {
        offset = offset + (_preRotationCenterWidth - _preRotationWidth);
    }
    
    if (self.rotationBehavior == IIViewDeckRotationKeepsLedgeSizes) {
        if (offset > 0) {
            offset = self.referenceBounds.size.width - _preRotationWidth + offset;
        }
        else if (offset < 0) {
            offset = offset + _preRotationWidth - self.referenceBounds.size.width;
        }
    }
    else {
        self.leftLedge = self.leftLedge + self.referenceBounds.size.width - _preRotationWidth; 
        self.rightLedge = self.rightLedge + self.referenceBounds.size.width - _preRotationWidth; 
        self.maxLedge = self.maxLedge + self.referenceBounds.size.width - _preRotationWidth; 
    }
    [self setSlidingFrameForOffset:offset];
    
    _preRotationWidth = 0;
}

#pragma mark - controller state

- (BOOL)leftControllerIsClosed {
    return !self.leftController || CGRectGetMinX(self.slidingControllerView.frame) <= 0;
}

- (BOOL)rightControllerIsClosed {
    return !self.rightController || CGRectGetMaxX(self.slidingControllerView.frame) >= self.referenceBounds.size.width;
}

- (BOOL)leftControllerIsOpen {
    return self.leftController && CGRectGetMinX(self.slidingControllerView.frame) < self.referenceBounds.size.width && CGRectGetMinX(self.slidingControllerView.frame) >= self.rightLedge;
}

- (BOOL)rightControllerIsOpen {
    return self.rightController && CGRectGetMaxX(self.slidingControllerView.frame) < self.referenceBounds.size.width && CGRectGetMaxX(self.slidingControllerView.frame) >= self.leftLedge;
}

- (void)showCenterView {
    [self showCenterView:YES];
}

- (void)showCenterView:(BOOL)animated {
    [self showCenterView:animated completion:nil];
}

- (void)showCenterView:(BOOL)animated  completion:(IIViewDeckControllerBlock)completed {
    BOOL mustRunCompletion = completed != nil;
    if (self.leftController && !self.leftController.view.hidden) {
        [self closeLeftViewAnimated:animated completion:completed];
        mustRunCompletion = NO;
    }
    
    if (self.rightController && !self.rightController.view.hidden) {
        [self closeRightViewAnimated:animated completion:completed];
        mustRunCompletion = NO;
    }
    
    if (mustRunCompletion)
        completed(self);
}

- (BOOL)toggleLeftView {
    return [self toggleLeftViewAnimated:YES];
}

- (BOOL)openLeftView {
    return [self openLeftViewAnimated:YES];
}

- (BOOL)closeLeftView {
    return [self closeLeftViewAnimated:YES];
}

- (BOOL)toggleLeftViewAnimated:(BOOL)animated {
    return [self toggleLeftViewAnimated:animated completion:nil];
}

- (BOOL)toggleLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    if ([self leftControllerIsClosed]) 
        return [self openLeftViewAnimated:animated completion:completed];
    else
        return [self closeLeftViewAnimated:animated completion:completed];
}

- (BOOL)openLeftViewAnimated:(BOOL)animated {
    return [self openLeftViewAnimated:animated completion:nil];
}

- (BOOL)openLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:YES completion:completed];
}

- (BOOL)openLeftViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self openLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:callDelegate completion:completed];
}

- (BOOL)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (!self.leftController || II_FLOAT_EQUAL(CGRectGetMinX(self.slidingControllerView.frame), self.leftLedge)) return YES;
    
    // check the delegate to allow opening
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillOpenLeftView:animated:) animated:animated]) return NO;
    // also close the right view if it's open. Since the delegate can cancel the close, check the result.
    if (callDelegate && ![self closeRightViewAnimated:animated options:options callDelegate:callDelegate completion:completed]) return NO;
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.leftController.view.hidden = NO;
        [self setSlidingFrameForOffset:self.referenceBounds.size.width - self.leftLedge];
        [self centerViewHidden];
    } completion:^(BOOL finished) {
        if (completed) completed(self);
        if (callDelegate) [self performDelegate:@selector(viewDeckControllerDidOpenLeftView:animated:) animated:animated];
    }];
    
    return YES;
}

- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced {
    return [self openLeftViewBouncing:bounced completion:nil];
}

- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self openLeftViewBouncing:bounced callDelegate:YES completion:completed];
}

- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self openLeftViewBouncing:bounced options:UIViewAnimationOptionCurveEaseInOut callDelegate:YES completion:completed];
}

- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (!self.leftController || II_FLOAT_EQUAL(CGRectGetMinX(self.slidingControllerView.frame), self.leftLedge)) return YES;
    
    // check the delegate to allow opening
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillOpenLeftView:animated:) animated:YES]) return NO;
    // also close the right view if it's open. Since the delegate can cancel the close, check the result.
    if (callDelegate && ![self closeRightViewAnimated:YES options:options callDelegate:callDelegate completion:completed]) return NO;
    
    // first open the view completely, run the block (to allow changes)
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        self.leftController.view.hidden = NO;
        [self setSlidingFrameForOffset:self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        // run block if it's defined
        if (bounced) bounced(self);
        [self centerViewHidden];
        
        // now slide the view back to the ledge position
        [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:options | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setSlidingFrameForOffset:self.referenceBounds.size.width - self.leftLedge];
        } completion:^(BOOL finished) {
            if (completed) completed(self);
            if (callDelegate) [self performDelegate:@selector(viewDeckControllerDidOpenLeftView:animated:) animated:YES];
        }];
    }];
    
    return YES;
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated {
    return [self closeLeftViewAnimated:animated completion:nil];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeLeftViewAnimated:animated callDelegate:YES completion:completed];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self closeLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:callDelegate completion:completed];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (self.leftControllerIsClosed) return YES;
    
    // check the delegate to allow closing
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillCloseLeftView:animated:) animated:animated]) return NO;
    
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        [self setSlidingFrameForOffset:0];
        [self centerViewVisible];
    } completion:^(BOOL finished) {
        [self hideAppropriateSideViews];
        if (completed) completed(self);
        if (callDelegate) {
            [self performDelegate:@selector(viewDeckControllerDidCloseLeftView:animated:) animated:animated];
            [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:animated];
        }
    }];
    
    return YES;
}

- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBlock)bounced {
    return [self closeLeftViewBouncing:bounced completion:nil];
}

- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self closeLeftViewBouncing:bounced callDelegate:YES completion:completed];
}

- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBlock)bounced callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (self.leftControllerIsClosed) return YES;
    
    // check the delegate to allow closing
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillCloseLeftView:animated:) animated:YES]) return NO;
    
    // first open the view completely, run the block (to allow changes) and close it again.
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        [self setSlidingFrameForOffset:self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        // run block if it's defined
        if (bounced) bounced(self);
        if (callDelegate && self.delegate && [self.delegate respondsToSelector:@selector(viewDeckController:didBounceWithClosingController:)]) 
            [self.delegate viewDeckController:self didBounceWithClosingController:self.leftController];
        
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            [self setSlidingFrameForOffset:0];
            [self centerViewVisible];
        } completion:^(BOOL finished2) {
            [self hideAppropriateSideViews];
            if (completed) completed(self);
            if (callDelegate) {
                [self performDelegate:@selector(viewDeckControllerDidCloseLeftView:animated:) animated:YES];
                [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:YES];
            }
        }];
    }];
    
    return YES;
}


- (BOOL)toggleRightView {
    return [self toggleRightViewAnimated:YES];
}

- (BOOL)openRightView {
    return [self openRightViewAnimated:YES];
}

- (BOOL)closeRightView {
    return [self closeRightViewAnimated:YES];
}

- (BOOL)toggleRightViewAnimated:(BOOL)animated {
    return [self toggleRightViewAnimated:animated completion:nil];
}

- (BOOL)toggleRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    if ([self rightControllerIsClosed]) 
        return [self openRightViewAnimated:animated completion:completed];
    else
        return [self closeRightViewAnimated:animated completion:completed];
}

- (BOOL)openRightViewAnimated:(BOOL)animated {
    return [self openRightViewAnimated:animated completion:nil];
}

- (BOOL)openRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:YES completion:completed];
}

- (BOOL)openRightViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self openRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:callDelegate completion:completed];
}

- (BOOL)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (!self.rightController || II_FLOAT_EQUAL(CGRectGetMaxX(self.slidingControllerView.frame), self.rightLedge)) return YES;
    
    // check the delegate to allow opening
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillOpenRightView:animated:) animated:animated]) return NO;
    // also close the left view if it's open. Since the delegate can cancel the close, check the result.
    if (callDelegate && ![self closeLeftViewAnimated:animated options:options callDelegate:callDelegate completion:completed]) return NO;
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.rightController.view.hidden = NO;
        [self setSlidingFrameForOffset:self.rightLedge - self.referenceBounds.size.width];
        [self centerViewHidden];
    } completion:^(BOOL finished) {
        if (completed) completed(self);
        if (callDelegate) [self performDelegate:@selector(viewDeckControllerDidOpenRightView:animated:) animated:animated];
    }];
    
    return YES;
}

- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced {
    return [self openRightViewBouncing:bounced completion:nil];
}

- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self openRightViewBouncing:bounced callDelegate:YES completion:completed];
}

- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self openRightViewBouncing:bounced options:UIViewAnimationOptionCurveEaseInOut callDelegate:YES completion:completed];
}

- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (!self.rightController || II_FLOAT_EQUAL(CGRectGetMinX(self.slidingControllerView.frame), self.rightLedge)) return YES;
    
    // check the delegate to allow opening
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillOpenRightView:animated:) animated:YES]) return NO;
    // also close the right view if it's open. Since the delegate can cancel the close, check the result.
    if (callDelegate && ![self closeLeftViewAnimated:YES options:options callDelegate:callDelegate completion:completed]) return NO;
    
    // first open the view completely, run the block (to allow changes)
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        self.rightController.view.hidden = NO;
        [self setSlidingFrameForOffset:-self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        // run block if it's defined
        if (bounced) bounced(self);
        [self centerViewHidden];
        
        // now slide the view back to the ledge position
        [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:options | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setSlidingFrameForOffset:self.rightLedge - self.referenceBounds.size.width];
        } completion:^(BOOL finished) {
            if (completed) completed(self);
            if (callDelegate) [self performDelegate:@selector(viewDeckControllerDidOpenRightView:animated:) animated:YES];
        }];
    }];
    
    return YES;
}

- (BOOL)closeRightViewAnimated:(BOOL)animated {
    return [self closeRightViewAnimated:animated completion:nil];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:YES completion:completed];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self openRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut callDelegate:callDelegate completion:completed];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (self.rightControllerIsClosed) return YES;
    
    // check the delegate to allow closing
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillCloseRightView:animated:) animated:animated]) return NO;
    
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        [self setSlidingFrameForOffset:0];
        [self centerViewVisible];
    } completion:^(BOOL finished) {
        if (completed) completed(self);
        [self hideAppropriateSideViews];
        if (callDelegate) {
            [self performDelegate:@selector(viewDeckControllerDidCloseRightView:animated:) animated:animated];
            [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:animated];
        }
    }];
    
    return YES;
}

- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBlock)bounced {
    return [self closeRightViewBouncing:bounced completion:nil];
}

- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self closeRightViewBouncing:bounced callDelegate:YES completion:completed];
}

- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBlock)bounced callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    if (self.rightControllerIsClosed) return YES;
    
    // check the delegate to allow closing
    if (callDelegate && ![self checkDelegate:@selector(viewDeckControllerWillCloseRightView:animated:) animated:YES]) return NO;
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        [self setSlidingFrameForOffset:-self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        if (bounced) bounced(self);
        if (callDelegate && self.delegate && [self.delegate respondsToSelector:@selector(viewDeckController:didBounceWithClosingController:)]) 
            [self.delegate viewDeckController:self didBounceWithClosingController:self.rightController];
        
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            [self setSlidingFrameForOffset:0];
            [self centerViewVisible];
        } completion:^(BOOL finished2) {
            [self hideAppropriateSideViews];
            if (completed) completed(self);
            [self performDelegate:@selector(viewDeckControllerDidCloseRightView:animated:) animated:YES];
            [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:YES];
        }];
    }];
    
    return YES;
}

- (void)rightViewPushViewControllerOverCenterController:(UIViewController*)controller {
    NSAssert([self.centerController isKindOfClass:[UINavigationController class]], @"cannot rightViewPushViewControllerOverCenterView when center controller is not a navigation controller");

    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *deckshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView* shotView = [[UIImageView alloc] initWithImage:deckshot];
    shotView.frame = self.view.frame; 
    [self.view.superview addSubview:shotView];
    CGRect targetFrame = self.view.frame; 
    self.view.frame = CGRectOffset(self.view.frame, self.view.frame.size.width, 0);
    
    [self closeRightViewAnimated:NO];
    UINavigationController* navController = (UINavigationController*)self.centerController;
    [navController pushViewController:controller animated:NO];
    
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        shotView.frame = CGRectOffset(shotView.frame, -self.view.frame.size.width, 0);
        self.view.frame = targetFrame;
    } completion:^(BOOL finished) {
        [shotView removeFromSuperview];
    }];
}



#pragma mark - Pre iOS5 message relaying

- (void)relayAppearanceMethod:(void(^)(UIViewController* controller))relay forced:(BOOL)forced {
    bool shouldRelay = ![self respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)] || ![self performSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)];
    
    // don't relay if the controller supports automatic relaying
    if (!shouldRelay && !forced) 
        return;                                                                                                                                       
    
    relay(self.centerController);
    relay(self.leftController);
    relay(self.rightController);
}

- (void)relayAppearanceMethod:(void(^)(UIViewController* controller))relay {
    [self relayAppearanceMethod:relay forced:NO];
}

#pragma mark - center view hidden stuff

- (void)centerViewVisible {
    [self removePanners];
    if (self.centerTapper) {
        [self.centerTapper removeTarget:self action:@selector(centerTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.centerTapper removeFromSuperview];
    }
    self.centerTapper = nil;
    [self addPanners];
}

- (void)centerViewHidden {
    if (IIViewDeckCenterHiddenIsInteractive(self.centerhiddenInteractivity)) 
        return;
    
    [self removePanners];
    if (!self.centerTapper) {
        self.centerTapper = [UIButton buttonWithType:UIButtonTypeCustom];
        self.centerTapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerTapper.frame = [self.centerView bounds];
        [self.centerView addSubview:self.centerTapper];
        [self.centerTapper addTarget:self action:@selector(centerTapped) forControlEvents:UIControlEventTouchUpInside];
        self.centerTapper.backgroundColor = [UIColor clearColor];
        
    }
    self.centerTapper.frame = [self.centerView bounds];
    [self addPanners];
}

- (void)centerTapped {
    if (IIViewDeckCenterHiddenCanTapToClose(self.centerhiddenInteractivity)) {
        if (self.leftController && CGRectGetMinX(self.slidingControllerView.frame) > 0) {
            if (self.centerhiddenInteractivity == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose) 
                [self closeLeftView];
            else
                [self closeLeftViewBouncing:nil];
        }
        if (self.rightController && CGRectGetMinX(self.slidingControllerView.frame) < 0) {
            if (self.centerhiddenInteractivity == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose) 
                [self closeRightView];
            else
                [self closeRightViewBouncing:nil];
        }
        
    }
}

#pragma mark - Panning

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.panningGestureDelegate && [self.panningGestureDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        BOOL result = [self.panningGestureDelegate gestureRecognizerShouldBegin:gestureRecognizer];
        if (!result) return result;
    }
    
    CGFloat px = self.slidingControllerView.frame.origin.x;
    if (px != 0) return YES;
        
    CGFloat x = [self locationOfPanner:(UIPanGestureRecognizer*)gestureRecognizer];
    BOOL ok =  YES;

    if (x > 0) {
        ok = [self checkDelegate:@selector(viewDeckControllerWillOpenLeftView:animated:) animated:NO];
        if (!ok)
            [self closeLeftViewAnimated:NO];
    }
    else if (x < 0) {
        ok = [self checkDelegate:@selector(viewDeckControllerWillOpenRightView:animated:) animated:NO];
        if (!ok)
            [self closeRightViewAnimated:NO];
    }
    
    return ok;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.panningGestureDelegate && [self.panningGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
        BOOL result = [self.panningGestureDelegate gestureRecognizer:gestureRecognizer
                                                  shouldReceiveTouch:touch];
        if (!result) return result;
    }

    if ([[touch view] isKindOfClass:[UISlider class]])
        return NO;

    _panOrigin = self.slidingControllerView.frame.origin.x;
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.panningGestureDelegate && [self.panningGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.panningGestureDelegate gestureRecognizer:gestureRecognizer
           shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    return NO;
}

- (CGFloat)locationOfPanner:(UIPanGestureRecognizer*)panner {
    CGPoint pan = [panner translationInView:self.referenceView];
    CGFloat x = pan.x + _panOrigin;
    
    if (!self.leftController) x = MIN(0, x);
    if (!self.rightController) x = MAX(0, x);
    
    CGFloat w = self.referenceBounds.size.width;
    CGFloat lx = fmaxf(fminf(x, w-self.leftLedge), -w+self.rightLedge);
    
    if (self.elastic) {
        CGFloat dx = ABS(x) - ABS(lx);
        if (dx > 0) {
            dx = dx / logf(dx + 1) * 2;
            x = lx + (x < 0 ? -dx : dx);
        }
    }
    else {
        x = lx;
    }
    
    return [self limitOffset:x];
}

- (void)panned:(UIPanGestureRecognizer*)panner {
    if (!_enabled) return;
    
    CGFloat px = self.slidingControllerView.frame.origin.x;
    CGFloat x = [self locationOfPanner:panner];
    CGFloat w = self.referenceBounds.size.width;

    SEL didCloseSelector = nil;
    SEL didOpenSelector = nil;
    
    // if we move over a boundary while dragging, ... 
    if (px <= 0 && x >= 0 && px != x) {
        // ... then we need to check if the other side can open.
        if (px < 0) {
            BOOL canClose = [self checkDelegate:@selector(viewDeckControllerWillCloseRightView:animated:) animated:NO];
            if (!canClose)
                return;
            didCloseSelector = @selector(viewDeckControllerDidCloseRightView:animated:);
        }

        if (x > 0) {
            BOOL canOpen = [self checkDelegate:@selector(viewDeckControllerWillOpenLeftView:animated:) animated:NO];
            didOpenSelector = @selector(viewDeckControllerDidOpenLeftView:animated:);
            if (!canOpen) {
                [self closeRightViewAnimated:NO];
                return;
            }
        }
    }
    else if (px >= 0 && x <= 0 && px != x) {
        if (px > 0) {
            BOOL canClose = [self checkDelegate:@selector(viewDeckControllerWillCloseLeftView:animated:) animated:NO];
            if (!canClose) {
                return;
            }
            didCloseSelector = @selector(viewDeckControllerDidCloseLeftView:animated:);
        }

        if (x < 0) {
            BOOL canOpen = [self checkDelegate:@selector(viewDeckControllerWillOpenRightView:animated:) animated:NO];
            didOpenSelector = @selector(viewDeckControllerDidOpenRightView:animated:);
            if (!canOpen) {
                [self closeLeftViewAnimated:NO];
                return;
            }
        }
    }
    
    [self setSlidingFrameForOffset:x];
    
    [self performOffsetDelegate:@selector(viewDeckController:didPanToOffset:) offset:x];
    
    if (panner.state == UIGestureRecognizerStateEnded ||
        panner.state == UIGestureRecognizerStateCancelled ||
        panner.state == UIGestureRecognizerStateFailed) {
        if (self.slidingControllerView.frame.origin.x == 0.0f)
            [self centerViewVisible];
        else
            [self centerViewHidden];
        
        CGFloat lw3 = (w-self.leftLedge) / 3.0;
        CGFloat rw3 = (w-self.rightLedge) / 3.0;
        CGFloat velocity = [panner velocityInView:self.referenceView].x;
        if (ABS(velocity) < 500) {
            // small velocity, no movement
            if (x >= w - self.leftLedge - lw3) {
                [self openLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut callDelegate:NO completion:nil];
            }
            else if (x <= self.rightLedge + rw3 - w) {
                [self openRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut callDelegate:NO completion:nil];
            }
            else
                [self showCenterView:YES];
        }
        else if (velocity < 0) {
            // swipe to the left
            if (x < 0) {
                [self openRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut callDelegate:YES completion:nil];
            }
            else 
                [self showCenterView:YES];
        }
        else if (velocity > 0) {
            // swipe to the right
            if (x > 0) {
                [self openLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut callDelegate:YES completion:nil];
            }
            else 
                [self showCenterView:YES];
        }
    }
    else
        [self hideAppropriateSideViews];

    if (didCloseSelector)
        [self performDelegate:didCloseSelector animated:NO];
    if (didOpenSelector)
        [self performDelegate:didOpenSelector animated:NO];
}


- (void)addPanner:(UIView*)view {
    if (!view) return;
    
    UIPanGestureRecognizer* panner = II_AUTORELEASE([[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)]);
    panner.cancelsTouchesInView = YES;
    panner.delegate = self;
    [view addGestureRecognizer:panner];
    [self.panners addObject:panner];
}


- (void)addPanners {
    [self removePanners];
    
    switch (_panningMode) {
        case IIViewDeckNoPanning: 
            break;
            
        case IIViewDeckFullViewPanning:
            [self addPanner:self.slidingControllerView];
            // also add to disabled center
            if (self.centerTapper)
                [self addPanner:self.centerTapper];
            // also add to navigationbar if present
            if (self.navigationController && !self.navigationController.navigationBarHidden) 
                [self addPanner:self.navigationController.navigationBar];
            break;
            
        case IIViewDeckNavigationBarPanning:
            if (self.navigationController && !self.navigationController.navigationBarHidden) {
                [self addPanner:self.navigationController.navigationBar];
            }
            
            if (self.centerController.navigationController && !self.centerController.navigationController.navigationBarHidden) {
                [self addPanner:self.centerController.navigationController.navigationBar];
            }
            
            if ([self.centerController isKindOfClass:[UINavigationController class]] && !((UINavigationController*)self.centerController).navigationBarHidden) {
                [self addPanner:((UINavigationController*)self.centerController).navigationBar];
            }
            break;
        case IIViewDeckPanningViewPanning:
            if (_panningView) {
                [self addPanner:self.panningView];
            }
            break;
    }
}


- (void)removePanners {
    for (UIGestureRecognizer* panner in self.panners) {
        [panner.view removeGestureRecognizer:panner];
    }
    [self.panners removeAllObjects];
}

#pragma mark - Delegate convenience methods

- (BOOL)checkDelegate:(SEL)selector animated:(BOOL)animated {
    BOOL ok = YES;
    // used typed message send to properly pass values
    BOOL (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, BOOL animated) = (void*)objc_msgSend;
    
    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        ok = ok & objc_msgSendTyped(self.delegate, selector, self, animated);
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate) 
            ok = ok & objc_msgSendTyped(controller, selector, self, animated);
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate) 
                ok = ok & objc_msgSendTyped(topController, selector, self, animated);
        }
    }
    
    return ok;
}

- (void)performDelegate:(SEL)selector animated:(BOOL)animated {
    // used typed message send to properly pass values
    void (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, BOOL animated) = (void*)objc_msgSend;

    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        objc_msgSendTyped(self.delegate, selector, self, animated);
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate) 
            objc_msgSendTyped(controller, selector, self, animated);
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate) 
                objc_msgSendTyped(topController, selector, self, animated);
        }
    }
}

- (void)performOffsetDelegate:(SEL)selector offset:(CGFloat)offset {
    void (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, CGFloat offset) = (void*)objc_msgSend;
    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        objc_msgSendTyped(self.delegate, selector, self, offset);
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate) 
            objc_msgSendTyped(controller, selector, self, offset);
        
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate) 
                objc_msgSendTyped(topController, selector, self, offset);
        }
    }
}


#pragma mark - Properties

- (void)setTitle:(NSString *)title {
    if (!II_STRING_EQUAL(title, self.title)) [super setTitle:title];
    if (!II_STRING_EQUAL(title, self.centerController.title)) self.centerController.title = title;
}

- (NSString*)title {
    return self.centerController.title;
}

- (void)setPanningMode:(IIViewDeckPanningMode)panningMode {
    if (_viewAppeared) {
        [self removePanners];
        _panningMode = panningMode;
        [self addPanners];
    }
    else
        _panningMode = panningMode;
}

- (void)setPanningView:(UIView *)panningView {
    if (_panningView != panningView) {
        II_RELEASE(_panningView);
        _panningView = panningView;
        II_RETAIN(_panningView);
        
        if (_viewAppeared && _panningMode == IIViewDeckPanningViewPanning)
            [self addPanners];
    }
}

- (void)setNavigationControllerBehavior:(IIViewDeckNavigationControllerBehavior)navigationControllerBehavior {
    if (!_viewAppeared) {
        _navigationControllerBehavior = navigationControllerBehavior;
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set navigationcontroller behavior when the view deck is already showing." userInfo:nil];
    }
}

- (void)applySideController:(__strong UIViewController **)controllerStore to:(UIViewController *)newController otherSideController:(UIViewController *)otherController clearOtherController:(void(^)())clearOtherController {
    void(^beforeBlock)(UIViewController* controller) = ^(UIViewController* controller){};
    void(^afterBlock)(UIViewController* controller, BOOL left) = ^(UIViewController* controller, BOOL left){};
    
    if (_viewAppeared) {
        beforeBlock = ^(UIViewController* controller) {
            [controller vdc_viewWillDisappear:NO];
            [controller.view removeFromSuperview];
            [controller vdc_viewDidDisappear:NO];
        };
        afterBlock = ^(UIViewController* controller, BOOL left) {
            [controller vdc_viewWillAppear:NO];
            controller.view.hidden = left ? self.slidingControllerView.frame.origin.x <= 0 : self.slidingControllerView.frame.origin.x >= 0;
            controller.view.frame = self.referenceBounds;
            controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (self.slidingController)
                [self.referenceView insertSubview:controller.view belowSubview:self.slidingControllerView];
            else
                [self.referenceView addSubview:controller.view];
            [controller vdc_viewDidAppear:NO];
        };
    }
    
    // start the transition
    if (*controllerStore) {
        [*controllerStore willMoveToParentViewController:nil];
        if (newController == self.centerController) self.centerController = nil;
        if (newController == otherController && clearOtherController) clearOtherController();
        beforeBlock(*controllerStore);
        [*controllerStore setViewDeckController:nil];
        [*controllerStore removeFromParentViewController];
        [*controllerStore didMoveToParentViewController:nil];
    }
    
    // make the switch
    if (*controllerStore != newController) {
        II_RELEASE(*controllerStore);
        *controllerStore = newController;
        II_RETAIN(*controllerStore);
    }
    
    if (*controllerStore) {
        [newController willMoveToParentViewController:nil];
        [newController removeFromParentViewController];
        [newController didMoveToParentViewController:nil];
        
        // and finish the transition
        UIViewController* parentController = (self.referenceView == self.view) ? self : [[self parentViewController] parentViewController];
        [parentController addChildViewController:*controllerStore];
        [*controllerStore setViewDeckController:self];
        afterBlock(*controllerStore, *controllerStore == _leftController);
        [*controllerStore didMoveToParentViewController:parentController];
    }
}

- (void)reapplySideController:(__strong UIViewController **)controllerStore {
    [self applySideController:controllerStore to:*controllerStore otherSideController:nil clearOtherController:nil];
}

- (void)setLeftController:(UIViewController *)leftController {
    if (_leftController == leftController) return;
    [self applySideController:&_leftController to:leftController otherSideController:_rightController clearOtherController:^() { self.rightController = nil; }];
}

- (void)setRightController:(UIViewController *)rightController {
    if (_rightController == rightController) return;
    [self applySideController:&_rightController to:rightController otherSideController:_leftController clearOtherController:^() { self.leftController = nil; }];
}


- (void)setCenterController:(UIViewController *)centerController {
    if (_centerController == centerController) return;
    
    void(^beforeBlock)(UIViewController* controller) = ^(UIViewController* controller){};
    void(^afterBlock)(UIViewController* controller) = ^(UIViewController* controller){};
    
    __block CGRect currentFrame = self.referenceBounds;
    if (_viewAppeared) {
        beforeBlock = ^(UIViewController* controller) {
            [controller vdc_viewWillDisappear:NO];
            [self restoreShadowToSlidingView];
            [self removePanners];
            [controller.view removeFromSuperview];
            [controller vdc_viewDidDisappear:NO];
            [self.centerView removeFromSuperview];
        };
        afterBlock = ^(UIViewController* controller) {
            [self.view addSubview:self.centerView];
            [controller vdc_viewWillAppear:NO];
            UINavigationController* navController = [centerController isKindOfClass:[UINavigationController class]] 
            ? (UINavigationController*)centerController 
            : nil;
            BOOL barHidden = NO;
            if (navController != nil && !navController.navigationBarHidden) {
                barHidden = YES;
                navController.navigationBarHidden = YES;
            }
            
            [self setSlidingAndReferenceViews];
            controller.view.frame = currentFrame;
            controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            controller.view.hidden = NO;
            [self.centerView addSubview:controller.view];
            
            if (barHidden) 
                navController.navigationBarHidden = NO;
            
            [self addPanners];
            [self applyShadowToSlidingView];
            [controller vdc_viewDidAppear:NO];
        };
    }
    
    // start the transition
    if (_centerController) {
        currentFrame = _centerController.view.frame;
        [_centerController willMoveToParentViewController:nil];
        if (centerController == self.leftController) self.leftController = nil;
        if (centerController == self.rightController) self.rightController = nil;
        beforeBlock(_centerController);
        @try {
            [_centerController removeObserver:self forKeyPath:@"title"];
            if (self.automaticallyUpdateTabBarItems) {
                [_centerController removeObserver:self forKeyPath:@"tabBarItem.title"];
                [_centerController removeObserver:self forKeyPath:@"tabBarItem.image"];
                [_centerController removeObserver:self forKeyPath:@"hidesBottomBarWhenPushed"];
            }
        }
        @catch (NSException *exception) {}
        [_centerController setViewDeckController:nil];
        [_centerController removeFromParentViewController];

        
        [_centerController didMoveToParentViewController:nil];
        II_RELEASE(_centerController);
    }
    
    // make the switch
    _centerController = centerController;
    
    if (_centerController) {
        // and finish the transition
        II_RETAIN(_centerController);
        [self addChildViewController:_centerController];
        [_centerController setViewDeckController:self];
        [_centerController addObserver:self forKeyPath:@"title" options:0 context:nil];
        self.title = _centerController.title;
        if (self.automaticallyUpdateTabBarItems) {
            [_centerController addObserver:self forKeyPath:@"tabBarItem.title" options:0 context:nil];
            [_centerController addObserver:self forKeyPath:@"tabBarItem.image" options:0 context:nil];
            [_centerController addObserver:self forKeyPath:@"hidesBottomBarWhenPushed" options:0 context:nil];
            self.tabBarItem.title = _centerController.tabBarItem.title;
            self.tabBarItem.image = _centerController.tabBarItem.image;
            self.hidesBottomBarWhenPushed = _centerController.hidesBottomBarWhenPushed;
        }
        
        afterBlock(_centerController);
        [_centerController didMoveToParentViewController:self];
    }    
}

- (void)setAutomaticallyUpdateTabBarItems:(BOOL)automaticallyUpdateTabBarItems {
    if (_automaticallyUpdateTabBarItems) {
        @try {
            [_centerController removeObserver:self forKeyPath:@"tabBarItem.title"];
            [_centerController removeObserver:self forKeyPath:@"tabBarItem.image"];
            [_centerController removeObserver:self forKeyPath:@"hidesBottomBarWhenPushed"];
        }
        @catch (NSException *exception) {}
    }
    
    _automaticallyUpdateTabBarItems = automaticallyUpdateTabBarItems;

    if (_automaticallyUpdateTabBarItems) {
        [_centerController addObserver:self forKeyPath:@"tabBarItem.title" options:0 context:nil];
        [_centerController addObserver:self forKeyPath:@"tabBarItem.image" options:0 context:nil];
        [_centerController addObserver:self forKeyPath:@"hidesBottomBarWhenPushed" options:0 context:nil];
        self.tabBarItem.title = _centerController.tabBarItem.title;
        self.tabBarItem.image = _centerController.tabBarItem.image;
    }
}


- (BOOL)setSlidingAndReferenceViews {
    if (self.navigationController && self.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated) {
        if ([self.navigationController.view superview]) {
            _slidingController = self.navigationController;
            self.referenceView = [self.navigationController.view superview];
            return YES;
        }
    }
    else {
        _slidingController = self.centerController;
        self.referenceView = self.view;
        return YES;
    }
    
    return NO;
}

- (UIView*)slidingControllerView {
    if (self.navigationController && self.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated) {
        return self.slidingController.view;
    }
    else {
        return self.centerView;
    }
}

#pragma mark - observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _centerController) {
        if ([@"tabBarItem.title" isEqualToString:keyPath]) {
            self.tabBarItem.title = _centerController.tabBarItem.title;
            return;
        }
        
        if ([@"tabBarItem.image" isEqualToString:keyPath]) {
            self.tabBarItem.image = _centerController.tabBarItem.image;
            return;
        }

        if ([@"hidesBottomBarWhenPushed" isEqualToString:keyPath]) {
            self.hidesBottomBarWhenPushed = _centerController.hidesBottomBarWhenPushed;
            self.tabBarController.hidesBottomBarWhenPushed = _centerController.hidesBottomBarWhenPushed;
            return;
        }
    }

    if ([@"title" isEqualToString:keyPath]) {
        if (!II_STRING_EQUAL([super title], self.centerController.title)) {
            self.title = self.centerController.title;
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"bounds"]) {
        CGFloat offset = self.slidingControllerView.frame.origin.x;
        [self setSlidingFrameForOffset:offset];
        self.slidingControllerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.referenceBounds].CGPath;
        UINavigationController* navController = [self.centerController isKindOfClass:[UINavigationController class]] 
        ? (UINavigationController*)self.centerController 
        : nil;
        if (navController != nil && !navController.navigationBarHidden) {
            navController.navigationBarHidden = YES;
            navController.navigationBarHidden = NO;
        }
        return;
    }
}

#pragma mark - Shadow

- (void)restoreShadowToSlidingView {
    UIView* shadowedView = self.slidingControllerView;
    if (!shadowedView) return;
    
    shadowedView.layer.shadowRadius = self.originalShadowRadius;
    shadowedView.layer.shadowOpacity = self.originalShadowOpacity;
    shadowedView.layer.shadowColor = [self.originalShadowColor CGColor]; 
    shadowedView.layer.shadowOffset = self.originalShadowOffset;
    shadowedView.layer.shadowPath = [self.originalShadowPath CGPath];
}

- (void)applyShadowToSlidingView {
    UIView* shadowedView = self.slidingControllerView;
    if (!shadowedView) return;
    
    self.originalShadowRadius = shadowedView.layer.shadowRadius;
    self.originalShadowOpacity = shadowedView.layer.shadowOpacity;
    self.originalShadowColor = shadowedView.layer.shadowColor ? [UIColor colorWithCGColor:self.slidingControllerView.layer.shadowColor] : nil;
    self.originalShadowOffset = shadowedView.layer.shadowOffset;
    self.originalShadowPath = shadowedView.layer.shadowPath ? [UIBezierPath bezierPathWithCGPath:self.slidingControllerView.layer.shadowPath] : nil;
    
    if ([self.delegate respondsToSelector:@selector(viewDeckController:applyShadow:withBounds:)]) {
        [self.delegate viewDeckController:self applyShadow:shadowedView.layer withBounds:self.referenceBounds];
    }
    else {
        shadowedView.layer.masksToBounds = NO;
        shadowedView.layer.shadowRadius = 10;
        shadowedView.layer.shadowOpacity = 0.5;
        shadowedView.layer.shadowColor = [[UIColor blackColor] CGColor];
        shadowedView.layer.shadowOffset = CGSizeZero;
        shadowedView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowedView.bounds] CGPath];
    }
}


@end

#pragma mark -

@implementation UIViewController (UIViewDeckItem) 

@dynamic viewDeckController;

static const char* viewDeckControllerKey = "ViewDeckController";

- (IIViewDeckController*)viewDeckController_core {
    return objc_getAssociatedObject(self, viewDeckControllerKey);
}

- (IIViewDeckController*)viewDeckController {
    id result = [self viewDeckController_core];
    if (!result && self.navigationController) 
        result = [self.navigationController viewDeckController];
    if (!result && [self respondsToSelector:@selector(wrapController)] && self.wrapController) 
        result = [self.wrapController viewDeckController];
    
    return result;
}

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController {
    objc_setAssociatedObject(self, viewDeckControllerKey, viewDeckController, OBJC_ASSOCIATION_ASSIGN);
}

- (void)vdc_presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    UIViewController* controller = self.viewDeckController && (self.viewDeckController.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated || ![self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) ? self.viewDeckController : self;
    [controller vdc_presentModalViewController:modalViewController animated:animated]; // when we get here, the vdc_ method is actually the old, real method
}

- (void)vdc_dismissModalViewControllerAnimated:(BOOL)animated {
    UIViewController* controller = self.viewDeckController ? self.viewDeckController : self;
    [controller vdc_dismissModalViewControllerAnimated:animated]; // when we get here, the vdc_ method is actually the old, real method
}

#ifdef __IPHONE_5_0

- (void)vdc_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController* controller = self.viewDeckController && (self.viewDeckController.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated || ![self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) ? self.viewDeckController : self;
    [controller vdc_presentViewController:viewControllerToPresent animated:animated completion:completion]; // when we get here, the vdc_ method is actually the old, real method
}

- (void)vdc_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController* controller = self.viewDeckController ? self.viewDeckController : self;
    [controller vdc_dismissViewControllerAnimated:flag completion:completion]; // when we get here, the vdc_ method is actually the old, real method
}

#endif

- (UINavigationController*)vdc_navigationController {
    UIViewController* controller = self.viewDeckController_core ? self.viewDeckController_core : self;
    return [controller vdc_navigationController]; // when we get here, the vdc_ method is actually the old, real method
}

- (UINavigationItem*)vdc_navigationItem {
    UIViewController* controller = self.viewDeckController_core ? self.viewDeckController_core : self;
    return [controller vdc_navigationItem]; // when we get here, the vdc_ method is actually the old, real method
}

+ (void)vdc_swizzle {
    SEL presentModal = @selector(presentModalViewController:animated:);
    SEL vdcPresentModal = @selector(vdc_presentModalViewController:animated:);
    method_exchangeImplementations(class_getInstanceMethod(self, presentModal), class_getInstanceMethod(self, vdcPresentModal));
    
    SEL presentVC = @selector(presentViewController:animated:completion:);
    SEL vdcPresentVC = @selector(vdc_presentViewController:animated:completion:);
    method_exchangeImplementations(class_getInstanceMethod(self, presentVC), class_getInstanceMethod(self, vdcPresentVC));
    
    SEL nc = @selector(navigationController);
    SEL vdcnc = @selector(vdc_navigationController);
    method_exchangeImplementations(class_getInstanceMethod(self, nc), class_getInstanceMethod(self, vdcnc));
    
    SEL ni = @selector(navigationItem);
    SEL vdcni = @selector(vdc_navigationItem);
    method_exchangeImplementations(class_getInstanceMethod(self, ni), class_getInstanceMethod(self, vdcni));
    
    // view containment drop ins for <ios5
    SEL willMoveToPVC = @selector(willMoveToParentViewController:);
    SEL vdcWillMoveToPVC = @selector(vdc_willMoveToParentViewController:);
    if (!class_getInstanceMethod(self, willMoveToPVC)) {
        Method implementation = class_getInstanceMethod(self, vdcWillMoveToPVC);
        class_addMethod([UIViewController class], willMoveToPVC, method_getImplementation(implementation), "v@:@"); 
    }
    
    SEL didMoveToPVC = @selector(didMoveToParentViewController:);
    SEL vdcDidMoveToPVC = @selector(vdc_didMoveToParentViewController:);
    if (!class_getInstanceMethod(self, didMoveToPVC)) {
        Method implementation = class_getInstanceMethod(self, vdcDidMoveToPVC);
        class_addMethod([UIViewController class], didMoveToPVC, method_getImplementation(implementation), "v@:"); 
    }
    
    SEL removeFromPVC = @selector(removeFromParentViewController);
    SEL vdcRemoveFromPVC = @selector(vdc_removeFromParentViewController);
    if (!class_getInstanceMethod(self, removeFromPVC)) {
        Method implementation = class_getInstanceMethod(self, vdcRemoveFromPVC);
        class_addMethod([UIViewController class], removeFromPVC, method_getImplementation(implementation), "v@:"); 
    }
    
    SEL addCVC = @selector(addChildViewController:);
    SEL vdcAddCVC = @selector(vdc_addChildViewController:);
    if (!class_getInstanceMethod(self, addCVC)) {
        Method implementation = class_getInstanceMethod(self, vdcAddCVC);
        class_addMethod([UIViewController class], addCVC, method_getImplementation(implementation), "v@:@"); 
    }
}

+ (void)load {
    [super load];
    [self vdc_swizzle];
}


@end

@implementation UIViewController (UIViewDeckController_ViewContainmentEmulation_Fakes) 

- (BOOL)vdc_shouldRelay {
    if (self.viewDeckController)
        return [self.viewDeckController vdc_shouldRelay];
    
    return ![self respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)] || ![self performSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)];
}

- (void)vdc_addChildViewController:(UIViewController *)childController {
    // intentionally empty
}

- (void)vdc_removeFromParentViewController {
    // intentionally empty
}

- (void)vdc_willMoveToParentViewController:(UIViewController *)parent {
    // intentionally empty
}

- (void)vdc_didMoveToParentViewController:(UIViewController *)parent {
    // intentionally empty
}

- (void)vdc_viewWillAppear:(bool)animated {
    if (![self vdc_shouldRelay])
        return;
    
    [self viewWillAppear:animated];
}

- (void)vdc_viewDidAppear:(bool)animated{
    if (![self vdc_shouldRelay])
        return;
    
    [self viewDidAppear:animated];
}

- (void)vdc_viewWillDisappear:(bool)animated{
    if (![self vdc_shouldRelay])
        return;
    
    [self viewWillDisappear:animated];
}

- (void)vdc_viewDidDisappear:(bool)animated{
    if (![self vdc_shouldRelay])
        return;
    
    [self viewDidDisappear:animated];
}


@end
