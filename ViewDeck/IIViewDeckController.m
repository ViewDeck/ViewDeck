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


#import "IIViewDeckController.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>

#define DURATION_FAST 0.3
#define DURATION_SLOW 0.3
#define SLIDE_DURATION(animated,duration) ((animated) ? (duration) : 0)
#define OPEN_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_FAST)
#define CLOSE_SLIDE_DURATION(animated) SLIDE_DURATION(animated,DURATION_SLOW)

@interface IIViewDeckController () <UIGestureRecognizerDelegate> {
    CGFloat _panOrigin;
    BOOL _viewAppeared;
    CGFloat _preRotationWidth, _leftWidth, _rightWidth;
}

@property (nonatomic, retain) UIView* referenceView;
@property (nonatomic, readonly) CGRect referenceBounds;
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

- (BOOL)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void(^)(IIViewDeckController* controller))completed;
- (void)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void(^)(IIViewDeckController* controller))completed;
- (BOOL)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void(^)(IIViewDeckController* controller))completed;
- (void)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void(^)(IIViewDeckController* controller))completed;

- (CGRect)slidingRectForOffset:(CGFloat)offset;
- (CGSize)slidingSizeForOffset:(CGFloat)offset;

- (void)setSlidingAndReferenceViews;
- (void)applyShadowToSlidingView;
- (void)restoreShadowToSlidingView;
- (void)arrangeViewsAfterRotation;

- (void)centerViewVisible;
- (void)centerViewHidden;

- (void)addPanners;
- (void)removePanners;

- (BOOL)checkDelegate:(SEL)selector animated:(BOOL)animated;
- (void)performDelegate:(SEL)selector animated:(BOOL)animated;

- (void)relayAppearanceMethod:(void(^)(UIViewController* controller))relay;
- (BOOL)mustRelayAppearance;

@end 


@interface UIViewController (UIViewDeckItem_Internal) 

// internal setter for the viewDeckController property on UIViewController
- (void)setViewDeckController:(IIViewDeckController*)viewDeckController;

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

#pragma mark - Initalisation and deallocation

- (id)initWithCenterViewController:(UIViewController*)centerController {
    if ((self = [super init])) {
        _elastic = YES;
        _panningMode = IIViewDeckFullViewPanning;
        _navigationControllerBehavior = IIViewDeckNavigationControllerContained;
        _centerhiddenInteractivity = IIViewDeckCenterHiddenUserInteractive;
        _rotationBehavior = IIViewDeckRotationKeepsLedgeSizes;
        _viewAppeared = NO;
        _resizesCenterView = NO;
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
    
    II_RELEASE(_slidingController), _slidingController = nil;
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
    NSMutableArray* result = [NSMutableArray arrayWithObject:self.centerController];
    if (self.leftController) [result addObject:self.leftController];
    if (self.rightController) [result addObject:self.rightController];
    return [NSArray arrayWithArray:result];
}

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
    if (_viewAppeared && self.slidingControllerView.frame.origin.x == self.referenceBounds.size.width - _leftLedge) {
        if (leftLedge < _leftLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                self.slidingControllerView.frame = [self slidingRectForOffset:self.referenceBounds.size.width - leftLedge];
            }];
        }
        else if (leftLedge > _leftLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                self.slidingControllerView.frame = [self slidingRectForOffset:self.referenceBounds.size.width - leftLedge];
            }];
        }
    }
    _leftLedge = leftLedge;
}

- (void)setRightLedge:(CGFloat)rightLedge {
    rightLedge = MAX(rightLedge, MIN(self.referenceBounds.size.width, rightLedge));
    if (_viewAppeared && self.slidingControllerView.frame.origin.x == _rightLedge - self.referenceBounds.size.width) {
        if (rightLedge < _rightLedge) {
            [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) animations:^{
                self.slidingControllerView.frame = [self slidingRectForOffset:rightLedge - self.referenceBounds.size.width];
            }];
        }
        else if (rightLedge > _rightLedge) {
            [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) animations:^{
                self.slidingControllerView.frame = [self slidingRectForOffset:rightLedge - self.referenceBounds.size.width];
            }];
        }
    }
    _rightLedge = rightLedge;
}

#pragma mark - View lifecycle

- (void)loadView
{
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
    
    [self.view addObserver:self forKeyPath:@"bounds" options:NSKeyValueChangeSetting context:nil];

    BOOL appeared = _viewAppeared;
    if (!_viewAppeared) {
        [self setSlidingAndReferenceViews];
        
        [self.centerController.view removeFromSuperview];
        [self.centerView addSubview:self.centerController.view];
        [self.leftController.view removeFromSuperview];
        [self.referenceView insertSubview:self.leftController.view belowSubview:self.slidingControllerView];
        [self.rightController.view removeFromSuperview];
        [self.referenceView insertSubview:self.rightController.view belowSubview:self.slidingControllerView];
        
        self.centerView.frame = self.referenceBounds;
        self.centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerController.view.frame = self.referenceBounds;
        self.slidingControllerView.frame = self.referenceBounds;
        self.slidingControllerView.hidden = NO;
        self.leftController.view.frame = self.referenceBounds;
        self.leftController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.leftController.view.hidden = YES;
        self.rightController.view.frame = self.referenceBounds;
        self.rightController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.rightController.view.hidden = YES;
        
        [self applyShadowToSlidingView];
        _viewAppeared = YES;
    }
    else 
        [self arrangeViewsAfterRotation];
    
    [self addPanners];

    if (self.slidingControllerView.frame.origin.x == 0) 
        [self centerViewVisible];
    else
        [self centerViewHidden];
   
    if (appeared) {
        [self relayAppearanceMethod:^(UIViewController *controller) {
            [controller viewWillAppear:animated];
        }];
    }
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
    
    [self closeLeftView];
    [self closeRightView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.view removeObserver:self forKeyPath:@"bounds"];

    [self relayAppearanceMethod:^(UIViewController *controller) {
        [controller viewDidDisappear:animated];
    }];
}

#pragma mark - rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _preRotationWidth = self.referenceBounds.size.width;
        
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

    [self arrangeViewsAfterRotation];
    
    [self.centerController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.leftController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.rightController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self restoreShadowToSlidingView];
    
    [self.centerController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.leftController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.rightController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self applyShadowToSlidingView];

    [self.centerController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.leftController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.rightController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)arrangeViewsAfterRotation {
    if (_preRotationWidth <= 0) return;
    
    CGFloat offset = self.slidingControllerView.frame.origin.x;
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
        self.leftController.view.frame = (CGRect) { self.leftController.view.frame.origin, _leftWidth, self.leftController.view.frame.size.height };
        self.rightController.view.frame = (CGRect) { self.rightController.view.frame.origin, _rightWidth, self.rightController.view.frame.size.height };
    }
    self.slidingControllerView.frame = [self slidingRectForOffset:offset];
    self.centerController.view.frame = self.referenceBounds;
    
    _preRotationWidth = 0;
}

#pragma mark - controller state

- (BOOL)leftControllerIsClosed {
    return !self.leftController || CGRectGetMinX(self.slidingControllerView.frame) <= 0;
}

- (BOOL)rightControllerIsClosed {
    return !self.rightController || CGRectGetMaxX(self.slidingControllerView.frame) >= self.referenceBounds.size.width;
}

- (void)showCenterView {
    [self showCenterView:YES];
}

- (void)showCenterView:(BOOL)animated {
    [self showCenterView:animated completion:nil];
}

- (void)showCenterView:(BOOL)animated  completion:(void(^)(IIViewDeckController* controller))completed {
    if (!self.leftController.view.hidden) 
        [self closeLeftViewAnimated:animated completion:completed];
    if (!self.rightController.view.hidden) 
        [self closeRightViewAnimated:animated completion:completed];
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
    [self toggleLeftViewAnimated:animated completion:nil];
}

- (void)toggleLeftViewAnimated:(BOOL)animated completion:(void (^)(IIViewDeckController *))completed {
    if ([self leftControllerIsClosed]) 
        [self openLeftViewAnimated:animated completion:completed];
    else
        [self closeLeftViewAnimated:animated completion:completed];
}

- (void)openLeftViewAnimated:(BOOL)animated {
    [self openLeftViewAnimated:animated completion:nil];
}

- (void)openLeftViewAnimated:(BOOL)animated completion:(void (^)(IIViewDeckController *))completed {
    [self openLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut completion:completed];
}


- (void)openLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void (^)(IIViewDeckController *))completed {
    if (!self.leftController || CGRectGetMinX(self.slidingControllerView.frame) == self.leftLedge) return;
    
    // check the delegate to allow opening
    if (![self checkDelegate:@selector(viewDeckControllerWillOpenLeftView:animated:) animated:animated]) return;
    // also close the right view if it's open. Since the delegate can cancel the close, check the result.
    if (![self closeRightViewAnimated:animated options:options completion:completed]) return;
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.leftController.view.hidden = NO;
        self.slidingControllerView.frame = [self slidingRectForOffset:self.referenceBounds.size.width - self.leftLedge];
        [self centerViewHidden];
    } completion:^(BOOL finished) {
        if (completed) completed(self);
        [self performDelegate:@selector(viewDeckControllerDidOpenLeftView:animated:) animated:animated];
    }];
}

- (void)closeLeftViewAnimated:(BOOL)animated {
    [self closeLeftViewAnimated:animated completion:nil];
}

- (void)closeLeftViewAnimated:(BOOL)animated completion:(void (^)(IIViewDeckController *))completed {
    [self closeLeftViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut completion:completed];
}

- (BOOL)closeLeftViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void (^)(IIViewDeckController *))completed {
    if (self.leftControllerIsClosed) return YES;

    // check the delegate to allow closing
    if (![self checkDelegate:@selector(viewDeckControllerWillCloseLeftView:animated:) animated:animated]) return NO;

    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingControllerView.frame = [self slidingRectForOffset:0];
        [self centerViewVisible];
    } completion:^(BOOL finished) {
        self.leftController.view.hidden = YES;
        if (completed) completed(self);
        [self performDelegate:@selector(viewDeckControllerDidCloseLeftView:animated:) animated:animated];
        [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:animated];
    }];
    
    return YES;
}

- (void)closeLeftViewBouncing:(void(^)(IIViewDeckController* controller))bounced {
    [self closeLeftViewBouncing:bounced completion:nil];
}

- (void)closeLeftViewBouncing:(void(^)(IIViewDeckController* controller))bounced completion:(void (^)(IIViewDeckController *))completed {
    if (self.leftControllerIsClosed) return;
    
    // check the delegate to allow closing
    if (![self checkDelegate:@selector(viewDeckControllerWillCloseLeftView:animated:) animated:YES]) return;
    
    // first open the view completely, run the block (to allow changes) and close it again.
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingControllerView.frame = [self slidingRectForOffset:self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        // run block if it's defined
        if (bounced) bounced(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewDeckController:didBounceWithClosingController:)]) 
            [self.delegate viewDeckController:self didBounceWithClosingController:self.leftController];
        
        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            self.slidingControllerView.frame = [self slidingRectForOffset:0];
            [self centerViewVisible];
        } completion:^(BOOL finished) {
            self.leftController.view.hidden = YES;
            if (completed) completed(self);
            [self performDelegate:@selector(viewDeckControllerDidCloseLeftView:animated:) animated:YES];
            [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:YES];
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
    [self toggleRightViewAnimated:animated completion:nil];
}

- (void)toggleRightViewAnimated:(BOOL)animated completion:(void (^)(IIViewDeckController *))completed {
    if ([self rightControllerIsClosed]) 
        [self openRightViewAnimated:animated completion:completed];
    else
        [self closeRightViewAnimated:animated completion:completed];
}

- (void)openRightViewAnimated:(BOOL)animated {
    [self openRightViewAnimated:animated completion:nil];
}

- (void)openRightViewAnimated:(BOOL)animated completion:(void (^)(IIViewDeckController *))completed {
    [self openRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut completion:completed];
}

- (void)openRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void (^)(IIViewDeckController *))completed {
    if (!self.rightController || CGRectGetMaxX(self.slidingControllerView.frame) == self.rightLedge) return;

    // check the delegate to allow opening
    if (![self checkDelegate:@selector(viewDeckControllerWillOpenRightView:animated:) animated:animated]) return;
    // also close the left view if it's open. Since the delegate can cancel the close, check the result.
    if (![self closeLeftViewAnimated:animated options:options completion:completed]) return;
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.rightController.view.hidden = NO;
        self.slidingControllerView.frame = [self slidingRectForOffset:self.rightLedge - self.referenceBounds.size.width];
        [self centerViewHidden];
    } completion:^(BOOL finished) {
        if (completed) completed(self);
        [self performDelegate:@selector(viewDeckControllerDidOpenRightView:animated:) animated:animated];
    }];
}

- (void)closeRightViewAnimated:(BOOL)animated {
    [self closeRightViewAnimated:animated completion:nil];
}

- (void)closeRightViewAnimated:(BOOL)animated completion:(void (^)(IIViewDeckController *))completed {
    [self closeRightViewAnimated:animated options:UIViewAnimationOptionCurveEaseInOut completion:completed];
}

- (BOOL)closeRightViewAnimated:(BOOL)animated options:(UIViewAnimationOptions)options completion:(void (^)(IIViewDeckController *))completed {
    if (self.rightControllerIsClosed) return YES;
    
    // check the delegate to allow closing
    if (![self checkDelegate:@selector(viewDeckControllerWillCloseRightView:animated:) animated:animated]) return NO;
    
    [UIView animateWithDuration:CLOSE_SLIDE_DURATION(animated) delay:0 options:options | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingControllerView.frame = [self slidingRectForOffset:0];
        [self centerViewVisible];
    } completion:^(BOOL finished) {
        if (completed) completed(self);
        self.rightController.view.hidden = YES;
        [self performDelegate:@selector(viewDeckControllerDidCloseRightView:animated:) animated:animated];
        [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:animated];
    }];
    
    return YES;
}

- (void)closeRightViewBouncing:(void(^)(IIViewDeckController* controller))bounced {
    [self closeRightViewBouncing:bounced completion:nil];
}

- (void)closeRightViewBouncing:(void(^)(IIViewDeckController* controller))bounced completion:(void (^)(IIViewDeckController *))completed {
    if (self.rightControllerIsClosed) return;
    
    // check the delegate to allow closing
    if (![self checkDelegate:@selector(viewDeckControllerWillCloseRightView:animated:) animated:YES]) return;
    
    [UIView animateWithDuration:OPEN_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews animations:^{
        self.slidingControllerView.frame = [self slidingRectForOffset:-self.referenceBounds.size.width];
    } completion:^(BOOL finished) {
        if (bounced)  bounced(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewDeckController:didBounceWithClosingController:)]) 
            [self.delegate viewDeckController:self didBounceWithClosingController:self.rightController];

        [UIView animateWithDuration:CLOSE_SLIDE_DURATION(YES) delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews animations:^{
            self.slidingControllerView.frame = [self slidingRectForOffset:0];
            [self centerViewVisible];
        } completion:^(BOOL finished) {
            self.rightController.view.hidden = YES;
            if (completed) completed(self);
            [self performDelegate:@selector(viewDeckControllerDidCloseRightView:animated:) animated:YES];
            [self performDelegate:@selector(viewDeckControllerDidShowCenterView:animated:) animated:YES];
        }];
    }];
}

#pragma mark - Pre iOS5 message relaying

- (void)relayAppearanceMethod:(void(^)(UIViewController* controller))relay {
    relay(self.centerController);
    relay(self.leftController);
    relay(self.rightController);
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    _panOrigin = self.slidingControllerView.frame.origin.x;
    return YES;
}

- (void)panned:(UIPanGestureRecognizer*)panner {
    if (!_enabled) return;
    
    CGPoint pan = [panner translationInView:self.referenceView];
    CGFloat x = pan.x + _panOrigin;
    
    if (!self.leftController) x = MIN(0, x);
    if (!self.rightController) x = MAX(0, x);

    CGFloat w = self.referenceBounds.size.width;
    CGFloat lx = MAX(MIN(x, w-self.leftLedge), -w+self.rightLedge);

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
    self.slidingControllerView.frame = [self slidingRectForOffset:x];

    BOOL rightWasHidden = self.rightController.view.hidden;
    BOOL leftWasHidden = self.leftController.view.hidden;
    self.rightController.view.hidden = x >= 0;
    self.leftController.view.hidden = x <= 0;
    
    if ([self.delegate respondsToSelector:@selector(viewDeckController:didPanToOffset:)])
        [self.delegate viewDeckController:self didPanToOffset:x];

    if ((self.leftController.view.hidden && !leftWasHidden) || (self.rightController.view.hidden && !rightWasHidden)) {
        [self centerViewVisible];
    }
    else if (leftWasHidden && rightWasHidden && (!self.leftController.view.hidden || !self.leftController.view.hidden)) {
        [self centerViewHidden];
    }

    if (panner.state == UIGestureRecognizerStateBegan) {
        if (x > 0) {
            [self checkDelegate:@selector(viewDeckControllerWillOpenLeftView:animated:) animated:NO];
        }
        else if (x < 0) {
            [self checkDelegate:@selector(viewDeckControllerWillOpenRightView:animated:) animated:NO];
        }
    }
    
    if (panner.state == UIGestureRecognizerStateEnded) {    
        CGFloat lw3 = (w-self.leftLedge) / 3.0;
        CGFloat rw3 = (w-self.rightLedge) / 3.0;
        CGFloat velocity = [panner velocityInView:self.referenceView].x;
        if (ABS(velocity) < 500) {
            // small velocity, no movement
            if (x >= w - self.leftLedge - lw3) {
                [self openLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut completion:nil];
            }
            else if (x <= self.rightLedge + rw3 - w) {
                [self openRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut completion:nil];
            }
            else
                [self showCenterView:YES];
        }
        else if (velocity < 0) {
            // swipe to the left
            if (x < 0) 
                [self openRightViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut completion:nil];
            else 
                [self showCenterView:YES];
        }
        else if (velocity > 0) {
            // swipe to the right
            if (x > 0) 
                [self openLeftViewAnimated:YES options:UIViewAnimationOptionCurveEaseOut completion:nil];
            else 
                [self showCenterView:YES];
        }
    }
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
            if (self.navigationController && !self.navigationController.navigationBarHidden && self.navigationControllerBehavior == IIViewDeckNavigationControllerContained) 
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
    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        ok = ok & (BOOL)objc_msgSend(self.delegate, selector, self, animated);

    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector]) 
            ok = ok & (BOOL)objc_msgSend(controller, selector, self, animated);
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector]) 
                ok = ok & (BOOL)objc_msgSend(topController, selector, self, animated);
        }
    }

    return ok;
}

- (void)performDelegate:(SEL)selector animated:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:selector]) 
        objc_msgSend(self.delegate, selector, self, animated);

    for (UIViewController* controller in self.controllers) {
        // check controller first
        if ([controller respondsToSelector:selector]) 
            objc_msgSend(controller, selector, self, animated);
        // if that fails, check if it's a navigation controller and use the top controller
        else if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController* topController = ((UINavigationController*)controller).topViewController;
            if ([topController respondsToSelector:selector]) 
                objc_msgSend(topController, selector, self, animated);
        }
    }
}


#pragma mark - Properties

- (BOOL)mustRelayAppearance {
    return ![self respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)] || ![self performSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.centerController.title = title;
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

- (void)setLeftController:(UIViewController *)leftController {
    if (_viewAppeared) {
        if (_leftController == leftController) return;
        
        if (_leftController) {
            if (self.mustRelayAppearance) [_rightController viewWillDisappear:NO];
            [_leftController.view removeFromSuperview];
            if (self.mustRelayAppearance) [_rightController viewDidDisappear:NO];
            _leftController.viewDeckController = nil;
        }
        
        if (leftController) {
            if (leftController == self.centerController) self.centerController = nil;
            if (leftController == self.rightController) self.rightController = nil;

            leftController.viewDeckController = self;
            if (self.mustRelayAppearance) [_leftController viewWillAppear:NO];
            if (self.slidingController)
                [self.referenceView insertSubview:leftController.view belowSubview:self.slidingControllerView];
            else
                [self.referenceView addSubview:leftController.view];
            leftController.view.hidden = self.slidingControllerView.frame.origin.x <= 0;
            leftController.view.frame = self.referenceBounds;
            leftController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
    }

    _leftController.viewDeckController = nil;
    II_RELEASE(_leftController);
    _leftController = leftController;
    II_RETAIN(_leftController);
    _leftController.viewDeckController = self;
    if (_viewAppeared && self.mustRelayAppearance) [_leftController viewDidAppear:NO];
}



- (void)setCenterController:(UIViewController *)centerController {
    if (!_viewAppeared) {
        _centerController.viewDeckController = nil;
        II_RELEASE(_centerController);
        [_centerController removeObserver:self forKeyPath:@"title"];
        _centerController = centerController;
        [_centerController addObserver:self forKeyPath:@"title" options:0 context:nil];
        _centerController.viewDeckController = self;
        II_RETAIN(_centerController);
        return;
    }

    if (_centerController == centerController) return;
    
    [self removePanners];
    CGRect currentFrame = self.referenceBounds;
    if (_centerController) {
        [self restoreShadowToSlidingView];
        currentFrame = _centerController.view.frame;
        if (self.mustRelayAppearance) [_centerController viewWillDisappear:NO];
        [_centerController.view removeFromSuperview];
        _centerController.viewDeckController = nil;
        [_centerController removeObserver:self forKeyPath:@"title"];
        if (self.mustRelayAppearance) [_centerController viewDidDisappear:NO];
        II_RELEASE(_centerController);
        _centerController = nil;
    }
    
    if (centerController) {
        if (centerController == self.leftController) self.leftController = nil;
        if (centerController == self.rightController) self.rightController = nil;

        UINavigationController* navController = [centerController isKindOfClass:[UINavigationController class]] 
            ? (UINavigationController*)centerController 
            : nil;
        BOOL barHidden = NO;
        if (navController != nil && !navController.navigationBarHidden) {
            barHidden = YES;
            navController.navigationBarHidden = YES;
        }

        _centerController = centerController;
        II_RETAIN(_centerController);
        [_centerController addObserver:self forKeyPath:@"title" options:0 context:nil];
        _centerController.viewDeckController = self;
        [self setSlidingAndReferenceViews];
        centerController.view.frame = currentFrame;
        centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        centerController.view.hidden = NO;
        if (self.mustRelayAppearance) [self.centerController viewWillAppear:NO];
        [self.centerView addSubview:centerController.view];
        
        if (barHidden) {
            navController.navigationBarHidden = NO;
        }
        
        [self addPanners];
        [self applyShadowToSlidingView];
        if (self.mustRelayAppearance) [self.centerController viewDidAppear:NO];
    }
    else {
        _centerController = nil;
    }
}

- (void)setRightController:(UIViewController *)rightController {
    if (_viewAppeared) {
        if (_rightController == rightController) return;
        
        if (_rightController) {
            if (self.mustRelayAppearance) [_rightController viewWillDisappear:NO];
            [_rightController.view removeFromSuperview];
            if (self.mustRelayAppearance) [_rightController viewDidDisappear:NO];
            _rightController.viewDeckController = nil;
        }
        
        if (rightController) {
            if (rightController == self.centerController) self.centerController = nil;
            if (rightController == self.leftController) self.leftController = nil;
            
            rightController.viewDeckController = self;
            if (self.mustRelayAppearance) [_rightController viewWillAppear:NO];
            if (self.slidingController) 
                [self.referenceView insertSubview:rightController.view belowSubview:self.slidingControllerView];
            else
                [self.referenceView addSubview:rightController.view];
            rightController.view.hidden = self.slidingControllerView.frame.origin.x >= 0;
            rightController.view.frame = self.referenceBounds;
            rightController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
    }

    _rightController.viewDeckController = nil;
    II_RELEASE(_rightController);
    _rightController = rightController;
    II_RETAIN(_rightController);
    _rightController.viewDeckController = self;
    if (_viewAppeared && self.mustRelayAppearance) [_rightController viewDidAppear:NO];
}

- (void)setSlidingAndReferenceViews {
    if (self.navigationController && self.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated) {
        _slidingController = self.navigationController;
        self.referenceView = [self.navigationController.view superview];
    }
    else {
        _slidingController = self.centerController;
        self.referenceView = self.view;
    }
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
    if ([@"title" isEqualToString:keyPath]) {
        if (![[super title] isEqualToString:self.centerController.title]) {
            self.title = self.centerController.title;
        }
    }
    else if ([keyPath isEqualToString:@"bounds"]) {
        CGFloat offset = self.slidingControllerView.frame.origin.x;
        self.slidingControllerView.frame = [self slidingRectForOffset:offset];
        self.slidingControllerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.referenceBounds].CGPath;
        UINavigationController* navController = [self.centerController isKindOfClass:[UINavigationController class]] 
            ? (UINavigationController*)self.centerController 
            : nil;
        if (navController != nil && !navController.navigationBarHidden) {
            navController.navigationBarHidden = YES;
            navController.navigationBarHidden = NO;
        }
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
        shadowedView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.referenceBounds] CGPath];
    }
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

    return result;
}

- (void)setViewDeckController:(IIViewDeckController*)viewDeckController {
    objc_setAssociatedObject(self, viewDeckControllerKey, viewDeckController, OBJC_ASSOCIATION_RETAIN);
}

- (void)vdc_presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    UIViewController* controller = self.viewDeckController ? self.viewDeckController : self;
    [controller vdc_presentModalViewController:modalViewController animated:animated]; // when we get here, the vdc_ method is actually the old, real method
}

- (void)vdc_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController* controller = self.viewDeckController ? self.viewDeckController : self;
    [controller vdc_presentViewController:viewControllerToPresent animated:animated completion:completion]; // when we get here, the vdc_ method is actually the old, real method
}

- (void)vdc_dismissModalViewControllerAnimated:(BOOL)animated {
    UIViewController* controller = self.viewDeckController ? self.viewDeckController : self;
    [controller vdc_dismissModalViewControllerAnimated:animated]; // when we get here, the vdc_ method is actually the old, real method
}

- (void)vdc_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController* controller = self.viewDeckController ? self.viewDeckController : self;
    [controller vdc_dismissViewControllerAnimated:flag completion:completion]; // when we get here, the vdc_ method is actually the old, real method
}

+ (void)vdc_swizzle {
    SEL presentModal = @selector(presentModalViewController:animated:);
    SEL vdcPresentModal = @selector(vdc_presentModalViewController:animated:);
    method_exchangeImplementations(class_getInstanceMethod(self, presentModal), class_getInstanceMethod(self, vdcPresentModal));

    SEL presentVC = @selector(presentViewController:animated:completion:);
    SEL vdcPresentVC = @selector(vdc_presentViewController:animated:completion:);
    method_exchangeImplementations(class_getInstanceMethod(self, presentVC), class_getInstanceMethod(self, vdcPresentVC));

    SEL dismisModal = @selector(dismissModalViewControllerAnimated:);
    SEL vdcDismissModal = @selector(vdc_dismissModalViewControllerAnimated:);
    method_exchangeImplementations(class_getInstanceMethod(self, dismisModal), class_getInstanceMethod(self, vdcDismissModal));

    SEL dismissVC = @selector(dismissViewControllerAnimated:completion:);
    SEL vdcDismissVC = @selector(vdc_dismissViewControllerAnimated:completion:);
    method_exchangeImplementations(class_getInstanceMethod(self, dismissVC), class_getInstanceMethod(self, vdcDismissVC));
}

+ (void)load {
    [super load];
    [self vdc_swizzle];
}


@end

