//
//  IIViewDeckController.m
//  IIViewDeck
//
//  Copyright (C) 2011-2013, Tom Adriaenssen
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
#import "IIWrapController.h"


enum {
    IIViewDeckNoSide = 0,
    IIViewDeckCenterSide = 5,
};

enum {
    IIViewDeckNoOrientation = 0,
};

inline NSString* NSStringFromIIViewDeckSide(IIViewDeckSide side) {
    switch (side) {
        case IIViewDeckLeftSide:
            return @"left";
            
        case IIViewDeckRightSide:
            return @"right";

        case IIViewDeckTopSide:
            return @"top";

        case IIViewDeckBottomSide:
            return @"bottom";

        case IIViewDeckNoSide:
            return @"no";

        default:
            return @"unknown";
    }
}

inline IIViewDeckOffsetOrientation IIViewDeckOffsetOrientationFromIIViewDeckSide(IIViewDeckSide side) {
    switch (side) {
        case IIViewDeckLeftSide:
        case IIViewDeckRightSide:
            return IIViewDeckHorizontalOrientation;
            
        case IIViewDeckTopSide:
        case IIViewDeckBottomSide:
            return IIViewDeckVerticalOrientation;
            
        default:
            return IIViewDeckNoOrientation;
    }
}

static const UIViewAnimationOptions DefaultSwipedAnimationCurve = UIViewAnimationOptionCurveEaseOut;

static NSTimeInterval durationToAnimate(CGFloat pointsToAnimate, CGFloat velocity)
{
    NSTimeInterval animationDuration = pointsToAnimate / fabsf(velocity);
    // adjust duration for easing curve, if necessary
    if (DefaultSwipedAnimationCurve != UIViewAnimationOptionCurveLinear) animationDuration *= 1.25;
    return animationDuration;
}

#define DEFAULT_DURATION 0.0

@interface IIViewDeckView : UIView {
    BOOL _userInteractionEnabled;
    BOOL _needsOffsetAdjustment;
}

@property (nonatomic, assign) BOOL allowUserInteractionEnabled;

- (void)setNeedsOffsetAdjustment;
- (BOOL)needsOffsetAdjustment;

@end

@interface UIViewController (UIViewDeckController_ViewContainmentEmulation_Fakes)
- (void)vdc_addChildViewController:(UIViewController *)childController;
- (void)vdc_removeFromParentViewController;
- (void)vdc_willMoveToParentViewController:(UIViewController *)parent;
- (void)vdc_didMoveToParentViewController:(UIViewController *)parent;
@end


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
- (uint)sideControllerCount;

- (CGRect)slidingRectForOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation;
- (CGSize)slidingSizeForOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation;
- (void)setSlidingFrameForOffset:(CGFloat)frame forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated;
- (void)setSlidingFrameForOffset:(CGFloat)offset limit:(BOOL)limit forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated;
- (void)setSlidingFrameForOffset:(CGFloat)offset limit:(BOOL)limit panning:(BOOL)panning forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated;
- (void)panToSlidingFrameForOffset:(CGFloat)frame forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated;
- (void)hideAppropriateSideViews;

- (BOOL)setSlidingAndReferenceViews;
- (void)applyShadowToSlidingViewAnimated:(BOOL)animated;
- (void)restoreShadowToSlidingView;
- (void)arrangeViewsAfterRotation;
- (CGFloat)relativeStatusBarHeight;

- (NSArray *)bouncingValuesForViewSide:(IIViewDeckSide)viewSide maximumBounce:(CGFloat)maxBounce numberOfBounces:(CGFloat)numberOfBounces dampingFactor:(CGFloat)zeta duration:(NSTimeInterval)duration;

- (void)centerViewVisible;
- (void)centerViewHidden;
- (void)centerTapped;
- (void)setAccessibilityForCenterTapper;

- (void)addPanners;
- (void)removePanners;
- (void)setNeedsAddPanners;
- (void)addPannersIfAllPannersAreInactiveAndNeeded;

- (BOOL)checkCanOpenSide:(IIViewDeckSide)viewDeckSide;
- (BOOL)checkCanCloseSide:(IIViewDeckSide)viewDeckSide;
- (void)notifyWillOpenSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)notifyDidOpenSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)notifyWillCloseSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)notifyDidCloseSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)notifyDidChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning;

- (BOOL)checkDelegate:(SEL)selector side:(IIViewDeckSide)viewDeckSize;
- (BOOL)checkDelegate:(SEL)selector view:(UIView*)view;
- (void)performDelegate:(SEL)selector side:(IIViewDeckSide)viewDeckSize animated:(BOOL)animated;
- (void)performDelegate:(SEL)selector side:(IIViewDeckSide)viewDeckSize controller:(UIViewController*)controller;
- (void)performDelegate:(SEL)selector offset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning;

- (void)relayRotationMethod:(void(^)(UIViewController* controller))relay;

- (CGFloat)openSlideDuration:(BOOL)animated;
- (CGFloat)closeSlideDuration:(BOOL)animated;

- (void)enqueueFinishTransitionBlock:(void(^)(void))finishTransition forController:(UIViewController*)controller;
- (void)finishTransitionBlocks;

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

@end


@implementation IIViewDeckController

@synthesize panningMode = _panningMode;
@synthesize panningCancelsTouchesInView = _panningCancelsTouchesInView;
@synthesize panners = _panners;
@synthesize referenceView = _referenceView;
@synthesize slidingController = _slidingController;
@synthesize centerController = _centerController;
@dynamic leftController;
@dynamic rightController;
@dynamic topController;
@dynamic bottomController;
@synthesize shadowEnabled = _shadowEnabled;
@synthesize resizesCenterView = _resizesCenterView;
@synthesize originalShadowOpacity = _originalShadowOpacity;
@synthesize originalShadowPath = _originalShadowPath;
@synthesize originalShadowRadius = _originalShadowRadius;
@synthesize originalShadowColor = _originalShadowColor;
@synthesize originalShadowOffset = _originalShadowOffset;
@synthesize delegate = _delegate;
@synthesize delegateMode = _delegateMode;
@synthesize navigationControllerBehavior = _navigationControllerBehavior;
@synthesize panningView = _panningView; 
@synthesize centerhiddenInteractivity = _centerhiddenInteractivity;
@synthesize centerTapper = _centerTapper;
@synthesize centerView = _centerView;
@synthesize centerViewOpacity = _centerViewOpacity;
@synthesize centerViewCornerRadius = _centerViewCornerRadius;
@synthesize sizeMode = _sizeMode;
@synthesize enabled = _enabled;
@synthesize elastic = _elastic;
@synthesize automaticallyUpdateTabBarItems = _automaticallyUpdateTabBarItems;
@synthesize panningGestureDelegate = _panningGestureDelegate;
@synthesize bounceDurationFactor = _bounceDurationFactor;
@synthesize bounceOpenSideDurationFactor = _bounceOpenSideDurationFactor;
@synthesize openSlideAnimationDuration = _openSlideAnimationDuration;
@synthesize closeSlideAnimationDuration = _closeSlideAnimationDuration;
@synthesize parallaxAmount = _parallaxAmount;
@synthesize centerTapperAccessibilityLabel = _centerTapperAccessibilityLabel;
@synthesize centerTapperAccessibilityHint = _centerTapperAccessibilityHint;

#pragma mark - Initalisation and deallocation

- (void)commonInitWithCenterViewController:(UIViewController *)centerController
{
    _elastic = YES;
    _willAppearShouldArrangeViewsAfterRotation = (UIInterfaceOrientation)UIDeviceOrientationUnknown;
    _panningMode = IIViewDeckFullViewPanning;
    _panningCancelsTouchesInView = YES; // let's default to standard IOS behavior.
    _navigationControllerBehavior = IIViewDeckNavigationControllerContained;
    _centerhiddenInteractivity = IIViewDeckCenterHiddenUserInteractive;
    _sizeMode = IIViewDeckLedgeSizeMode;
    _viewAppeared = 0;
    _viewFirstAppeared = NO;
    _resizesCenterView = NO;
    _automaticallyUpdateTabBarItems = NO;
    _centerViewOpacity = 1;
    _centerViewCornerRadius = 0;
    self.panners = [NSMutableArray array];
    self.enabled = YES;
    _offset = 0;
    _bounceDurationFactor = 0.3;
    _openSlideAnimationDuration = 0.3;
    _closeSlideAnimationDuration = 0.3;
    _offsetOrientation = IIViewDeckHorizontalOrientation;

    _disabledPanClasses = [NSMutableSet setWithObjects:[UISlider class], NSClassFromString(@"UITableViewCellReorderControl"), nil];
    II_RETAIN(_disabledPanClasses);

    _delegate = nil;
    _delegateMode = IIViewDeckDelegateOnly;
    
    self.originalShadowRadius = 0;
    self.originalShadowOffset = CGSizeZero;
    self.originalShadowColor = nil;
    self.originalShadowOpacity = 0;
    self.originalShadowPath = nil;
    
    _slidingController = nil;
    self.centerController = centerController;
    self.leftController = nil;
    self.rightController = nil;
    self.topController = nil;
    self.bottomController = nil;

    _shadowEnabled = YES;
    _shadowLayer = [CALayer new];
    _shadowLayer.masksToBounds = NO;
    _shadowLayer.shadowRadius = 10;
    _shadowLayer.shadowOpacity = 0.5;
    _shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    _shadowLayer.shadowOffset = CGSizeZero;

    _ledge[IIViewDeckLeftSide] = _ledge[IIViewDeckRightSide] = _ledge[IIViewDeckTopSide] = _ledge[IIViewDeckBottomSide] = 44;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitWithCenterViewController:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self commonInitWithCenterViewController:nil];
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        [self commonInitWithCenterViewController:centerController];
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

- (id)initWithCenterViewController:(UIViewController*)centerController topViewController:(UIViewController*)topController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.topController = topController;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController bottomViewController:(UIViewController*)bottomController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.bottomController = bottomController;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController topViewController:(UIViewController*)topController bottomViewController:(UIViewController*)bottomController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.topController = topController;
        self.bottomController = bottomController;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController topViewController:(UIViewController*)topController bottomViewController:(UIViewController*)bottomController {
    if ((self = [self initWithCenterViewController:centerController])) {
        self.leftController = leftController;
        self.rightController = rightController;
        self.topController = topController;
        self.bottomController = bottomController;
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

- (uint)sideControllerCount {
    return (self.leftController ? 1 : 0) + (self.rightController ? 1 : 0) + (self.topController ? 1 : 0) + (self.bottomController ? 1 : 0);
}

- (NSArray*)controllers {
    NSMutableArray *result = [NSMutableArray array];
    if (self.centerController) [result addObject:self.centerController];
    if (self.leftController) [result addObject:self.leftController];
    if (self.rightController) [result addObject:self.rightController];
    if (self.topController) [result addObject:self.topController];
    if (self.bottomController) [result addObject:self.bottomController];
    return [NSArray arrayWithArray:result];
}

- (CGRect)referenceBounds {
    return self.referenceView
        ? self.referenceView.bounds
        : [[UIScreen mainScreen] bounds];
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

- (CGFloat)limitOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation {
    if (orientation == IIViewDeckHorizontalOrientation) {
        if (self.leftController && self.rightController) return offset;

        if (self.leftController && _maxLedge > 0) {
            CGFloat left = self.referenceBounds.size.width - _maxLedge;
            offset = MIN(offset, left);
        }
        else if (self.rightController && _maxLedge > 0) {
            CGFloat right = _maxLedge - self.referenceBounds.size.width;
            offset = MAX(offset, right);
        }
        
        return offset;
    }
    else {
        if (self.topController && self.bottomController) return offset;
        
        if (self.topController && _maxLedge > 0) {
            CGFloat top = self.referenceBounds.size.height - _maxLedge;
            offset = MIN(offset, top);
        }
        else if (self.bottomController && _maxLedge > 0) {
            CGFloat bottom = _maxLedge - self.referenceBounds.size.height;
            offset = MAX(offset, bottom);
        }
        
        return offset;
    }
    
}

- (CGRect)slidingRectForOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation {
    offset = [self limitOffset:offset forOrientation:orientation];
    if (orientation == IIViewDeckHorizontalOrientation) {
        return (CGRect) { {self.resizesCenterView && offset < 0 ? 0 : offset, 0}, [self slidingSizeForOffset:offset forOrientation:orientation] };
    }
    else {
        return (CGRect) { {0, self.resizesCenterView && offset < 0 ? 0 : offset}, [self slidingSizeForOffset:offset forOrientation:orientation] };
    }
}

- (CGSize)slidingSizeForOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation {
    if (!self.resizesCenterView) return self.referenceBounds.size;
    
    offset = [self limitOffset:offset forOrientation:orientation];
    if (orientation == IIViewDeckHorizontalOrientation) {
        return (CGSize) { self.centerViewBounds.size.width - ABS(offset), self.centerViewBounds.size.height };
    }
    else {
        return (CGSize) { self.centerViewBounds.size.width, self.centerViewBounds.size.height - ABS(offset) };
    }
}

-(void)setSlidingFrameForOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated {
    [self setSlidingFrameForOffset:offset limit:YES panning:NO forOrientation:orientation animated:animated];
}

-(void)panToSlidingFrameForOffset:(CGFloat)offset forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated {
    [self setSlidingFrameForOffset:offset limit:YES panning:YES forOrientation:orientation animated:animated];
}

-(void)setSlidingFrameForOffset:(CGFloat)offset limit:(BOOL)limit forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated {
    [self setSlidingFrameForOffset:offset limit:limit panning:NO forOrientation:orientation animated:animated];
}

-(void)setSlidingFrameForOffset:(CGFloat)offset limit:(BOOL)limit panning:(BOOL)panning forOrientation:(IIViewDeckOffsetOrientation)orientation animated:(BOOL)animated {
    CGFloat beforeOffset = _offset;
    if (limit)
        offset = [self limitOffset:offset forOrientation:orientation];
    _offset = offset;
    _offsetOrientation = orientation;

    self.slidingControllerView.frame = [self slidingRectForOffset:_offset forOrientation:orientation];
    
    CABasicAnimation* slidingAnim = (CABasicAnimation*)[self.slidingControllerView.layer animationForKey:@"position"];
    _shadowLayer.frame = self.slidingControllerView.layer.frame;

    CABasicAnimation* anim = [CABasicAnimation animation];
    anim.duration = slidingAnim.duration;
    anim.keyPath = @"position";
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = slidingAnim.fromValue;
    anim.toValue = slidingAnim.toValue ?: [NSValue valueWithCGPoint:self.slidingControllerView.layer.position];
    anim.timingFunction = slidingAnim.timingFunction;
    [_shadowLayer addAnimation:anim forKey:@"position"];
    
    [self setParallax];

    if (beforeOffset != _offset)
        [self notifyDidChangeOffset:_offset orientation:orientation panning:panning];
}

- (void)hideAppropriateSideViews {
    [self hide:(CGRectGetMinX(self.slidingControllerView.frame) <= 0) controllerViewForSide:IIViewDeckLeftSide];
    [self hide:(CGRectGetMaxX(self.slidingControllerView.frame) >= self.referenceBounds.size.width) controllerViewForSide:IIViewDeckRightSide];
    [self hide:(CGRectGetMinY(self.slidingControllerView.frame) <= 0) controllerViewForSide:IIViewDeckTopSide];
    [self hide:(CGRectGetMaxY(self.slidingControllerView.frame) >= self.referenceBounds.size.height) controllerViewForSide:IIViewDeckBottomSide];
}

#pragma mark - ledges

- (void)setSize:(CGFloat)size forSide:(IIViewDeckSide)side completion:(void(^)(BOOL finished))completion {
    // we store ledge sizes internally but allow size to be specified depending on size mode.
    CGFloat ledge = [self sizeAsLedge:size forSide:side];
    
    CGFloat minLedge;
    CGFloat(^offsetter)(CGFloat ledge);
   
    switch (side) {
        case IIViewDeckLeftSide: {
            minLedge = MIN(self.referenceBounds.size.width, ledge);
            offsetter = ^CGFloat(CGFloat l) { return  self.referenceBounds.size.width - l; };
            break;
        }

        case IIViewDeckRightSide: {
            minLedge = MIN(self.referenceBounds.size.width, ledge);
            offsetter = ^CGFloat(CGFloat l) { return l - self.referenceBounds.size.width; };
            break;
        }

        case IIViewDeckTopSide: {
            minLedge = MIN(self.referenceBounds.size.width, ledge);
            offsetter = ^CGFloat(CGFloat l) { return  self.referenceBounds.size.height - l; };
            break;
        }

        case IIViewDeckBottomSide: {
            minLedge = MIN(self.referenceBounds.size.width, ledge);
            offsetter = ^CGFloat(CGFloat l) { return l - self.referenceBounds.size.height; };
            break;
        }
            
        default:
            return;
    }

    ledge = MAX(ledge, minLedge);
    if (_viewFirstAppeared && II_FLOAT_EQUAL(self.slidingControllerView.frame.origin.x, offsetter(_ledge[side]))) {
        IIViewDeckOffsetOrientation orientation = IIViewDeckOffsetOrientationFromIIViewDeckSide(side);
        if (ledge < _ledge[side]) {
            [UIView animateWithDuration:[self closeSlideDuration:YES] animations:^{
                [self setSlidingFrameForOffset:offsetter(ledge) forOrientation:orientation animated:YES];
            } completion:completion];
        }
        else if (ledge > _ledge[side]) {
            [UIView animateWithDuration:[self openSlideDuration:YES] animations:^{
                [self setSlidingFrameForOffset:offsetter(ledge) forOrientation:orientation animated:YES];
            } completion:completion];
        }
    }
    
    [self setLedgeValue:ledge forSide:side];
}

- (CGFloat)sizeForSide:(IIViewDeckSide)side {
    return [self ledgeAsSize:_ledge[side] forSide:side];
}

#pragma mark left size

- (void)setLeftSize:(CGFloat)leftSize {
    [self setLeftSize:leftSize completion:nil];
}

- (void)setLeftSize:(CGFloat)leftSize completion:(void(^)(BOOL finished))completion {
    [self setSize:leftSize forSide:IIViewDeckLeftSide completion:completion];
}

- (CGFloat)leftSize {
    return [self sizeForSide:IIViewDeckLeftSide];
}

- (CGFloat)leftViewSize {
    return [self ledgeAsSize:_ledge[IIViewDeckLeftSide] mode:IIViewDeckViewSizeMode forSide:IIViewDeckLeftSide];
}

- (CGFloat)leftLedgeSize {
    return [self ledgeAsSize:_ledge[IIViewDeckLeftSide] mode:IIViewDeckLedgeSizeMode forSide:IIViewDeckLeftSide];
}

#pragma mark right size

- (void)setRightSize:(CGFloat)rightSize {
    [self setRightSize:rightSize completion:nil];
}

- (void)setRightSize:(CGFloat)rightSize completion:(void(^)(BOOL finished))completion {
    [self setSize:rightSize forSide:IIViewDeckRightSide completion:completion];
}
    
- (CGFloat)rightSize {
    return [self sizeForSide:IIViewDeckRightSide];
}

- (CGFloat)rightViewSize {
    return [self ledgeAsSize:_ledge[IIViewDeckRightSide] mode:IIViewDeckViewSizeMode forSide:IIViewDeckRightSide];
}

- (CGFloat)rightLedgeSize {
    return [self ledgeAsSize:_ledge[IIViewDeckRightSide] mode:IIViewDeckLedgeSizeMode forSide:IIViewDeckRightSide];
}


#pragma mark top size

- (void)setTopSize:(CGFloat)leftSize {
    [self setTopSize:leftSize completion:nil];
}

- (void)setTopSize:(CGFloat)topSize completion:(void(^)(BOOL finished))completion {
    [self setSize:topSize forSide:IIViewDeckTopSide completion:completion];
}

- (CGFloat)topSize {
    return [self sizeForSide:IIViewDeckTopSide];
}

- (CGFloat)topViewSize {
    return [self ledgeAsSize:_ledge[IIViewDeckTopSide] mode:IIViewDeckViewSizeMode forSide:IIViewDeckTopSide];
}

- (CGFloat)topLedgeSize {
    return [self ledgeAsSize:_ledge[IIViewDeckTopSide] mode:IIViewDeckLedgeSizeMode forSide:IIViewDeckTopSide];
}


#pragma mark Bottom size

- (void)setBottomSize:(CGFloat)bottomSize {
    [self setBottomSize:bottomSize completion:nil];
}

- (void)setBottomSize:(CGFloat)bottomSize completion:(void(^)(BOOL finished))completion {
    [self setSize:bottomSize forSide:IIViewDeckBottomSide completion:completion];
}

- (CGFloat)bottomSize {
    return [self sizeForSide:IIViewDeckBottomSide];
}

- (CGFloat)bottomViewSize {
    return [self ledgeAsSize:_ledge[IIViewDeckBottomSide] mode:IIViewDeckViewSizeMode forSide:IIViewDeckBottomSide];
}

- (CGFloat)bottomLedgeSize {
    return [self ledgeAsSize:_ledge[IIViewDeckBottomSide] mode:IIViewDeckLedgeSizeMode forSide:IIViewDeckBottomSide];
}


#pragma mark max size

- (void)setMaxSize:(CGFloat)maxSize {
    [self setMaxSize:maxSize completion:nil];
}

- (void)setMaxSize:(CGFloat)maxSize completion:(void(^)(BOOL finished))completion {
    if ([self sideControllerCount] > 1) {
        NSLog(@"IIViewDeckController: warning: setting maxLedge with more than one side controllers. Value will be ignored.");
        return;
    }
    
    [self doForControllers:^(UIViewController* controller, IIViewDeckSide side) {
        if (controller) {
            _maxLedge = [self sizeAsLedge:maxSize forSide:side];
            if (_ledge[side] > _maxLedge)
                [self setSize:maxSize forSide:side completion:completion];
            else if (completion)
                completion(NO);
            [self setSlidingFrameForOffset:_offset forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:YES]; // should be animated
        }
    }];
}

- (CGFloat)maxSize {
    return _maxLedge;
}

- (CGFloat)sizeAsLedge:(CGFloat)size forSide:(IIViewDeckSide)side {
    if (_sizeMode == IIViewDeckLedgeSizeMode)
        return size;
    else {
        return ((side == IIViewDeckLeftSide || side == IIViewDeckRightSide)
                ? self.referenceBounds.size.width : self.referenceBounds.size.height) - size;
    }
}

- (CGFloat)ledgeAsSize:(CGFloat)ledge forSide:(IIViewDeckSide)side {
    return [self ledgeAsSize:ledge mode:_sizeMode forSide:side];
}

- (CGFloat)ledgeAsSize:(CGFloat)ledge mode:(IIViewDeckSizeMode)mode forSide:(IIViewDeckSide)side {
    if (mode == IIViewDeckLedgeSizeMode)
        return ledge;
    else
        return ((side == IIViewDeckLeftSide || side == IIViewDeckRightSide)
                ? self.referenceBounds.size.width : self.referenceBounds.size.height) - ledge;
}

#pragma mark - View lifecycle

- (void)loadView
{
    _offset = 0;
    _viewFirstAppeared = NO;
    _viewAppeared = 0;
    
    self.view = II_AUTORELEASE([[IIViewDeckView alloc] init]);
    if ([[self presentingViewController] isKindOfClass:[UINavigationController class]])
        [((IIViewDeckView*)self.view) setNeedsOffsetAdjustment];
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

#pragma mark - View Containment


- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return NO;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}

- (BOOL)safe_shouldManageAppearanceMethods {
    if ([[UIViewController class] instancesRespondToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)] ) { // on iOS6 or later
        return ![self shouldAutomaticallyForwardAppearanceMethods];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return ![self automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers];
#pragma clang diagnostic pop
}

- (BOOL)safe_shouldForwardRotationMethods {
    if ([[UIViewController class] instancesRespondToSelector:@selector(shouldAutomaticallyForwardRotationMethods)] ) { // on iOS6 or later
        return ![self shouldAutomaticallyForwardRotationMethods];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return ![self automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers];
#pragma clang diagnostic pop
}


#pragma mark - Appearance

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];

    if (!_viewFirstAppeared) {
        _viewFirstAppeared = YES;
        
        void(^applyViews)(void) = ^{
            [self.centerController.view removeFromSuperview];
            [self.centerView addSubview:self.centerController.view];
            
            [self doForControllers:^(UIViewController* controller, IIViewDeckSide side) {
                [controller.view removeFromSuperview];
                [self.referenceView insertSubview:controller.view belowSubview:self.slidingControllerView];
            }];
            
            [self setSlidingFrameForOffset:_offset forOrientation:_offsetOrientation animated:YES];
            self.slidingControllerView.hidden = NO;
            
            self.centerView.frame = self.centerViewBounds;
            self.centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.centerController.view.frame = self.centerView.bounds;
            [self doForControllers:^(UIViewController* controller, IIViewDeckSide side) {
                controller.view.frame = self.sideViewBounds;
                controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }];
            
            [self applyCenterViewCornerRadiusAnimated:NO];
            [self applyShadowToSlidingViewAnimated:NO];
            [self applyCenterViewOpacityIfNeeded];
        };
        
        if ([self setSlidingAndReferenceViews]) {
            applyViews();
            applyViews = nil;
        }
        
        // after 0.01 sec, since in certain cases the sliding view is reset.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            if (applyViews) applyViews();
            [self setSlidingFrameForOffset:_offset forOrientation:_offsetOrientation animated:YES];
            [self hideAppropriateSideViews];
        });
        
        [self setNeedsAddPanners];
        
        if ([self isSideClosed:IIViewDeckLeftSide] && [self isSideClosed:IIViewDeckRightSide] && [self isSideClosed:IIViewDeckTopSide] && [self isSideClosed:IIViewDeckBottomSide])
            [self centerViewVisible];
        else
            [self centerViewHidden];
    }
    else if (_willAppearShouldArrangeViewsAfterRotation != UIDeviceOrientationUnknown) {
        [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
        [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
        [self didRotateFromInterfaceOrientation:_willAppearShouldArrangeViewsAfterRotation];
    }
    
    if ([self safe_shouldManageAppearanceMethods]) [self.centerController viewWillAppear:animated];
    [self transitionAppearanceFrom:0 to:1 animated:animated];

    if (self.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.slidingControllerView.frame = (CGRect) { _willAppearOffset, self.slidingControllerView.frame.size };
        });
    }
    
    _viewAppeared = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self safe_shouldManageAppearanceMethods]) [self.centerController viewDidAppear:animated];
    [self transitionAppearanceFrom:1 to:2 animated:animated];
    _viewAppeared = 2;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self safe_shouldManageAppearanceMethods]) [self.centerController viewWillDisappear:animated];
    [self transitionAppearanceFrom:2 to:1 animated:animated];
    _viewAppeared = 1;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated)
        _willAppearOffset = self.slidingControllerView.frame.origin;

    @try {
        [self.view removeObserver:self forKeyPath:@"bounds"];
    } @catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    
    if ([self safe_shouldManageAppearanceMethods]) [self.centerController viewDidDisappear:animated];
    [self transitionAppearanceFrom:1 to:0 animated:animated];
    _viewAppeared = 0;
}

#pragma mark - Rotation IOS6

- (BOOL)shouldAutorotate {
    _preRotationSize = self.referenceBounds.size;
    _preRotationCenterSize = self.centerView.bounds.size;
    _willAppearShouldArrangeViewsAfterRotation = self.interfaceOrientation;
    
    // give other controllers a chance to act on it too
    [self relayRotationMethod:^(UIViewController *controller) {
        [controller shouldAutorotate];
    }];

    return !self.centerController || [self.centerController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (self.centerController)
        return [self.centerController supportedInterfaceOrientations];
    
    return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.centerController)
        return [self.centerController preferredInterfaceOrientationForPresentation];
    
    return [super preferredInterfaceOrientationForPresentation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _preRotationSize = self.referenceBounds.size;
    _preRotationCenterSize = self.centerView.bounds.size;
    _preRotationIsLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    _willAppearShouldArrangeViewsAfterRotation = interfaceOrientation;
    
    // give other controllers a chance to act on it too
    [self relayRotationMethod:^(UIViewController *controller) {
        [controller shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }];

    return !self.centerController || [self.centerController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self arrangeViewsAfterRotation];
    
    [self relayRotationMethod:^(UIViewController *controller) {
        [controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }];

    [self applyCenterViewCornerRadiusAnimated:YES];
    [self applyShadowToSlidingViewAnimated:YES];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (_preRotationSize.width == 0) {
        _preRotationSize = self.referenceBounds.size;
        _preRotationCenterSize = self.centerView.bounds.size;
        _preRotationIsLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    }
    
    [self relayRotationMethod:^(UIViewController *controller) {
        [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self relayRotationMethod:^(UIViewController *controller) {
        [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }];
    
    [self setAccessibilityForCenterTapper]; // update since the frame and the frame's intersection with the window will have changed
}

- (void)arrangeViewsAfterRotation {
    _willAppearShouldArrangeViewsAfterRotation = (UIInterfaceOrientation)UIDeviceOrientationUnknown;
    if (_preRotationSize.width <= 0 || _preRotationSize.height <= 0) return;
    
    CGFloat offset, max, preSize;
    IIViewDeckSide adjustOffset = IIViewDeckNoSide;
    if (_offsetOrientation == IIViewDeckVerticalOrientation) {
        offset = self.slidingControllerView.frame.origin.y;
        max = self.referenceBounds.size.height;
        preSize = _preRotationSize.height;
        if (self.resizesCenterView && II_FLOAT_EQUAL(offset, 0)) {
            offset = offset + (_preRotationCenterSize.height - _preRotationSize.height);
        }
        if (!II_FLOAT_EQUAL(offset, 0)) {
            if (II_FLOAT_EQUAL(offset, preSize - _ledge[IIViewDeckTopSide]))
                adjustOffset = IIViewDeckTopSide;
            else if (II_FLOAT_EQUAL(offset, _ledge[IIViewDeckBottomSide] - preSize))
                adjustOffset = IIViewDeckBottomSide;
        }
    }
    else {
        offset = self.slidingControllerView.frame.origin.x;
        max = self.referenceBounds.size.width;
        preSize = _preRotationSize.width;
        if (self.resizesCenterView && II_FLOAT_EQUAL(offset, 0)) {
            offset = offset + (_preRotationCenterSize.width - _preRotationSize.width);
        }
        if (!II_FLOAT_EQUAL(offset, 0)) {
            if (II_FLOAT_EQUAL(offset, preSize - _ledge[IIViewDeckLeftSide]))
                adjustOffset = IIViewDeckLeftSide;
            else if (II_FLOAT_EQUAL(offset, _ledge[IIViewDeckRightSide] - preSize))
                adjustOffset = IIViewDeckRightSide;
        }
    }
    
    if (self.sizeMode != IIViewDeckLedgeSizeMode) {
        if (_maxLedge != 0)
            _maxLedge = _maxLedge + max - preSize;

        [self setLedgeValue:_ledge[IIViewDeckLeftSide] + self.referenceBounds.size.width - _preRotationSize.width forSide:IIViewDeckLeftSide];
        [self setLedgeValue:_ledge[IIViewDeckRightSide] + self.referenceBounds.size.width - _preRotationSize.width forSide:IIViewDeckRightSide];
        [self setLedgeValue:_ledge[IIViewDeckTopSide] + self.referenceBounds.size.height - _preRotationSize.height forSide:IIViewDeckTopSide];
        [self setLedgeValue:_ledge[IIViewDeckBottomSide] + self.referenceBounds.size.height - _preRotationSize.height forSide:IIViewDeckBottomSide];
    }
    else {
        if (offset > 0) {
            offset = max - preSize + offset;
        }
        else if (offset < 0) {
            offset = offset + preSize - max;
        }
    }
    
    switch (adjustOffset) {
        case IIViewDeckLeftSide:
            offset = self.referenceBounds.size.width - _ledge[adjustOffset];
            break;

        case IIViewDeckRightSide:
            offset = _ledge[adjustOffset] - self.referenceBounds.size.width;
            break;

        case IIViewDeckTopSide:
            offset = self.referenceBounds.size.height - _ledge[adjustOffset];
            break;

        case IIViewDeckBottomSide:
            offset = _ledge[adjustOffset] - self.referenceBounds.size.height;
            break;

        default:
            break;
    }
    [self setSlidingFrameForOffset:offset forOrientation:_offsetOrientation animated:NO];
    
    _preRotationSize = CGSizeZero;
}

- (void)setLedgeValue:(CGFloat)ledge forSide:(IIViewDeckSide)side {
    if (_maxLedge > 0)
        ledge = MIN(_maxLedge, ledge);

    _ledge[side] = [self performDelegate:@selector(viewDeckController:changesLedge:forSide:) ledge:ledge side:side];
}

#pragma mark - Notify

- (CGFloat)ledgeOffsetForSide:(IIViewDeckSide)viewDeckSide {
    switch (viewDeckSide) {
        case IIViewDeckLeftSide:
            return self.referenceBounds.size.width - _ledge[viewDeckSide];
            break;
            
        case IIViewDeckRightSide:
            return _ledge[viewDeckSide] - self.referenceBounds.size.width;
            break;
            
        case IIViewDeckTopSide:
            return self.referenceBounds.size.height - _ledge[viewDeckSide];
            
        case IIViewDeckBottomSide:
            return _ledge[viewDeckSide] - self.referenceBounds.size.height;
    }
    
    return 0;
}

- (void)doForControllers:(void(^)(UIViewController* controller, IIViewDeckSide side))action {
    if (!action) return;
    for (IIViewDeckSide side=IIViewDeckLeftSide; side<=IIViewDeckBottomSide; side++) {
        action(_controllers[side], side);
    }
}

- (UIViewController*)controllerForSide:(IIViewDeckSide)viewDeckSide {
    return viewDeckSide == IIViewDeckNoSide ? nil : _controllers[viewDeckSide];
}

- (IIViewDeckSide)oppositeOfSide:(IIViewDeckSide)viewDeckSide {
    switch (viewDeckSide) {
        case IIViewDeckLeftSide:
            return IIViewDeckRightSide;
            
        case IIViewDeckRightSide:
            return IIViewDeckLeftSide;
            
        case IIViewDeckTopSide:
            return IIViewDeckBottomSide;
            
        case IIViewDeckBottomSide:
            return IIViewDeckTopSide;
            
        default:
            return IIViewDeckNoSide;
    }
}

- (IIViewDeckSide)sideForController:(UIViewController*)controller {
    for (IIViewDeckSide side=IIViewDeckLeftSide; side<=IIViewDeckBottomSide; side++) {
        if (_controllers[side] == controller) return side;
    }
    
    return NSNotFound;
}




- (BOOL)checkCanOpenSide:(IIViewDeckSide)viewDeckSide {
    return ![self isSideOpen:viewDeckSide] && [self checkDelegate:@selector(viewDeckController:shouldOpenViewSide:) side:viewDeckSide];
}

- (BOOL)checkCanCloseSide:(IIViewDeckSide)viewDeckSide {
    return ![self isSideClosed:viewDeckSide] && [self checkDelegate:@selector(viewDeckController:shouldCloseViewSide:animated:) side:viewDeckSide];
}

- (void)notifyWillOpenSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckNoSide) return;
    [self notifyAppearanceForSide:viewDeckSide animated:animated from:0 to:1];

    if ([self isSideClosed:viewDeckSide]) {
        [self performDelegate:@selector(viewDeckController:willOpenViewSide:animated:) side:viewDeckSide animated:animated];
    }
}

- (void)notifyDidOpenSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckNoSide) return;
    [self notifyAppearanceForSide:viewDeckSide animated:animated from:1 to:2];

    if ([self isSideOpen:viewDeckSide]) {
        [self performDelegate:@selector(viewDeckController:didOpenViewSide:animated:) side:viewDeckSide animated:animated];
    }
}

- (void)notifyWillCloseSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckNoSide) return;
    [self notifyAppearanceForSide:viewDeckSide animated:animated from:2 to:1];

    if (![self isSideClosed:viewDeckSide]) {
        [self performDelegate:@selector(viewDeckController:willCloseViewSide:animated:) side:viewDeckSide animated:animated];
    }
}

- (void)notifyDidCloseSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckNoSide) return;

    [self notifyAppearanceForSide:viewDeckSide animated:animated from:1 to:0];
    if ([self isSideClosed:viewDeckSide]) {
        [self performDelegate:@selector(viewDeckController:didCloseViewSide:animated:) side:viewDeckSide animated:animated];
        [self performDelegate:@selector(viewDeckController:didShowCenterViewFromSide:animated:) side:viewDeckSide animated:animated];
    }
}

- (void)notifyDidChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    [self performDelegate:@selector(viewDeckController:didChangeOffset:orientation:panning:) offset:offset orientation:orientation panning:panning];
}

- (void)notifyAppearanceForSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated from:(int)from to:(int)to {
    if (viewDeckSide == IIViewDeckNoSide)
        return;
    
    if (_viewAppeared < to) {
        _sideAppeared[viewDeckSide] = to;
        return;
    }

    SEL selector = nil;
    if (from < to) {
        if (_sideAppeared[viewDeckSide] > from)
            return;
        
        if (to == 1)
            selector = @selector(viewWillAppear:);
        else if (to == 2)
            selector = @selector(viewDidAppear:);
    }
    else {
        if (_sideAppeared[viewDeckSide] < from)
            return;

        if (to == 1)
            selector = @selector(viewWillDisappear:);
        else if (to == 0)
            selector = @selector(viewDidDisappear:);
    }
    
    _sideAppeared[viewDeckSide] = to;
    
    if ([self safe_shouldManageAppearanceMethods] && selector) {
        UIViewController* controller = [self controllerForSide:viewDeckSide];
        controller.view.tag = controller.view.tag; // access view property so that viewDidLoad is called before viewWillAppear is view is not loaded
        BOOL (*objc_msgSendTyped)(id self, SEL _cmd, BOOL animated) = (void*)objc_msgSend;
        objc_msgSendTyped(controller, selector, animated);
    }
}

- (void)transitionAppearanceFrom:(int)from to:(int)to animated:(BOOL)animated {
    SEL selector = nil;
    if (from < to) {
        if (to == 1)
            selector = @selector(viewWillAppear:);
        else if (to == 2)
            selector = @selector(viewDidAppear:);
    }
    else {
        if (to == 1)
            selector = @selector(viewWillDisappear:);
        else if (to == 0)
            selector = @selector(viewDidDisappear:);
    }
    
    [self doForControllers:^(UIViewController *controller, IIViewDeckSide side) {
        if (from < to && _sideAppeared[side] <= from)
            return;
        else if (from > to && _sideAppeared[side] >= from)
            return;
        
        if ([self safe_shouldManageAppearanceMethods] && selector && controller) {
            BOOL (*objc_msgSendTyped)(id self, SEL _cmd, BOOL animated) = (void*)objc_msgSend;
            objc_msgSendTyped(controller, selector, animated);
        }
    }];
}



#pragma mark - controller state

-(void)setCenterhiddenInteractivity:(IIViewDeckCenterHiddenInteractivity)centerhiddenInteractivity {
    _centerhiddenInteractivity = centerhiddenInteractivity;
    
    if ([self isAnySideOpen]) {
        if (IIViewDeckCenterHiddenIsInteractive(self.centerhiddenInteractivity)) {
            [self centerViewVisible];
        } else {
            [self centerViewHidden];
        }
    }
}

- (BOOL)isSideClosed:(IIViewDeckSide)viewDeckSide {
    if (![self controllerForSide:viewDeckSide])
        return YES;
    
    switch (viewDeckSide) {
        case IIViewDeckLeftSide:
            return CGRectGetMinX(self.slidingControllerView.frame) <= 0;
            
        case IIViewDeckRightSide:
            return CGRectGetMaxX(self.slidingControllerView.frame) >= self.referenceBounds.size.width;
            
        case IIViewDeckTopSide:
            return CGRectGetMinY(self.slidingControllerView.frame) <= 0;
            
        case IIViewDeckBottomSide:
            return CGRectGetMaxY(self.slidingControllerView.frame) >= self.referenceBounds.size.height;
            
        default:
            return YES;
    }
}


- (BOOL)isAnySideOpen {
    return [self isSideOpen:IIViewDeckLeftSide] || [self isSideOpen:IIViewDeckRightSide] || [self isSideOpen:IIViewDeckTopSide] || [self isSideOpen:IIViewDeckBottomSide];
}


- (BOOL)isSideOpen:(IIViewDeckSide)viewDeckSide {
    if (![self controllerForSide:viewDeckSide])
        return NO;
    
    switch (viewDeckSide) {
        case IIViewDeckLeftSide:
            return II_FLOAT_EQUAL(CGRectGetMinX(self.slidingControllerView.frame), self.referenceBounds.size.width - _ledge[IIViewDeckLeftSide]);
            
        case IIViewDeckRightSide: {
            return II_FLOAT_EQUAL(CGRectGetMaxX(self.slidingControllerView.frame), _ledge[IIViewDeckRightSide]);
        }

        case IIViewDeckTopSide:
            return II_FLOAT_EQUAL(CGRectGetMinY(self.slidingControllerView.frame), self.referenceBounds.size.height - _ledge[IIViewDeckTopSide]);

        case IIViewDeckBottomSide:
            return II_FLOAT_EQUAL(CGRectGetMaxY(self.slidingControllerView.frame), _ledge[IIViewDeckBottomSide]);

        default:
            return NO;
    }
}

- (BOOL)isSideTransitioning:(IIViewDeckSide)viewDeckSide {
    return ![self isSideClosed:viewDeckSide] && ![self isSideOpen:viewDeckSide];
}

- (BOOL)openSideView:(IIViewDeckSide)side animated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:side animated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)openSideView:(IIViewDeckSide)side animated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    // if there's no controller or we're already open, just run the completion and say we're done.
    if (![self controllerForSide:side] || [self isSideOpen:side]) {
        if (completed) completed(self, YES);
        return YES;
    }
    
    // check the delegate to allow opening
    if (![self checkCanOpenSide:side]) {
        if (completed) completed(self, NO);
        return NO;
    };
    
    if (![self isSideClosed:[self oppositeOfSide:side]]) {
        return [self toggleOpenViewAnimated:animated completion:completed];
    }
    
    if (duration == DEFAULT_DURATION) duration = [self openSlideDuration:animated];
    
    __block UIViewAnimationOptions options = UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
    
    IIViewDeckControllerBlock finish = ^(IIViewDeckController *controller, BOOL success) {
        if (!success) {
            if (completed) completed(self, NO);
            return;
        }
        
        [self notifyWillOpenSide:side animated:animated];
        [self disableUserInteraction];
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            [self hide:NO controllerViewForSide:side];
            [self setSlidingFrameForOffset:[self ledgeOffsetForSide:side] forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:YES];
            [self centerViewHidden];
        } completion:^(BOOL finished) {
            [self enableUserInteraction];
            [self setAccessibilityForCenterTapper]; // update since the frame and the frame's intersection with the window will have changed
            if (completed) completed(self, YES);
            [self notifyDidOpenSide:side animated:animated];
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        }];
    };
    
    if ([self isSideClosed:side]) {
        // try to close any open view first
        return [self closeOpenViewAnimated:animated completion:finish];
    }
    else {
        options |= UIViewAnimationOptionCurveEaseOut;

        finish(self, YES);
        return YES;
    }
}

- (void)hide:(BOOL)hidden controllerViewForSide:(IIViewDeckSide)side  {
    if ([self sideControllerCount] > 1)
        [self controllerForSide:side].view.hidden = hidden;
    else
        [self controllerForSide:side].view.hidden = NO;
}

- (BOOL)openSideView:(IIViewDeckSide)side bounceOffset:(CGFloat)bounceOffset targetOffset:(CGFloat)targetOffset bounced:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    BOOL animated = YES;
    
    // if there's no controller or we're already open, just run the completion and say we're done.
    if (![self controllerForSide:side] || [self isSideOpen:side]) {
        if (completed) completed(self, YES);
        return YES;
    }
    
    // check the delegate to allow opening
    if (![self checkCanOpenSide:side]) {
        if (completed) completed(self, NO);
        return NO;
    };
    
    UIViewAnimationOptions options = UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
    if ([self isSideClosed:side]) options |= UIViewAnimationOptionCurveEaseIn;

    return [self closeOpenViewAnimated:animated completion:^(IIViewDeckController *controller, BOOL success) {
        if (!success) {
            if (completed) completed(self, NO);
            return;
        }
        
        CGFloat longFactor = _bounceDurationFactor ? _bounceDurationFactor : 1;
        CGFloat shortFactor = _bounceOpenSideDurationFactor ? _bounceOpenSideDurationFactor : (_bounceDurationFactor ? 1-_bounceDurationFactor : 1);
      
        // first open the view completely, run the block (to allow changes)
        [self notifyWillOpenSide:side animated:animated];
        [self disableUserInteraction];
        [UIView animateWithDuration:[self openSlideDuration:YES]*longFactor delay:0 options:options animations:^{
            [self hide:NO controllerViewForSide:side];
            [self setSlidingFrameForOffset:bounceOffset forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:YES];
        } completion:^(BOOL finished) {
            [self centerViewHidden];
            // run block if it's defined
            if (bounced) bounced(self);
            [self performDelegate:@selector(viewDeckController:didBounceViewSide:openingController:) side:side controller:_controllers[side]];
            
            // now slide the view back to the ledge position
            [UIView animateWithDuration:[self openSlideDuration:YES]*shortFactor delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self setSlidingFrameForOffset:targetOffset forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:YES];
            } completion:^(BOOL finished) {
                [self enableUserInteraction];
                [self setAccessibilityForCenterTapper]; // update since the frame and the frame's intersection with the window will have changed
                if (completed) completed(self, YES);
                [self notifyDidOpenSide:side animated:animated];
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            }];
        }];
    }];
}


- (BOOL)closeSideView:(IIViewDeckSide)side animated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:side animated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)closeSideView:(IIViewDeckSide)side animated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    if ([self isSideClosed:side]) {
        if (completed) completed(self, YES);
        return YES;
    }
    
    // check the delegate to allow closing
    if (![self checkCanCloseSide:side]) {
        if (completed) completed(self, NO);
        return NO;
    }
    
    if (duration == DEFAULT_DURATION) duration = [self closeSlideDuration:animated];
    
    UIViewAnimationOptions options = UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
    options |= [self isSideOpen:side] ? UIViewAnimationOptionCurveEaseInOut : UIViewAnimationOptionCurveEaseOut;
    
    [self notifyWillCloseSide:side animated:animated];
    [self disableUserInteraction];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self setSlidingFrameForOffset:0 forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:animated];
        [self centerViewVisible];
    } completion:^(BOOL finished) {
        [self hideAppropriateSideViews];
        [self enableUserInteraction];
        if (completed) completed(self, YES);
        [self notifyDidCloseSide:side animated:animated];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    }];
    
    return YES;
}

- (CGFloat)openSlideDuration:(BOOL)animated {
    return animated ? self.openSlideAnimationDuration : 0;
}

- (CGFloat)closeSlideDuration:(BOOL)animated {
    return animated ? self.closeSlideAnimationDuration : 0;
}


- (BOOL)closeSideView:(IIViewDeckSide)side bounceOffset:(CGFloat)bounceOffset bounced:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    if ([self isSideClosed:side]) {
        if (completed) completed(self, YES);
        return YES;
    }
    
    // check the delegate to allow closing
    if (![self checkCanCloseSide:side]) {
        if (completed) completed(self, NO);
        return NO;
    }
    
    UIViewAnimationOptions options = UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
    if ([self isSideOpen:side]) options |= UIViewAnimationOptionCurveEaseIn;
    
    BOOL animated = YES;
    
    CGFloat longFactor = _bounceDurationFactor ? _bounceDurationFactor : 1;
    CGFloat shortFactor = _bounceOpenSideDurationFactor ? _bounceOpenSideDurationFactor : (_bounceDurationFactor ? 1-_bounceDurationFactor : 1);
  
    // first open the view completely, run the block (to allow changes) and close it again.
    [self notifyWillCloseSide:side animated:animated];
    [self disableUserInteraction];
    [UIView animateWithDuration:[self openSlideDuration:YES]*shortFactor delay:0 options:options animations:^{
        [self setSlidingFrameForOffset:bounceOffset forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:YES];
    } completion:^(BOOL finished) {
        // run block if it's defined
        if (bounced) bounced(self);
        [self performDelegate:@selector(viewDeckController:didBounceViewSide:closingController:) side:side controller:_controllers[side]];
        
        [UIView animateWithDuration:[self closeSlideDuration:YES]*longFactor delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            [self setSlidingFrameForOffset:0 forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(side) animated:YES];
            [self centerViewVisible];
        } completion:^(BOOL finished2) {
            [self hideAppropriateSideViews];
            [self enableUserInteraction];
            if (completed) completed(self, YES);
            [self notifyDidCloseSide:side animated:animated];
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        }];
    }];
    
    return YES;
}


#pragma mark - Left Side

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
    if ([self isSideClosed:IIViewDeckLeftSide]) 
        return [self openLeftViewAnimated:animated completion:completed];
    else
        return [self closeLeftViewAnimated:animated completion:completed];
}

- (BOOL)openLeftViewAnimated:(BOOL)animated {
    return [self openLeftViewAnimated:animated completion:nil];
}

- (BOOL)openLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckLeftSide animated:animated completion:completed];
}

- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self openLeftViewBouncing:bounced completion:nil];
}

- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckLeftSide bounceOffset:self.referenceBounds.size.width targetOffset:self.referenceBounds.size.width - _ledge[IIViewDeckLeftSide] bounced:bounced completion:completed];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated {
    return [self closeLeftViewAnimated:animated completion:nil];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeLeftViewAnimated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckLeftSide animated:animated duration:duration completion:completed];
}

- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self closeLeftViewBouncing:bounced completion:nil];
}

- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckLeftSide bounceOffset:self.referenceBounds.size.width bounced:bounced completion:completed];
}

#pragma mark - Right Side

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
    if ([self isSideClosed:IIViewDeckRightSide]) 
        return [self openRightViewAnimated:animated completion:completed];
    else
        return [self closeRightViewAnimated:animated completion:completed];
}

- (BOOL)openRightViewAnimated:(BOOL)animated {
    return [self openRightViewAnimated:animated completion:nil];
}

- (BOOL)openRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckRightSide animated:animated completion:completed];
}

- (BOOL)openRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self openRightViewBouncing:bounced completion:nil];
}

- (BOOL)openRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckRightSide bounceOffset:-self.referenceBounds.size.width targetOffset:_ledge[IIViewDeckRightSide] - self.referenceBounds.size.width bounced:bounced completion:completed];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated {
    return [self closeRightViewAnimated:animated completion:nil];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeRightViewAnimated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckRightSide animated:animated duration:duration completion:completed];
}

- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self closeRightViewBouncing:bounced completion:nil];
}

- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckRightSide bounceOffset:-self.referenceBounds.size.width bounced:bounced completion:completed];
}

#pragma mark - right view, special case for navigation stuff

- (BOOL)canRightViewPushViewControllerOverCenterController {
    return [self.centerController isKindOfClass:[UINavigationController class]];
}

- (void)rightViewPushViewControllerOverCenterController:(UIViewController*)controller {
    NSAssert([self.centerController isKindOfClass:[UINavigationController class]], @"cannot rightViewPushViewControllerOverCenterView when center controller is not a navigation controller");

    UIView* view = self.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *deckshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView* shotView = [[UIImageView alloc] initWithImage:deckshot];
    shotView.frame = view.frame; 
    [view.superview addSubview:shotView];
    CGRect targetFrame = view.frame; 
    view.frame = CGRectOffset(view.frame, view.frame.size.width, 0);
    
    [self closeRightViewAnimated:NO];
    UINavigationController* navController = self.centerController.navigationController ? self.centerController.navigationController :(UINavigationController*)self.centerController;
    [navController pushViewController:controller animated:NO];
    
    [self disableUserInteraction];
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        shotView.frame = CGRectOffset(shotView.frame, -view.frame.size.width, 0);
        view.frame = targetFrame;
    } completion:^(BOOL finished) {
        [self enableUserInteraction];
        [shotView removeFromSuperview];
    }];
}

#pragma mark - disable pan over certain controllers

- (void)disablePanOverViewsOfClass:(Class)viewClass {
    return [_disabledPanClasses addObject:viewClass];
}

- (void)enablePanOverViewsOfClass:(Class)viewClass {
    return [_disabledPanClasses removeObject:viewClass];
}

- (BOOL)canPanOverViewsOfClass:(Class)viewClass {
    return [_disabledPanClasses containsObject:viewClass];
}

- (NSArray*)viewClassesWithDisabledPan {
    return [_disabledPanClasses allObjects];
}


#pragma mark - Top Side

- (BOOL)toggleTopView {
    return [self toggleTopViewAnimated:YES];
}

- (BOOL)openTopView {
    return [self openTopViewAnimated:YES];
}

- (BOOL)closeTopView {
    return [self closeTopViewAnimated:YES];
}

- (BOOL)toggleTopViewAnimated:(BOOL)animated {
    return [self toggleTopViewAnimated:animated completion:nil];
}

- (BOOL)toggleTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    if ([self isSideClosed:IIViewDeckTopSide])
        return [self openTopViewAnimated:animated completion:completed];
    else
        return [self closeTopViewAnimated:animated completion:completed];
}

- (BOOL)openTopViewAnimated:(BOOL)animated {
    return [self openTopViewAnimated:animated completion:nil];
}

- (BOOL)openTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckTopSide animated:animated completion:completed];
}

- (BOOL)openTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self openTopViewBouncing:bounced completion:nil];
}

- (BOOL)openTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckTopSide bounceOffset:self.referenceBounds.size.height targetOffset:self.referenceBounds.size.height - _ledge[IIViewDeckTopSide] bounced:bounced completion:completed];
}

- (BOOL)closeTopViewAnimated:(BOOL)animated {
    return [self closeTopViewAnimated:animated completion:nil];
}

- (BOOL)closeTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeTopViewAnimated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)closeTopViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckTopSide animated:animated duration:duration completion:completed];
}

- (BOOL)closeTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self closeTopViewBouncing:bounced completion:nil];
}

- (BOOL)closeTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckTopSide bounceOffset:self.referenceBounds.size.height bounced:bounced completion:completed];
}


#pragma mark - Bottom Side

- (BOOL)toggleBottomView {
    return [self toggleBottomViewAnimated:YES];
}

- (BOOL)openBottomView {
    return [self openBottomViewAnimated:YES];
}

- (BOOL)closeBottomView {
    return [self closeBottomViewAnimated:YES];
}

- (BOOL)toggleBottomViewAnimated:(BOOL)animated {
    return [self toggleBottomViewAnimated:animated completion:nil];
}

- (BOOL)toggleBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    if ([self isSideClosed:IIViewDeckBottomSide])
        return [self openBottomViewAnimated:animated completion:completed];
    else
        return [self closeBottomViewAnimated:animated completion:completed];
}

- (BOOL)openBottomViewAnimated:(BOOL)animated {
    return [self openBottomViewAnimated:animated completion:nil];
}

- (BOOL)openBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckBottomSide animated:animated completion:completed];
}

- (BOOL)openBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self openBottomViewBouncing:bounced completion:nil];
}

- (BOOL)openBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self openSideView:IIViewDeckBottomSide bounceOffset:-self.referenceBounds.size.height targetOffset:_ledge[IIViewDeckBottomSide] - self.referenceBounds.size.height bounced:bounced completion:completed];
}

- (BOOL)closeBottomViewAnimated:(BOOL)animated {
    return [self closeBottomViewAnimated:animated completion:nil];
}

- (BOOL)closeBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeBottomViewAnimated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)closeBottomViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckBottomSide animated:animated duration:duration completion:completed];
}

- (BOOL)closeBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self closeBottomViewBouncing:bounced completion:nil];
}

- (BOOL)closeBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    return [self closeSideView:IIViewDeckBottomSide bounceOffset:-self.referenceBounds.size.height bounced:bounced completion:completed];
}

#pragma mark - Side Bouncing

- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide {
    return [self previewBounceView:viewDeckSide withCompletion:nil];
}

- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide withCompletion:(IIViewDeckControllerBlock)completed {
    return [self previewBounceView:viewDeckSide toDistance:40.0f duration:1.2f callDelegate:YES completion:completed];
}

- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide toDistance:(CGFloat)distance duration:(NSTimeInterval)duration callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    return [self previewBounceView:viewDeckSide toDistance:distance duration:duration numberOfBounces:4.0f dampingFactor:0.40f callDelegate:callDelegate completion:completed];
}

- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide toDistance:(CGFloat)distance duration:(NSTimeInterval)duration numberOfBounces:(CGFloat)numberOfBounces dampingFactor:(CGFloat)zeta callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed {
    // Check if the requested side to bounce is nil, or if it's already open
    if (![self controllerForSide:viewDeckSide] || [self isSideOpen:viewDeckSide]) return NO;
    
    // check the delegate to allow bouncing
    if (callDelegate && ![self checkDelegate:@selector(viewDeckController:shouldPreviewBounceViewSide:) side:viewDeckSide]) return NO;
    // also close any view that's open. Since the delegate can cancel the close, check the result.
    if (callDelegate && [self isAnySideOpen]) {
        if (![self toggleOpenViewAnimated:YES]) return NO;
    }
    // check for in-flight preview bounce animation, do not add another if so
    if ([self.slidingControllerView.layer animationForKey:@"previewBounceAnimation"]) {
        return NO;
    }
    
    NSArray *animationValues = [self bouncingValuesForViewSide:viewDeckSide maximumBounce:distance numberOfBounces:numberOfBounces dampingFactor:zeta duration:duration];
    if (!animationValues) {
        return NO;
    }
    
    UIViewController *previewController = [self controllerForSide:viewDeckSide];
    NSString *keyPath = @"position.x";
    
    if (viewDeckSide == IIViewDeckBottomSide || viewDeckSide == IIViewDeckTopSide) {
        keyPath = @"position.y";
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = duration;
    animation.values = animationValues;
    animation.removedOnCompletion = YES;
    
    previewController.view.hidden = NO;
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
        // only re-hide controller if the view has not been panned mid-animation
        if (_offset == 0.0f) {
            previewController.view.hidden = YES;
        }
        
        // perform completion and delegate call
        if (completed) completed(self, YES);
        if (callDelegate) [self performDelegate:@selector(viewDeckController:didPreviewBounceViewSide:animated:) side:viewDeckSide animated:YES];
    }];
    [self.slidingControllerView.layer addAnimation:animation forKey:@"previewBounceAnimation"];
    
    // Inform delegate
    if (callDelegate) [self performDelegate:@selector(viewDeckController:willPreviewBounceViewSide:animated:) side:viewDeckSide animated:YES];
    
    // Commit animation
    [CATransaction commit];
    
    return YES;
}

- (NSArray *)bouncingValuesForViewSide:(IIViewDeckSide)viewDeckSide maximumBounce:(CGFloat)maxBounce numberOfBounces:(CGFloat)numberOfBounces dampingFactor:(CGFloat)zeta duration:(NSTimeInterval)duration {
    
    // Underdamped, Free Vibration of a SDOF System
    // u(t) = abs(e^(-zeta * wn * t) * ((Vo/wd) * sin(wd * t))
    
    // Vo, initial velocity, is calculated to provide the desired maxBounce and
    // animation duration. The damped period (wd) and distance of the maximum (first)
    // bounce can be controlled either via the initial condition Vo or the damping
    // factor zeta for a desired duration, Vo is simpler mathematically.
    
    NSUInteger steps = (NSUInteger)MIN(floorf(duration * 100.0f), 100);
    float time = 0.0;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    
    double offset = 0.0;
    float Td = (2.0f * duration) / numberOfBounces; //Damped period, calculated to give the number of bounces desired in the duration specified (2 bounces per Td)
    float wd = (2.0f * M_PI)/Td; // Damped frequency
    zeta = MIN(MAX(0.0001f, zeta), 0.9999f); // For an underdamped system, we must have 0 < zeta < 1
    float zetaFactor = sqrtf(1 - powf(zeta, 2.0f)); // Used in multiple places
    float wn = wd/zetaFactor; // Natural frequency
    float Vo = maxBounce * wd/(expf(-zeta/zetaFactor * (0.18f * Td) * wd) * sinf(0.18f * Td * wd));
    
    // Determine parameters based on direction
    CGFloat position = 0.0f;
    NSInteger direction = 1;
    switch (viewDeckSide) {
        case IIViewDeckLeftSide:
            position = self.slidingControllerView.layer.position.x;
            direction = 1;
            break;
            
        case IIViewDeckRightSide:
            position = self.slidingControllerView.layer.position.x;
            direction = -1;
            break;
        
        case IIViewDeckTopSide:
            position = self.slidingControllerView.layer.position.y;
            direction = 1;
            break;
            
        case IIViewDeckBottomSide:
            position = self.slidingControllerView.layer.position.y;
            direction = -1;
            break;
            
        default:
            return nil;
            break;
    }
    
    // Calculate steps
    for (int t = 0; t < steps; t++) {
        time = (t / (float)steps) * duration;
        offset = abs(expf(-zeta * wn * time) * ((Vo / wd) * sin(wd * time)));
        offset = direction * [self limitOffset:offset forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(viewDeckSide)] + position;
        [values addObject:[NSNumber numberWithFloat:offset]];
    }
    
    return values;
}

#pragma mark - toggling open view

- (BOOL)toggleOpenView {
    return [self toggleOpenViewAnimated:YES];
}

- (BOOL)toggleOpenViewAnimated:(BOOL)animated {
    return [self toggleOpenViewAnimated:animated completion:nil];
}

- (BOOL)toggleOpenViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    IIViewDeckSide fromSide, toSide;
    CGFloat targetOffset;
    
    if ([self isSideOpen:IIViewDeckLeftSide]) {
        fromSide = IIViewDeckLeftSide;
        toSide = IIViewDeckRightSide;
        targetOffset = _ledge[IIViewDeckRightSide] - self.referenceBounds.size.width;
    }
    else if (([self isSideOpen:IIViewDeckRightSide])) {
        fromSide = IIViewDeckRightSide;
        toSide = IIViewDeckLeftSide;
        targetOffset = self.referenceBounds.size.width - _ledge[IIViewDeckLeftSide];
    }
    else if (([self isSideOpen:IIViewDeckTopSide])) {
        fromSide = IIViewDeckTopSide;
        toSide = IIViewDeckBottomSide;
        targetOffset = _ledge[IIViewDeckBottomSide] - self.referenceBounds.size.height;
    }
    else if (([self isSideOpen:IIViewDeckBottomSide])) {
        fromSide = IIViewDeckBottomSide;
        toSide = IIViewDeckTopSide;
        targetOffset = self.referenceBounds.size.height - _ledge[IIViewDeckTopSide];
    }
    else
        return NO;

    // check the delegate to allow closing and opening
    if (![self checkCanCloseSide:fromSide] && ![self checkCanOpenSide:toSide]) return NO;
    
    [self notifyWillCloseSide:fromSide animated:animated];
    [UIView animateWithDuration:[self closeSlideDuration:animated] delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        [self setSlidingFrameForOffset:0 forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(fromSide) animated:YES];
    } completion:^(BOOL finished) {
        [self notifyWillOpenSide:toSide animated:animated];
        [UIView animateWithDuration:[self openSlideDuration:animated] delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            [self setSlidingFrameForOffset:targetOffset forOrientation:IIViewDeckOffsetOrientationFromIIViewDeckSide(toSide) animated:YES];
        } completion:^(BOOL finished) {
            [self notifyDidOpenSide:toSide animated:animated];
        }];
        [self hideAppropriateSideViews];
        [self notifyDidCloseSide:fromSide animated:animated];
    }];
    
    return YES;
}


- (BOOL)closeOpenView {
    return [self closeOpenViewAnimated:YES];
}

- (BOOL)closeOpenViewAnimated:(BOOL)animated {
    return [self closeOpenViewAnimated:animated completion:nil];
}

- (BOOL)closeOpenViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed {
    return [self closeOpenViewAnimated:animated duration:DEFAULT_DURATION completion:completed];
}

- (BOOL)closeOpenViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed {
    if (![self isSideClosed:IIViewDeckLeftSide]) {
        return [self closeLeftViewAnimated:animated duration:duration completion:completed];
    }
    else if (![self isSideClosed:IIViewDeckRightSide]) {
        return [self closeRightViewAnimated:animated duration:duration completion:completed];
    }
    else if (![self isSideClosed:IIViewDeckTopSide]) {
        return [self closeTopViewAnimated:animated duration:duration completion:completed];
    }
    else if (![self isSideClosed:IIViewDeckBottomSide]) {
        return [self closeBottomViewAnimated:animated duration:duration completion:completed];
    }
    
    if (completed) completed(self, YES);
    return YES;
}


- (BOOL)closeOpenViewBouncing:(IIViewDeckControllerBounceBlock)bounced {
    return [self closeOpenViewBouncing:bounced completion:nil];
}

- (BOOL)closeOpenViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed {
    if ([self isSideOpen:IIViewDeckLeftSide]) {
        return [self closeLeftViewBouncing:bounced completion:completed];
    }
    else if (([self isSideOpen:IIViewDeckRightSide])) {
        return [self closeRightViewBouncing:bounced completion:completed];
    }
    else if (([self isSideOpen:IIViewDeckTopSide])) {
        return [self closeTopViewBouncing:bounced completion:completed];
    }
    else if (([self isSideOpen:IIViewDeckBottomSide])) {
        return [self closeBottomViewBouncing:bounced completion:completed];
    }
    
    if (completed) completed(self, YES);
    return YES;
}


#pragma mark - Pre iOS5 message relaying

- (void)relayRotationMethod:(void(^)(UIViewController* controller))relay {
    if ([self safe_shouldForwardRotationMethods]) {
        relay(self.centerController);
        [self doForControllers:^(UIViewController *controller, IIViewDeckSide side) {
            relay(controller);
        }];
    }
}

#pragma mark - center view hidden stuff

- (void)centerViewVisible {
    if (self.centerTapper) {
        [self.centerTapper removeTarget:self action:@selector(centerTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.centerTapper removeFromSuperview];
    }
    self.centerTapper = nil;
    [self setNeedsAddPanners];
    [self applyShadowToSlidingViewAnimated:YES];
}

- (void)centerViewHidden {
    if (!IIViewDeckCenterHiddenIsInteractive(self.centerhiddenInteractivity)) {
        if (!self.centerTapper) {
            self.centerTapper = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.centerTapper setBackgroundImage:nil forState:UIControlStateNormal];
            [self.centerTapper setBackgroundImage:nil forState:UIControlStateHighlighted];
            [self.centerTapper setBackgroundImage:nil forState:UIControlStateDisabled];
            self.centerTapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.centerTapper.frame = [self.centerView bounds];
            [self.centerTapper addTarget:self action:@selector(centerTapped) forControlEvents:UIControlEventTouchUpInside];
            self.centerTapper.backgroundColor = [UIColor clearColor];
            if ([self.centerTapper respondsToSelector:@selector(accessibilityViewIsModal)]) {
				self.centerTapper.accessibilityViewIsModal = YES;
			}
        }
        [self.centerView addSubview:self.centerTapper];
        self.centerTapper.frame = [self.centerView bounds];
        [self setAccessibilityForCenterTapper]; // set accessibility label, hint, and frame
        
        [self setNeedsAddPanners];
    }
    
    [self applyShadowToSlidingViewAnimated:YES];
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
        if (self.bottomController && CGRectGetMinY(self.slidingControllerView.frame) < 0) {
            if (self.centerhiddenInteractivity == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose)
                [self closeBottomView];
            else
                [self closeBottomViewBouncing:nil];
        }
        
        if (self.topController && CGRectGetMinY(self.slidingControllerView.frame) > 0) {
            if (self.centerhiddenInteractivity == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose)
                [self closeTopView];
            else
                [self closeTopViewBouncing:nil];
        }
    }
}

- (void)disableUserInteraction {
    @synchronized (self.view) {
        ++_disabledUserInteractions;
        if (_disabledUserInteractions == 1) {
            ((IIViewDeckView*)self.view).allowUserInteractionEnabled = NO;
        }
    }
}

- (void)enableUserInteraction {
    @synchronized (self.view) {
        if (_disabledUserInteractions > 0) {
            --_disabledUserInteractions;
            if (_disabledUserInteractions == 0) {
                ((IIViewDeckView*)self.view).allowUserInteractionEnabled = YES;
            }
        }
    }
}

- (void)setAccessibilityForCenterTapper {
    if (self.centerTapper) {
        self.centerTapper.accessibilityLabel = self.centerTapperAccessibilityLabel;
        self.centerTapper.accessibilityHint = self.centerTapperAccessibilityHint;
        self.centerTapper.accessibilityFrame = CGRectIntersection(self.view.window.bounds, [self.centerTapper convertRect:self.centerTapper.bounds toView:nil]);
    }
}

- (void)setCenterTapperAccessibilityLabel:(NSString *)centerTapperAccessibilityLabel {
    if (![_centerTapperAccessibilityLabel isEqualToString:centerTapperAccessibilityLabel]) {
        _centerTapperAccessibilityLabel = centerTapperAccessibilityLabel;
        [self setAccessibilityForCenterTapper];
    }
}

- (void)setCenterTapperAccessibilityHint:(NSString *)centerTapperAccessibilityHint {
    if (![_centerTapperAccessibilityHint isEqualToString:centerTapperAccessibilityHint]) {
        _centerTapperAccessibilityHint = centerTapperAccessibilityHint;
        [self setAccessibilityForCenterTapper];
    }
}

#pragma mark - Panning

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panner {
    UINavigationController* navController = [self.centerController isKindOfClass:[UINavigationController class]] ? (UINavigationController*)self.centerController : self.centerController.navigationController;

    if (self.panningMode == IIViewDeckNavigationBarOrOpenCenterPanning && panner.view == self.slidingControllerView) {
        CGPoint loc = [panner locationInView:navController.navigationBar];
        
        if (!CGRectContainsPoint(navController.navigationBar.bounds, loc) && ![self isAnySideOpen])
            return NO;
    }
    
    if (self.panningGestureDelegate && [self.panningGestureDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        BOOL result = [self.panningGestureDelegate gestureRecognizerShouldBegin:panner];
        if (!result) return result;
    }
    
    IIViewDeckOffsetOrientation orientation;
    CGPoint velocity = [panner velocityInView:self.referenceView];
    if (ABS(velocity.x) >= ABS(velocity.y))
        orientation = IIViewDeckHorizontalOrientation;
    else
        orientation = IIViewDeckVerticalOrientation;

    CGFloat pv;
    IIViewDeckSide minSide, maxSide;
    if (orientation == IIViewDeckHorizontalOrientation) {
        minSide = IIViewDeckLeftSide;
        maxSide = IIViewDeckRightSide;
        pv = self.slidingControllerView.frame.origin.x;
    }
    else {
        minSide = IIViewDeckTopSide;
        maxSide = IIViewDeckBottomSide;
        pv = self.slidingControllerView.frame.origin.y;
    }
    
    if (self.panningMode == IIViewDeckDelegatePanning && [self.delegate respondsToSelector:@selector(viewDeckController:shouldPan:)]) {
        if (![self.delegate viewDeckController:self shouldPan:panner])
            return NO;
    }
    
    if (pv != 0) return YES;
        
    CGFloat v = [self locationOfPanner:panner orientation:orientation];
    BOOL ok = YES;

    if (v > 0) {
        ok = [self checkCanOpenSide:minSide];
        if (!ok)
            [self closeSideView:minSide animated:NO completion:nil];
    }
    else if (v < 0) {
        ok = [self checkCanOpenSide:maxSide];
        if (!ok)
            [self closeSideView:maxSide animated:NO completion:nil];
    }
    
    return ok;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // allow the panningGestureDelegate to act first
    if (self.panningGestureDelegate && [self.panningGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
        BOOL result = [self.panningGestureDelegate gestureRecognizer:gestureRecognizer
                                                  shouldReceiveTouch:touch];
        if (!result) return result;
    }
    
    // check the disabled pan classes
    for (Class viewClass in _disabledPanClasses) {
        if ([[touch view] isKindOfClass:viewClass])
            return NO;
    }

    // check the delegate if we should start panning over this view
    if (![self checkDelegate:@selector(viewDeckController:shouldBeginPanOverView:) view:[touch view]]) {
        return NO;
    }

    _panOrigin = self.slidingControllerView.frame.origin;
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.panningGestureDelegate && [self.panningGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.panningGestureDelegate gestureRecognizer:gestureRecognizer
           shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    return NO;
}

- (CGFloat)locationOfPanner:(UIPanGestureRecognizer*)panner orientation:(IIViewDeckOffsetOrientation)orientation {
    CGPoint pan = [panner translationInView:self.referenceView];
    CGFloat ofs = orientation == IIViewDeckHorizontalOrientation ? (pan.x+_panOrigin.x) : (pan.y + _panOrigin.y);
    
    IIViewDeckSide minSide, maxSide;
    CGFloat max;
    if (orientation == IIViewDeckHorizontalOrientation) {
        minSide = IIViewDeckLeftSide;
        maxSide = IIViewDeckRightSide;
        max = self.referenceBounds.size.width;
    }
    else {
        minSide = IIViewDeckTopSide;
        maxSide = IIViewDeckBottomSide;
        max = self.referenceBounds.size.height;
    }
    if (!_controllers[minSide]) ofs = MIN(0, ofs);
    if (!_controllers[maxSide]) ofs = MAX(0, ofs);
    
    CGFloat lofs = MAX(MIN(ofs, max-_ledge[minSide]), -max+_ledge[maxSide]);
    
    if (self.elastic) {
        CGFloat dofs = ABS(ofs) - ABS(lofs);
        if (dofs > 0) {
            dofs = dofs / logf(dofs + 1) * 2;
            ofs = lofs + (ofs < 0 ? -dofs : dofs);
        }
    }
    else {
        ofs = lofs;
    }
    
    return [self limitOffset:ofs forOrientation:orientation]; 
}


- (void)panned:(UIPanGestureRecognizer*)panner {
    if (!_enabled) return;
    
    if (_offset == 0 && panner.state == UIGestureRecognizerStateBegan) {
        CGPoint velocity = [panner velocityInView:self.referenceView];
        if (ABS(velocity.x) >= ABS(velocity.y))
            [self panned:panner orientation:IIViewDeckHorizontalOrientation];
        else
            [self panned:panner orientation:IIViewDeckVerticalOrientation];
    }
    else {
        [self panned:panner orientation:_offsetOrientation];
    }
}

- (void)panned:(UIPanGestureRecognizer*)panner orientation:(IIViewDeckOffsetOrientation)orientation {
    [self setParallax];
    
    CGFloat pv, m;
    IIViewDeckSide minSide, maxSide;
    if (orientation == IIViewDeckHorizontalOrientation) {
        pv = self.slidingControllerView.frame.origin.x;
        m = self.referenceBounds.size.width;
        minSide = IIViewDeckLeftSide;
        maxSide = IIViewDeckRightSide;
    }
    else {
        pv = self.slidingControllerView.frame.origin.y;
        m = self.referenceBounds.size.height;
        minSide = IIViewDeckTopSide;
        maxSide = IIViewDeckBottomSide;
    }
    CGFloat v = [self locationOfPanner:panner orientation:orientation];

    IIViewDeckSide closeSide = IIViewDeckNoSide;
    IIViewDeckSide openSide = IIViewDeckNoSide;
    
    // if we move over a boundary while dragging, ... 
    if (pv <= 0 && v >= 0 && pv != v) {
        // ... then we need to check if the other side can open.
        if (pv < 0) {
            if (![self checkCanCloseSide:maxSide])
                return;
            [self notifyWillCloseSide:maxSide animated:NO];
            closeSide = maxSide;
        }

        if (v > 0) {
            if (![self checkCanOpenSide:minSide]) {
                [self closeSideView:maxSide animated:NO completion:nil];
                return;
            }
            [self notifyWillOpenSide:minSide animated:NO];
            openSide = minSide;
        }
    }
    else if (pv >= 0 && v <= 0 && pv != v) {
        if (pv > 0) {
            if (![self checkCanCloseSide:minSide])
                return;
            [self notifyWillCloseSide:minSide animated:NO];
            closeSide = minSide;
        }

        if (v < 0) {
            if (![self checkCanOpenSide:maxSide]) {
                [self closeSideView:minSide animated:NO completion:nil];
                return;
            }
            [self notifyWillOpenSide:maxSide animated:NO];
            openSide = maxSide;
        }
    }
    
    // Check for an in-flight bounce animation
    CAKeyframeAnimation *bounceAnimation = (CAKeyframeAnimation *)[self.slidingControllerView.layer animationForKey:@"previewBounceAnimation"];
    if (bounceAnimation != nil) {
        self.slidingControllerView.frame = [[self.slidingControllerView.layer presentationLayer] frame];
        [self.slidingControllerView.layer removeAnimationForKey:@"previewBounceAnimation"];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self panToSlidingFrameForOffset:v forOrientation:orientation animated:YES];
        } completion:nil];
    } else {
        [self panToSlidingFrameForOffset:v forOrientation:orientation animated:NO];
    }
    
    if (panner.state == UIGestureRecognizerStateEnded ||
        panner.state == UIGestureRecognizerStateCancelled ||
        panner.state == UIGestureRecognizerStateFailed) {
        CGFloat sv = orientation == IIViewDeckHorizontalOrientation ? self.slidingControllerView.frame.origin.x : self.slidingControllerView.frame.origin.y;
        if (II_FLOAT_EQUAL(sv, 0.0f))
            [self centerViewVisible];
        else
            [self centerViewHidden];
        
        CGFloat lm3 = (m-_ledge[minSide]) / 3.0;
        CGFloat rm3 = (m-_ledge[maxSide]) / 3.0;
        CGPoint velocity = [panner velocityInView:self.referenceView];
        CGFloat orientationVelocity = orientation == IIViewDeckHorizontalOrientation ? velocity.x : velocity.y;
        if (ABS(orientationVelocity) < 500) {
            // small velocity, no movement
            if (v >= m - _ledge[minSide] - lm3) {
                [self openSideView:minSide animated:YES completion:nil];
            }
            else if (v <= _ledge[maxSide] + rm3 - m) {
                [self openSideView:maxSide animated:YES completion:nil];
            }
            else
                [self closeOpenView];
        }
        else if (orientationVelocity != 0.0f) {
            if (orientationVelocity < 0) {
                // swipe to the left
                // Animation duration based on velocity
                CGFloat pointsToAnimate = self.slidingControllerView.frame.origin.x;
                NSTimeInterval animationDuration = fabsf(durationToAnimate(pointsToAnimate, orientationVelocity));
                
                if (v < 0) {
                    [self openSideView:maxSide animated:YES duration:animationDuration completion:nil];
                }
                else
                {
                    [self closeOpenViewAnimated:YES duration:animationDuration completion:nil];
                }
            }
            else if (orientationVelocity > 0) {
                // swipe to the right
                
                // Animation duration based on velocity
                CGFloat maxDistance = CGRectGetWidth(self.view.frame) - self.leftSize;
                CGFloat pointsToAnimate = fabsf(maxDistance - self.slidingControllerView.frame.origin.x);
                NSTimeInterval animationDuration = durationToAnimate(pointsToAnimate, orientationVelocity);
                
                if (v > 0) {
                    [self openSideView:minSide animated:YES duration:animationDuration completion:nil];
                }
                else 
                    [self closeOpenViewAnimated:YES duration:animationDuration completion:nil];
            }
        }
    }
    else
        [self hideAppropriateSideViews];
    
    [self setAccessibilityForCenterTapper]; // update since the frame and the frame's intersection with the window will have changed
    
    [self notifyDidCloseSide:closeSide animated:NO];
    [self notifyDidOpenSide:openSide animated:NO];
    [self addPannersIfAllPannersAreInactiveAndNeeded];
}

- (void) setParallax {
    if(_parallaxAmount <= 0.0) return;
    
    self.leftController.view.frame = [self getLeftParallax];
    self.rightController.view.frame = [self getRightParallax];
}

- (CGRect) getLeftParallax {
    CGFloat pv = self.slidingControllerView.frame.origin.x;
    CGFloat diff = pv-(self.slidingControllerView.frame.size.width-_ledge[IIViewDeckLeftSide]);
    if (diff > 0.0f) diff = 0.0f;
    
    return CGRectMake(diff*_parallaxAmount, self.leftController.view.frame.origin.y, self.leftController.view.frame.size.width, self.leftController.view.frame.size.height);
}

- (CGRect) getRightParallax {
    CGFloat pv = self.slidingControllerView.frame.origin.x;
    CGFloat diff = pv+(self.slidingControllerView.frame.size.width-_ledge[IIViewDeckRightSide]);
    if (diff < 0.0f) diff = 0.0f;
    
    return CGRectMake(diff*_parallaxAmount, self.rightController.view.frame.origin.y, self.rightController.view.frame.size.width, self.rightController.view.frame.size.height);
}


- (void)addPanner:(UIView*)view {
    if (!view) return;
    
    UIPanGestureRecognizer* panner = II_AUTORELEASE([[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)]);
    panner.cancelsTouchesInView = _panningCancelsTouchesInView;
    panner.delegate = self;
    [view addGestureRecognizer:panner];
    [self.panners addObject:panner];
}

- (void)setNeedsAddPanners {
    if (_needsAddPannersIfAllPannersAreInactive)
        return;
    if ([self hasActivePanner])
        _needsAddPannersIfAllPannersAreInactive = YES;
    else
        [self addPanners];
}

- (void)addPannersIfAllPannersAreInactiveAndNeeded {
    if (!_needsAddPannersIfAllPannersAreInactive || [self hasActivePanner])
        return;
    [self addPanners];
    _needsAddPannersIfAllPannersAreInactive = NO;
}

- (void)addPanners {
    [self removePanners];
    
    switch (_panningMode) {
        case IIViewDeckNoPanning: 
            break;
            
        case IIViewDeckAllViewsPanning:
            [self addPanner:self.view];
            break;
            
        case IIViewDeckFullViewPanning:
        case IIViewDeckDelegatePanning:
        case IIViewDeckNavigationBarOrOpenCenterPanning:
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

- (BOOL)hasActivePanner {
    for (UIPanGestureRecognizer *panner in self.panners) {
        if (panner.state == UIGestureRecognizerStateBegan || panner.state == UIGestureRecognizerStateChanged) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Delegate convenience methods

- (BOOL)checkDelegate:(SEL)selector side:(IIViewDeckSide)viewDeckSide {
    BOOL ok = YES;
    // used typed message send to properly pass values
    BOOL (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, IIViewDeckSide viewDeckSide) = (void*)objc_msgSend;
    
    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        ok = ok & objc_msgSendTyped(self.delegate, selector, self, viewDeckSide);
    
    if (_delegateMode != IIViewDeckDelegateOnly) {
        for (UIViewController* controller in self.controllers) {
            // check controller first
            if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate)
                ok = ok & objc_msgSendTyped(controller, selector, self, viewDeckSide);
            // if that fails, check if it's a navigation controller and use the top controller
            else if ([controller isKindOfClass:[UINavigationController class]]) {
                UIViewController* topController = ((UINavigationController*)controller).topViewController;
                if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate)
                    ok = ok & objc_msgSendTyped(topController, selector, self, viewDeckSide);
            }
        }
    }
    
    return ok;
}

- (BOOL)checkDelegate:(SEL)selector view:(UIView*)view {
    BOOL ok = YES;
    // used typed message send to properly pass values
    BOOL (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, UIView* view) = (void*)objc_msgSend;
    
    if (self.delegate && [self.delegate respondsToSelector:selector])
        ok = ok & objc_msgSendTyped(self.delegate, selector, self, view);
    
    if (_delegateMode != IIViewDeckDelegateOnly) {
        for (UIViewController* controller in self.controllers) {
            // check controller first
            if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate)
                ok = ok & objc_msgSendTyped(controller, selector, self, view);
            // if that fails, check if it's a navigation controller and use the top controller
            else if ([controller isKindOfClass:[UINavigationController class]]) {
                UIViewController* topController = ((UINavigationController*)controller).topViewController;
                if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate)
                    ok = ok & objc_msgSendTyped(topController, selector, self, view);
            }
        }
    }
    
    return ok;
}

- (void)performDelegate:(SEL)selector side:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    // used typed message send to properly pass values
    void (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, IIViewDeckSide viewDeckSide, BOOL animated) = (void*)objc_msgSend;
    
    if (self.delegate && [self.delegate respondsToSelector:selector])
        objc_msgSendTyped(self.delegate, selector, self, viewDeckSide, animated);
    
    if (_delegateMode == IIViewDeckDelegateOnly)
        return;
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate)
            objc_msgSendTyped(controller, selector, self, viewDeckSide, animated);
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate)
                objc_msgSendTyped(topController, selector, self, viewDeckSide, animated);
        }
    }
}

- (void)performDelegate:(SEL)selector side:(IIViewDeckSide)viewDeckSide controller:(UIViewController*)controller {
    // used typed message send to properly pass values
    void (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, IIViewDeckSide viewDeckSide, UIViewController* controller) = (void*)objc_msgSend;
    
    if (self.delegate && [self.delegate respondsToSelector:selector])
        objc_msgSendTyped(self.delegate, selector, self, viewDeckSide, controller);
    
    if (_delegateMode == IIViewDeckDelegateOnly)
        return;
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate)
            objc_msgSendTyped(controller, selector, self, viewDeckSide, controller);
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate)
                objc_msgSendTyped(topController, selector, self, viewDeckSide, controller);
        }
    }
}

- (CGFloat)performDelegate:(SEL)selector ledge:(CGFloat)ledge side:(IIViewDeckSide)side {
    CGFloat (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, CGFloat ledge, IIViewDeckSide side) = (void*)objc_msgSend;
    if (self.delegate && [self.delegate respondsToSelector:selector])
        ledge = objc_msgSendTyped(self.delegate, selector, self, ledge, side);
    
    if (_delegateMode == IIViewDeckDelegateOnly)
        return ledge;
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate)
            ledge = objc_msgSendTyped(controller, selector, self, ledge, side);
        
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate)
                ledge = objc_msgSendTyped(topController, selector, self, ledge, side);
        }
    }
    
    return ledge;
}

- (void)performDelegate:(SEL)selector offset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    void (*objc_msgSendTyped)(id self, SEL _cmd, IIViewDeckController* foo, CGFloat offset, IIViewDeckOffsetOrientation orientation, BOOL panning) = (void*)objc_msgSend;
    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        objc_msgSendTyped(self.delegate, selector, self, offset, orientation, panning);
    
    if (_delegateMode == IIViewDeckDelegateOnly)
        return;
    
    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector] && (id)controller != (id)self.delegate) 
            objc_msgSendTyped(controller, selector, self, offset, orientation, panning);
        
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector] && (id)topController != (id)self.delegate) 
                objc_msgSendTyped(topController, selector, self, offset, orientation, panning);
        }
    }
}


#pragma mark - Properties

- (void)setBounceDurationFactor:(CGFloat)bounceDurationFactor {
    _bounceDurationFactor = MIN(MAX(0, bounceDurationFactor), 0.99f);
}

- (void)setTitle:(NSString *)title {
    if (!II_STRING_EQUAL(title, self.title)) [super setTitle:title];
    if (!II_STRING_EQUAL(title, self.centerController.title)) self.centerController.title = title;
}

- (NSString*)title {
    return self.centerController.title;
}

- (void)setPanningMode:(IIViewDeckPanningMode)panningMode {
    if (_viewFirstAppeared) {
        _panningMode = panningMode;
        [self setNeedsAddPanners];
    }
    else
        _panningMode = panningMode;
}

- (void)setPanningView:(UIView *)panningView {
    if (_panningView != panningView) {
        II_RELEASE(_panningView);
        _panningView = panningView;
        II_RETAIN(_panningView);
        
        if (_viewFirstAppeared && _panningMode == IIViewDeckPanningViewPanning)
            [self setNeedsAddPanners];
    }
}

- (void)setPanningCancelsTouchesInView:(BOOL)panningCancelsTouchesInView {
    _panningCancelsTouchesInView = panningCancelsTouchesInView;
    for (UIGestureRecognizer* panner in _panners) {
        panner.cancelsTouchesInView = panningCancelsTouchesInView;
    }
}

- (void)setNavigationControllerBehavior:(IIViewDeckNavigationControllerBehavior)navigationControllerBehavior {
    if (!_viewFirstAppeared) {
        _navigationControllerBehavior = navigationControllerBehavior;
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set navigationcontroller behavior when the view deck is already showing." userInfo:nil];
    }
}

- (void)setController:(UIViewController *)controller forSide:(IIViewDeckSide)side {
    UIViewController* prevController = _controllers[side];
    if (controller == prevController)
        return;

    __block IIViewDeckSide currentSide = IIViewDeckNoSide;
    [self doForControllers:^(UIViewController* sideController, IIViewDeckSide side) {
        if (controller == sideController)
            currentSide = side;
    }];
    void(^beforeBlock)() = ^{};
    void(^afterBlock)(UIViewController* controller) = ^(UIViewController* controller){};
    
    __block CGRect newFrame = self.referenceBounds;
    if (_viewFirstAppeared) {
        beforeBlock = ^{
            [self notifyAppearanceForSide:side animated:NO from:2 to:1];
            [[self controllerForSide:side].view removeFromSuperview];
            [self notifyAppearanceForSide:side animated:NO from:1 to:0];
        };
        afterBlock = ^(UIViewController* controller) {
            [self notifyAppearanceForSide:side animated:NO from:0 to:1];
            [self hideAppropriateSideViews];
            controller.view.frame = newFrame;
            controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (self.slidingController)
                [self.referenceView insertSubview:controller.view belowSubview:self.slidingControllerView];
            else
                [self.referenceView addSubview:controller.view];
            [self notifyAppearanceForSide:side animated:NO from:1 to:2];
        };
    }
    
    // start the transition
    if (prevController) {
        newFrame = prevController.view.frame;
        [prevController willMoveToParentViewController:nil];
        if (controller == self.centerController) self.centerController = nil;
        beforeBlock();
        if (currentSide != IIViewDeckNoSide) _controllers[currentSide] = nil;
        [prevController setViewDeckController:nil];
        [prevController removeFromParentViewController];
        [prevController didMoveToParentViewController:nil];
    }
    
    // make the switch
    if (prevController != controller) {
        II_RELEASE(prevController);
        _controllers[side] = controller;
        II_RETAIN(controller);
    }
    
    if (controller) {
        // and finish the transition
        void(^finishTransition)(void) = ^{
            UIViewController* parentController = [[self parentViewController] parentViewController] ?: [self presentingViewController] ?: self;
            
            [parentController addChildViewController:controller];
            [controller setViewDeckController:self];
            afterBlock(controller);
            [controller didMoveToParentViewController:parentController];
            [self applyCenterViewOpacityIfNeeded];
        };
        
        [self enqueueFinishTransitionBlock:finishTransition forController:controller];
    }
}

- (UIViewController *)leftController {
    return [self controllerForSide:IIViewDeckLeftSide];
}

- (void)setLeftController:(UIViewController *)leftController {
    [self setController:leftController forSide:IIViewDeckLeftSide];
}

- (UIViewController *)rightController {
    return [self controllerForSide:IIViewDeckRightSide];
}

- (void)setRightController:(UIViewController *)rightController {
    [self setController:rightController forSide:IIViewDeckRightSide];
}

- (UIViewController *)topController {
    return [self controllerForSide:IIViewDeckTopSide];
}

- (void)setTopController:(UIViewController *)topController {
    [self setController:topController forSide:IIViewDeckTopSide];
}

- (UIViewController *)bottomController {
    return [self controllerForSide:IIViewDeckBottomSide];
}

- (void)setBottomController:(UIViewController *)bottomController {
    [self setController:bottomController forSide:IIViewDeckBottomSide];
}


- (void)setCenterController:(UIViewController *)centerController {
    if (_centerController == centerController) return;
    
    void(^beforeBlock)(UIViewController* controller) = ^(UIViewController* controller){};
    void(^afterBlock)(UIViewController* controller) = ^(UIViewController* controller){};
    
    __block CGRect currentFrame = self.referenceBounds;
    if (_viewFirstAppeared) {
        beforeBlock = ^(UIViewController* controller) {
            if ([self safe_shouldManageAppearanceMethods]) [controller viewWillDisappear:NO];
            [self restoreShadowToSlidingView];
            [self removePanners];
            [controller.view removeFromSuperview];
            if ([self safe_shouldManageAppearanceMethods]) [controller viewDidDisappear:NO];
            [self.centerView removeFromSuperview];
        };
        afterBlock = ^(UIViewController* controller) {
            [self.view addSubview:self.centerView];
             if ([self safe_shouldManageAppearanceMethods]) [controller viewWillAppear:NO];
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
            [self applyShadowToSlidingViewAnimated:NO];
            if ([self safe_shouldManageAppearanceMethods]) [controller viewDidAppear:NO];
        };
    }
    
    // start the transition
    if (_centerController) {
        currentFrame = _centerController.view.frame;
        [_centerController willMoveToParentViewController:nil];
        if (centerController == self.leftController) self.leftController = nil;
        if (centerController == self.rightController) self.rightController = nil;
        if (centerController == self.topController) self.topController = nil;
        if (centerController == self.bottomController) self.bottomController = nil;
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
        II_RETAIN(_centerController);
        [_centerController willMoveToParentViewController:self];
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
        
        [_centerController view]; // make sure the view is loaded before calling viewWillAppear:
        [self applyCenterViewOpacityIfNeeded];
        [self applyCenterViewCornerRadiusAnimated:NO];
        afterBlock(_centerController);
        [_centerController didMoveToParentViewController:self];
        
        if ([self isAnySideOpen]) {
            [self centerViewHidden];
        }
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
            [self finishTransitionBlocks];
            return YES;
        }
    }
    else {
        _slidingController = self.centerController;
        self.referenceView = self.view;
        [self finishTransitionBlocks];
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
        [self setSlidingFrameForOffset:_offset forOrientation:_offsetOrientation animated:NO];
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
    
    if ([keyPath isEqualToString:@"parentViewController"] || [keyPath isEqualToString:@"presentingViewController"]) {
        [self finishTransitionBlocks];
        
    }
}

#pragma mark - transition blocks

- (void)enqueueFinishTransitionBlock:(void(^)(void))finishTransition forController:(UIViewController*)controller {
    [controller willMoveToParentViewController:self];
    if (self.referenceView) {
        finishTransition();
    }
    else {
        [controller setViewDeckController:self]; // do this now since the transition block my run to late
        if (!_finishTransitionBlocks) {
            _finishTransitionBlocks = [NSMutableArray new];
            II_RETAIN(_finishTransitionBlocks);
            [self addObserver:self forKeyPath:@"parentViewController" options:0 context:nil];
            [self addObserver:self forKeyPath:@"presentingViewController" options:0 context:nil];
        }
        [_finishTransitionBlocks addObject:finishTransition];
    }
}

- (void)finishTransitionBlocks {
    if (![self parentViewController] && ![self presentingViewController]) return;
    if (!self.referenceView) return;
    
    if (_finishTransitionBlocks) {
        [self removeObserver:self forKeyPath:@"parentViewController" context:nil];
        [self removeObserver:self forKeyPath:@"presentingViewController" context:nil];
        
        for (void(^finishTransition)(void) in _finishTransitionBlocks) {
            finishTransition();
        }
        II_RELEASE(_finishTransitionBlocks);
        _finishTransitionBlocks = nil;
    }
}

#pragma mark - Center Opacity

- (void)setCenterViewOpacity:(CGFloat)centerViewOpacity {
    _centerViewOpacity = centerViewOpacity;
    
    if (centerViewOpacity < 1 && [self sideControllerCount] > 1) {
        NSLog(@"IIViewDeckController: warning: setting centerViewOpacity to value different than 1 with more than one side controller. Value will be ignored.");
        return;
    }
    
    [self applyCenterViewOpacityIfNeeded];
}

- (void)applyCenterViewOpacityIfNeeded {
    if (!self.centerController.view)
        return;
    
    if ([self sideControllerCount] > 1) {
        // more than once controller => not opaque
        if (self.centerController.view.alpha < 1) {
            self.centerController.view.alpha = 1;
            self.centerController.view.opaque = YES;
        }
        return;
    }
    
    self.centerController.view.alpha = _centerViewOpacity;
    self.centerController.view.opaque = NO;
}

#pragma mark - Center corner radius

- (void)setCenterViewCornerRadius:(CGFloat)centerViewCornerRadius {
    _centerViewCornerRadius = centerViewCornerRadius;
    [self applyCenterViewCornerRadiusAnimated:NO];
}

- (UIBezierPath*)generateCenterViewCornerRadiusPath {
    CGRect rect = self.slidingControllerView.layer.bounds;
    if (_centerViewCornerRadius == 0)
        return [UIBezierPath bezierPathWithRect:rect];
    
    // create mask path
    CGSize radius = (CGSize) { _centerViewCornerRadius, _centerViewCornerRadius };
    UIRectCorner corners = 0;
    if (self.leftController)
        corners |= UIRectCornerTopLeft | UIRectCornerBottomLeft;
    if (self.rightController)
        corners |= UIRectCornerTopRight | UIRectCornerBottomRight;
    if (self.topController)
        corners |= UIRectCornerTopLeft | UIRectCornerTopRight;
    if (self.bottomController)
        corners |= UIRectCornerBottomLeft | UIRectCornerBottomRight;
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radius];
    
    return path;
}

- (void)applyCenterViewCornerRadiusAnimated:(BOOL)animated {
    UIBezierPath* path = [self generateCenterViewCornerRadiusPath];

    if (!self.slidingControllerView.layer.mask) {
        self.slidingControllerView.layer.mask = [CAShapeLayer layer];
        ((CAShapeLayer*)self.slidingControllerView.layer.mask).path = [path CGPath];
    }
   
    CAShapeLayer* mask = (CAShapeLayer*)self.slidingControllerView.layer.mask;
    if (animated) {
        CGFloat duration = 0.3;
        CAMediaTimingFunction* timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self currentAnimationDuration:&duration timingFunction:&timingFunction];

        CABasicAnimation* anim;
        anim = [CABasicAnimation animationWithKeyPath:@"bounds"];
        anim.duration = duration;
        anim.timingFunction = timingFunction;
        anim.fromValue = [NSValue valueWithCGRect:mask.bounds];
        anim.toValue = [NSValue valueWithCGRect:[path bounds]];
        anim.fillMode = kCAFillModeForwards;
        [mask addAnimation:anim forKey:@"animateBounds"];
        
        anim = [CABasicAnimation animationWithKeyPath:@"path"];
        anim.duration = duration;
        anim.timingFunction = timingFunction;
        anim.fromValue = (id)mask.path;
        anim.toValue = (id)[path CGPath];
        anim.fillMode = kCAFillModeForwards;
        [mask addAnimation:anim forKey:@"animatePath"];

        anim = [CABasicAnimation animationWithKeyPath:@"position"];
        anim.duration = duration;
        anim.timingFunction = timingFunction;
        anim.fromValue = [NSValue valueWithCGPoint:_shadowLayer.position];
        anim.toValue = [NSValue valueWithCGPoint:self.slidingControllerView.layer.position];
        anim.fillMode = kCAFillModeForwards;
        [_shadowLayer addAnimation:anim forKey:@"animatePosition"];

        anim = [CABasicAnimation animationWithKeyPath:@"bounds"];
        anim.duration = duration;
        anim.timingFunction = timingFunction;
        anim.fromValue = [NSValue valueWithCGRect:_shadowLayer.bounds];
        anim.toValue = [NSValue valueWithCGRect:self.slidingControllerView.layer.bounds];
        anim.fillMode = kCAFillModeForwards;
        [_shadowLayer addAnimation:anim forKey:@"animateBounds"];

        anim = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        anim.duration = duration;
        anim.timingFunction = timingFunction;
        anim.fromValue = (id)_shadowLayer.shadowPath;
        anim.toValue = (id)[path CGPath];
        anim.fillMode = kCAFillModeForwards;
        [_shadowLayer addAnimation:anim forKey:@"animateShadowPath"];
    }

    mask.path = [path CGPath];
    mask.frame = [path bounds];
    _shadowLayer.shadowPath = [path CGPath];
    _shadowLayer.frame = self.slidingControllerView.layer.frame;
}

#pragma mark - Shadow

- (void)setShadowEnabled:(BOOL)shadowEnabled animated:(BOOL)animated {
    _shadowEnabled = shadowEnabled;
    
    if (shadowEnabled)
        [self applyShadowToSlidingViewAnimated:animated];
    else
        [self restoreShadowToSlidingView];
}

- (void)setShadowEnabled:(BOOL)shadowEnabled {
    [self setShadowEnabled:shadowEnabled animated:NO];
}

- (void)restoreShadowToSlidingView {
    UIView* shadowedView = self.slidingControllerView;
    if (!shadowedView) return;
    
    [_shadowLayer removeFromSuperlayer];
}

- (void)applyShadowToSlidingViewAnimated:(BOOL)animated {
    if (!self.shadowEnabled) return;

    UIView* shadowedView = self.slidingControllerView;
    if (!shadowedView) return;
    
    if ([self.delegate respondsToSelector:@selector(viewDeckController:applyShadow:withBounds:)]) {
        [self.delegate viewDeckController:self applyShadow:_shadowLayer withBounds:self.referenceBounds];
    }
    else {
        CGPathRef newPath = ((CAShapeLayer*)self.slidingControllerView.layer.mask).path;
        if (animated) {
            CGFloat duration;
            CAMediaTimingFunction* timingFunction;
            if ([self currentAnimationDuration:&duration timingFunction:&timingFunction]) {
                CABasicAnimation* anim;
                if (![_shadowLayer animationForKey:@"animateShadowPath"]) {
                    anim = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
                    anim.fromValue = (id)_shadowLayer.shadowPath;
                    anim.toValue = (__bridge id)newPath;
                    anim.duration = duration;
                    anim.timingFunction = timingFunction;
                    anim.fillMode = kCAFillModeForwards;
                    [_shadowLayer addAnimation:anim forKey:@"animateShadowPath"];

                    anim = [CABasicAnimation animationWithKeyPath:@"bounds"];
                    anim.duration = duration;
                    anim.timingFunction = timingFunction;
                    anim.fromValue = [NSValue valueWithCGRect:_shadowLayer.bounds];
                    anim.toValue = [NSValue valueWithCGRect:self.slidingControllerView.layer.bounds];
                    anim.fillMode = kCAFillModeForwards;
                    [_shadowLayer addAnimation:anim forKey:@"animateBounds"];
                }
            }
            
            // fallback: make shadow transparent and fade in to desired value. This gives the same visual
            // effect as animating
            if ([_shadowLayer animationKeys].count == 0) {
                CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                anim.fromValue = @(0.0);
                anim.duration = 1;
                anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                anim.fillMode = kCAFillModeForwards;
                [_shadowLayer addAnimation:anim forKey:@"animateShadowOpacity"];
            }
        }
        else {
            [shadowedView.layer.superlayer insertSublayer:_shadowLayer below:shadowedView.layer];
            _shadowLayer.frame = shadowedView.layer.frame;
            _shadowLayer.shadowPath = newPath;
        }
    }
}

- (BOOL)currentAnimationDuration:(CGFloat*)duration timingFunction:(CAMediaTimingFunction**)timingFunction {
    for (NSString* key in self.slidingControllerView.layer.animationKeys) {
        if ([key isEqualToString:@"bounds"]) {
            CABasicAnimation* other = (CABasicAnimation*)[self.slidingControllerView.layer animationForKey:key];
            
            if ([other isKindOfClass:[CABasicAnimation class]]) {
                *duration = other.duration;
                *timingFunction = other.timingFunction;
                return YES;
            }
        }
    }
    
    return NO;
}
@end

#pragma mark -

@implementation IIViewDeckView

@synthesize allowUserInteractionEnabled = _allowUserInteractionEnabled;

- (id)init {
    if ((self = [super init])) {
        _allowUserInteractionEnabled = YES;
        _userInteractionEnabled = [self isUserInteractionEnabled];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _allowUserInteractionEnabled = YES;
        _userInteractionEnabled = [self isUserInteractionEnabled];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _allowUserInteractionEnabled = YES;
        _userInteractionEnabled = [self isUserInteractionEnabled];
    }
    return self;
}

- (void)setAllowUserInteractionEnabled:(BOOL)allowUserInteractionEnabled {
    _allowUserInteractionEnabled = allowUserInteractionEnabled;
    [super setUserInteractionEnabled:_allowUserInteractionEnabled && _userInteractionEnabled];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    _userInteractionEnabled = userInteractionEnabled;
    [super setUserInteractionEnabled:_allowUserInteractionEnabled && _userInteractionEnabled];
}

- (void)setNeedsOffsetAdjustment {
    _needsOffsetAdjustment = YES;
}

- (BOOL)needsOffsetAdjustment {
    return _needsOffsetAdjustment;
}

@end

@implementation UIViewController (UIViewDeckItem)

@dynamic viewDeckController;

static const char* viewDeckControllerKey = "ViewDeckController";

- (IIViewDeckController*)viewDeckController_core {
    return objc_getAssociatedObject(self, viewDeckControllerKey);
}

- (IIViewDeckController*)viewDeckController {
    IIViewDeckController* result = [self viewDeckController_core];
    if (!result && self.navigationController) {
        result = [self.navigationController viewDeckController_core];
        if (!result) {
            for (UIViewController* controller in [self.navigationController.viewControllers reverseObjectEnumerator]) {
                if ([controller isKindOfClass:[IIViewDeckController class]])
                    result = (IIViewDeckController*)controller;
                else
                    result = [controller viewDeckController_core];
                if (result) {
                    if (result.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated)
                        break;
                    result = nil;
                }
            }
        }
    }
    if (!result && [self respondsToSelector:@selector(wrapController)] && self.wrapController)
        result = [self.wrapController viewDeckController];
    
    return result;
}

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController {
    objc_setAssociatedObject(self, viewDeckControllerKey, viewDeckController, OBJC_ASSOCIATION_ASSIGN);
}

- (void)vdc_presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    UIViewController* controller = self.viewDeckController ?: self;
    [controller vdc_presentModalViewController:modalViewController animated:animated]; // when we get here, the vdc_ method is actually the old, real method
}


#ifdef __IPHONE_5_0

- (void)vdc_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController* controller = self.viewDeckController ?: self;
    [controller vdc_presentViewController:viewControllerToPresent animated:animated completion:completion]; // when we get here, the vdc_ method is actually the old, real method
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
    if (![self instancesRespondToSelector:@selector(presentViewController:animated:completion:)]) {
        SEL presentModal = @selector(presentModalViewController:animated:);
        SEL vdcPresentModal = @selector(vdc_presentModalViewController:animated:);
        method_exchangeImplementations(class_getInstanceMethod(self, presentModal), class_getInstanceMethod(self, vdcPresentModal));
    }
    
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self vdc_swizzle];
        }
    });
}


@end

@implementation UIView (UIViewDeckView_HandleOffsetAdjustment)

+ (void)vdc_swizzle {
    SEL asv = @selector(addSubview:);
    SEL vdcasv = @selector(vdc_addSubview:);
    method_exchangeImplementations(class_getInstanceMethod(self, asv), class_getInstanceMethod(self, vdcasv));
}

- (void)vdc_addSubview:(UIView *)view {
    if ([view isKindOfClass:[IIViewDeckView class]]) {
        if ([self isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            // if the view needs offset adjustment (in case of a navigation controller), do it
            if ([(IIViewDeckView*)view needsOffsetAdjustment]) {
                CGRect fondlyRememberedFrame = view.frame; // remember the frame since it's actually correct
                
                // offset it
                view.frame = (CGRect) { view.frame.origin.x, 0, view.frame.size.width, view.frame.size.height + view.frame.origin.y };
                // remember the duration of the generated animation (since were in a transition view) to be able to
                // dispatch_after so we can correct this back at the correct time
                CGFloat duration = [view.layer animationForKey:@"position"].duration;
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // restore the correct frame
                    view.frame = fondlyRememberedFrame;
                });
                
                // recursively remove all animations (those are just position and bounds animations on all subviews)
                [self vdc_removeAllAnimationsRecursive:view];
                
            }
        }
    }
    
    // do your stuff, UIView
    [self vdc_addSubview:view];
}

- (void)vdc_removeAllAnimationsRecursive:(UIView*)view {
    [view.layer removeAllAnimations];
    for (UIView* subview in view.subviews) {
        [self vdc_removeAllAnimationsRecursive:subview];
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self vdc_swizzle];
        }
    });
}


@end


@implementation UIViewController (UIViewDeckController_ViewContainmentEmulation_Fakes)

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




@end

