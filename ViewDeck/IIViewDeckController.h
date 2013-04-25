//
//  IIViewDeckController.h
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

#import <UIKit/UIKit.h>

// thanks to http://stackoverflow.com/a/8594878/742176

#if TARGET_OS_IPHONE && defined(__IPHONE_5_0) && (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) && __clang__ && (__clang_major__ >= 3)
#define II_SDK_SUPPORTS_WEAK 1
#elif TARGET_OS_MAC && defined(__MAC_10_7) && (MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7) && __clang__ && (__clang_major__ >= 3)
#define II_SDK_SUPPORTS_WEAK 1
#else
#define II_SDK_SUPPORTS_WEAK 0
#endif

#if II_SDK_SUPPORTS_WEAK
#define __ii_weak        __weak
#define ii_weak_property weak
#else
#if __clang__ && (__clang_major__ >= 3)
#define __ii_weak __unsafe_unretained
#else
#define __ii_weak
#endif
#define ii_weak_property assign
#endif


@protocol IIViewDeckControllerDelegate;

enum {
    IIViewDeckLeftSide = 1,
    IIViewDeckRightSide = 2,
    IIViewDeckTopSide = 3,
    IIViewDeckBottomSide = 4,
};
typedef UInt32 IIViewDeckSide;

enum {
    IIViewDeckHorizontalOrientation = 1,
    IIViewDeckVerticalOrientation = 2
};
typedef UInt32 IIViewDeckOffsetOrientation;

enum {
    IIViewDeckNoPanning,              // no panning allowed
    IIViewDeckFullViewPanning,        // the default: touch anywhere in the center view to drag the center view around
    IIViewDeckNavigationBarPanning,   // panning only occurs when you start touching in the navigation bar (when the center controller is a UINavigationController with a visible navigation bar). Otherwise it will behave as IIViewDeckNoPanning. 
    IIViewDeckPanningViewPanning,      // panning only occurs when you start touching in a UIView set in panningView property
    IIViewDeckDelegatePanning,         // allows panning with a delegate
    IIViewDeckNavigationBarOrOpenCenterPanning,      //panning occurs when you start touching the navigation bar if the center controller is visible.  If the left or right controller is open, pannning occurs anywhere on the center controller, not just the navbar.
    IIViewDeckAllViewsPanning,        // you can pan anywhere in the viewdeck (including sideviews)
};
typedef UInt32 IIViewDeckPanningMode;


enum {
    IIViewDeckCenterHiddenUserInteractive,         // the center view stays interactive
    IIViewDeckCenterHiddenNotUserInteractive,      // the center view will become nonresponsive to useractions
    IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, // the center view will become nonresponsive to useractions, but will allow the user to tap it so that it closes
    IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing, // same as IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, but closes the center view bouncing
};
typedef UInt32 IIViewDeckCenterHiddenInteractivity;


enum {
    IIViewDeckNavigationControllerContained,      // the center navigation controller will act as any other viewcontroller. Pushing and popping view controllers will be contained in the centerview.
    IIViewDeckNavigationControllerIntegrated      // the center navigation controller will integrate with the viewdeck.
};
typedef UInt32 IIViewDeckNavigationControllerBehavior;


enum {
    IIViewDeckLedgeSizeMode, // when rotating, the ledge sizes are kept (side views are more/less visible)
    IIViewDeckViewSizeMode  // when rotating, the size view sizes are kept (ledges change)
};
typedef UInt32 IIViewDeckSizeMode;


enum {
    IIViewDeckDelegateOnly, // call the delegate only
    IIViewDeckDelegateAndSubControllers  // call the delegate and the subcontrollers
};
typedef UInt32 IIViewDeckDelegateMode;

#define IIViewDeckCenterHiddenCanTapToClose(interactivity) ((interactivity) == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose || (interactivity) == IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing)
#define IIViewDeckCenterHiddenIsInteractive(interactivity) ((interactivity) == IIViewDeckCenterHiddenUserInteractive)

extern NSString* NSStringFromIIViewDeckSide(IIViewDeckSide side);
extern IIViewDeckOffsetOrientation IIViewDeckOffsetOrientationFromIIViewDeckSide(IIViewDeckSide side);

@interface IIViewDeckController : UIViewController {
@private    
    CGPoint _panOrigin;
    UInt32 _viewAppeared;
    BOOL _viewFirstAppeared;
    UInt32 _sideAppeared[6];
    CGFloat _ledge[5];
    UIViewController* _controllers[6];
    CGFloat _offset, _maxLedge;
    CGSize _preRotationSize, _preRotationCenterSize;
    BOOL _preRotationIsLandscape;
    IIViewDeckOffsetOrientation _offsetOrientation;
    UIInterfaceOrientation _willAppearShouldArrangeViewsAfterRotation;
    CGPoint _willAppearOffset;
    NSMutableArray* _finishTransitionBlocks;
    int _disabledUserInteractions;
    BOOL _needsAddPannersIfAllPannersAreInactive;
}

typedef void (^IIViewDeckControllerBlock) (IIViewDeckController *controller, BOOL success);
typedef void (^IIViewDeckControllerBounceBlock) (IIViewDeckController *controller);

@property (nonatomic, ii_weak_property) __ii_weak id<IIViewDeckControllerDelegate> delegate;
@property (nonatomic, assign) IIViewDeckDelegateMode delegateMode;

@property (nonatomic, readonly, retain) NSArray* controllers;
@property (nonatomic, retain) IBOutlet UIViewController* centerController;
@property (nonatomic, retain) IBOutlet UIViewController* leftController;
@property (nonatomic, retain) IBOutlet UIViewController* rightController;
@property (nonatomic, retain) IBOutlet UIViewController* topController;
@property (nonatomic, retain) IBOutlet UIViewController* bottomController;
@property (nonatomic, readonly, assign) UIViewController* slidingController;

@property (nonatomic, retain) IBOutlet UIView* panningView;
@property (nonatomic, ii_weak_property) __ii_weak id<UIGestureRecognizerDelegate> panningGestureDelegate;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isElastic) BOOL elastic;

@property (nonatomic, assign) CGFloat leftSize;
@property (nonatomic, assign, readonly) CGFloat leftViewSize;
@property (nonatomic, assign, readonly) CGFloat leftLedgeSize;
@property (nonatomic, assign) CGFloat rightSize;
@property (nonatomic, assign, readonly) CGFloat rightViewSize;
@property (nonatomic, assign, readonly) CGFloat rightLedgeSize;
@property (nonatomic, assign) CGFloat topSize;
@property (nonatomic, assign, readonly) CGFloat topViewSize;
@property (nonatomic, assign, readonly) CGFloat topLedgeSize;
@property (nonatomic, assign) CGFloat bottomSize;
@property (nonatomic, assign, readonly) CGFloat bottomViewSize;
@property (nonatomic, assign, readonly) CGFloat bottomLedgeSize;
@property (nonatomic, assign) CGFloat maxSize;
@property (nonatomic, assign) BOOL resizesCenterView;
@property (nonatomic, assign) IIViewDeckPanningMode panningMode;
@property (nonatomic, assign) BOOL panningCancelsTouchesInView;
@property (nonatomic, assign) IIViewDeckCenterHiddenInteractivity centerhiddenInteractivity;
@property (nonatomic, assign) IIViewDeckNavigationControllerBehavior navigationControllerBehavior;
@property (nonatomic, assign) BOOL automaticallyUpdateTabBarItems;
@property (nonatomic, assign) IIViewDeckSizeMode sizeMode;
@property (nonatomic, assign) CGFloat bounceDurationFactor; // capped between 0.01 and 0.99. defaults to 0.3. Set to 0 to have the old 1.4 behavior (equal time for long part and short part of bounce)
@property (nonatomic, assign) CGFloat bounceOpenSideDurationFactor; // Same as bounceDurationFactor, but if set, will give independent control of the bounce as the side opens fully (first half of the bounce)
@property (nonatomic, assign) CGFloat openSlideAnimationDuration;
@property (nonatomic, assign) CGFloat closeSlideAnimationDuration;
@property (nonatomic, assign) CGFloat parallaxAmount;

@property (nonatomic, strong) NSString *centerTapperAccessibilityLabel; // Voice over accessibility label for button to close side panel
@property (nonatomic, strong) NSString *centerTapperAccessibilityHint;  // Voice over accessibility hint for button to close side panel

- (id)initWithCenterViewController:(UIViewController*)centerController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController;
- (id)initWithCenterViewController:(UIViewController*)centerController rightViewController:(UIViewController*)rightController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController;
- (id)initWithCenterViewController:(UIViewController*)centerController topViewController:(UIViewController*)topController;
- (id)initWithCenterViewController:(UIViewController*)centerController bottomViewController:(UIViewController*)bottomController;
- (id)initWithCenterViewController:(UIViewController*)centerController topViewController:(UIViewController*)topController bottomViewController:(UIViewController*)bottomController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController topViewController:(UIViewController*)topController bottomViewController:(UIViewController*)bottomController;

- (void)setLeftSize:(CGFloat)leftSize completion:(void(^)(BOOL finished))completion;
- (void)setRightSize:(CGFloat)rightSize completion:(void(^)(BOOL finished))completion;
- (void)setTopSize:(CGFloat)leftSize completion:(void(^)(BOOL finished))completion;
- (void)setBottomSize:(CGFloat)rightSize completion:(void(^)(BOOL finished))completion;
- (void)setMaxSize:(CGFloat)maxSize completion:(void(^)(BOOL finished))completion;

- (BOOL)toggleLeftView;
- (BOOL)openLeftView;
- (BOOL)closeLeftView;
- (BOOL)toggleLeftViewAnimated:(BOOL)animated;
- (BOOL)toggleLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewAnimated:(BOOL)animated;
- (BOOL)openLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeLeftViewAnimated:(BOOL)animated;
- (BOOL)closeLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeLeftViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)toggleRightView;
- (BOOL)openRightView;
- (BOOL)closeRightView;
- (BOOL)toggleRightViewAnimated:(BOOL)animated;
- (BOOL)toggleRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewAnimated:(BOOL)animated;
- (BOOL)openRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)openRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewAnimated:(BOOL)animated;
- (BOOL)closeRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)toggleTopView;
- (BOOL)openTopView;
- (BOOL)closeTopView;
- (BOOL)toggleTopViewAnimated:(BOOL)animated;
- (BOOL)toggleTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openTopViewAnimated:(BOOL)animated;
- (BOOL)openTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)openTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeTopViewAnimated:(BOOL)animated;
- (BOOL)closeTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeTopViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)closeTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)toggleBottomView;
- (BOOL)openBottomView;
- (BOOL)closeBottomView;
- (BOOL)toggleBottomViewAnimated:(BOOL)animated;
- (BOOL)toggleBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openBottomViewAnimated:(BOOL)animated;
- (BOOL)openBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)openBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeBottomViewAnimated:(BOOL)animated;
- (BOOL)closeBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeBottomViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)closeBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)toggleOpenView;
- (BOOL)toggleOpenViewAnimated:(BOOL)animated;
- (BOOL)toggleOpenViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;

- (BOOL)closeOpenView;
- (BOOL)closeOpenViewAnimated:(BOOL)animated;
- (BOOL)closeOpenViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeOpenViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeOpenViewBouncing:(IIViewDeckControllerBounceBlock)bounced;
- (BOOL)closeOpenViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide;
- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide withCompletion:(IIViewDeckControllerBlock)completed;
- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide toDistance:(CGFloat)distance duration:(NSTimeInterval)duration callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide toDistance:(CGFloat)distance duration:(NSTimeInterval)duration numberOfBounces:(CGFloat)numberOfBounces dampingFactor:(CGFloat)zeta callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;

- (BOOL)canRightViewPushViewControllerOverCenterController;
- (void)rightViewPushViewControllerOverCenterController:(UIViewController*)controller;

- (BOOL)isSideClosed:(IIViewDeckSide)viewDeckSide;
- (BOOL)isSideOpen:(IIViewDeckSide)viewDeckSide;
- (BOOL)isAnySideOpen;

- (CGFloat)statusBarHeight;

- (IIViewDeckSide)sideForController:(UIViewController*)controller;

@end


// Delegate protocol

@protocol IIViewDeckControllerDelegate <NSObject>

@optional
- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldPan:(UIPanGestureRecognizer*)panGestureRecognizer;

- (void)viewDeckController:(IIViewDeckController*)viewDeckController applyShadow:(CALayer*)shadowLayer withBounds:(CGRect)rect;

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didBounceViewSide:(IIViewDeckSide)viewDeckSide openingController:(UIViewController*)openingController;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didBounceViewSide:(IIViewDeckSide)viewDeckSide closingController:(UIViewController*)closingController;

- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldOpenViewSide:(IIViewDeckSide)viewDeckSide;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController willPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;

- (CGFloat)viewDeckController:(IIViewDeckController*)viewDeckController changesLedge:(CGFloat)ledge forSide:(IIViewDeckSide)viewDeckSide;

@end


// category on UIViewController to provide access to the viewDeckController in the 
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (UIViewDeckItem) 

@property(nonatomic,readonly,retain) IIViewDeckController *viewDeckController; 

@end


