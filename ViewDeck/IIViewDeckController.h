//
//  IIViewDeckController.h
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

#import <UIKit/UIKit.h>

// undefine this if you don't want to use 'the undocumented stuff' we have
// to work around some issues. This is limited to use of NSClassFromString() so
// you're probably safe anyway since ViewDeck *does not* use anything undocumented
// itself. The NSClassFromString() calls are use to detect certain classes, but
// that's it.
// But if you want to be absolutely safe: uncomment this line below.
//#define EXTRA_APPSTORE_SAFETY


// thanks to http://stackoverflow.com/a/8594878/742176

#ifdef __has_feature

    #if __has_feature(objc_arc_weak)
    #define __ii_weak        __weak
    #define ii_weak_property weak
    #elif __has_feature(objc_arc)
    #define ii_weak_property unsafe_unretained
    #define __ii_weak __unsafe_unretained
    #else
    #define ii_weak_property assign
    #define __ii_weak
    #endif

#else

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

#endif


#define II_DEPRECATED_DROP __deprecated_msg("This method is deprecated and will go away in 3.0.0 without a replacement. If you think it is still needed, please file an issue at https://github.com/ViewDeck/ViewDeck/issues/new")

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@protocol IIViewDeckControllerDelegate;

typedef NS_ENUM(NSInteger, IIViewDeckSide) {
    IIViewDeckLeftSide = 1,
    IIViewDeckRightSide = 2,
    IIViewDeckTopSide DEPRECATED_ATTRIBUTE = 3,
    IIViewDeckBottomSide DEPRECATED_ATTRIBUTE = 4,
};


typedef NS_ENUM(NSInteger, IIViewDeckOffsetOrientation) {
    IIViewDeckHorizontalOrientation = 1,
    IIViewDeckVerticalOrientation = 2
} II_DEPRECATED_DROP;


typedef NS_ENUM(NSInteger, IIViewDeckPanningMode) {
    IIViewDeckNoPanning,              /// no panning allowed
    IIViewDeckFullViewPanning,        /// the default: touch anywhere in the center view to drag the center view around
    IIViewDeckNavigationBarPanning,   /// panning only occurs when you start touching in the navigation bar (when the center controller is a UINavigationController with a visible navigation bar). Otherwise it will behave as IIViewDeckNoPanning.
    IIViewDeckPanningViewPanning,      /// panning only occurs when you start touching in a UIView set in panningView property
    IIViewDeckDelegatePanning,         /// allows panning with a delegate
    IIViewDeckNavigationBarOrOpenCenterPanning,      /// panning occurs when you start touching the navigation bar if the center controller is visible.  If the left or right controller is open, pannning occurs anywhere on the center controller, not just the navbar.
    IIViewDeckAllViewsPanning,        /// you can pan anywhere in the viewdeck (including sideviews)
};


typedef NS_ENUM(NSInteger, IIViewDeckCenterHiddenInteractivity) {
    IIViewDeckCenterHiddenUserInteractive,         /// the center view stays interactive
    IIViewDeckCenterHiddenNotUserInteractive,      /// the center view will become nonresponsive to useractions
    IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, /// the center view will become nonresponsive to useractions, but will allow the user to tap it so that it closes
    IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing, /// same as IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, but closes the center view bouncing
};


typedef NS_ENUM(NSInteger, IIViewDeckNavigationControllerBehavior) {
    IIViewDeckNavigationControllerContained,      /// the center navigation controller will act as any other viewcontroller. Pushing and popping view controllers will be contained in the centerview.
    IIViewDeckNavigationControllerIntegrated      /// the center navigation controller will integrate with the viewdeck.
} II_DEPRECATED_DROP;


typedef NS_ENUM(NSInteger, IIViewDeckSizeMode) {
    IIViewDeckLedgeSizeMode, /// when rotating, the ledge sizes are kept (side views are more/less visible)
    IIViewDeckViewSizeMode  /// when rotating, the size view sizes are kept (ledges change)
};


typedef NS_ENUM(NSInteger, IIViewDeckDelegateMode) {
    IIViewDeckDelegateOnly, /// call the delegate only
    IIViewDeckDelegateAndSubControllers  /// call the delegate and the subcontrollers
};



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
    NSMutableSet* _disabledPanClasses;
}

typedef void (^IIViewDeckControllerBlock) (IIViewDeckController *controller, BOOL success);
typedef void (^IIViewDeckControllerBounceBlock) (IIViewDeckController *controller);

@property (nonatomic, ii_weak_property) __ii_weak id<IIViewDeckControllerDelegate> delegate;
@property (nonatomic, assign) IIViewDeckDelegateMode delegateMode;

@property (nonatomic, readonly, retain) NSArray* controllers II_DEPRECATED_DROP;
@property (nonatomic, retain) IBOutlet UIViewController* centerController;
@property (nonatomic, retain) IBOutlet UIViewController* leftController;
@property (nonatomic, retain) IBOutlet UIViewController* rightController;
@property (nonatomic, retain) IBOutlet UIViewController* topController II_DEPRECATED_DROP;
@property (nonatomic, retain) IBOutlet UIViewController* bottomController II_DEPRECATED_DROP;
@property (nonatomic, readonly, assign) UIViewController* slidingController II_DEPRECATED_DROP;

@property (nonatomic, retain) IBOutlet UIView* panningView II_DEPRECATED_DROP;
@property (nonatomic, ii_weak_property) __ii_weak id<UIGestureRecognizerDelegate> panningGestureDelegate;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isElastic) BOOL elastic;

@property (nonatomic, assign) CGFloat leftSize;
@property (nonatomic, assign, readonly) CGFloat leftViewSize;
@property (nonatomic, assign, readonly) CGFloat leftLedgeSize;
@property (nonatomic, assign) CGFloat rightSize;
@property (nonatomic, assign, readonly) CGFloat rightViewSize;
@property (nonatomic, assign, readonly) CGFloat rightLedgeSize;
@property (nonatomic, assign) CGFloat topSize II_DEPRECATED_DROP;
@property (nonatomic, assign, readonly) CGFloat topViewSize II_DEPRECATED_DROP;
@property (nonatomic, assign, readonly) CGFloat topLedgeSize II_DEPRECATED_DROP;
@property (nonatomic, assign) CGFloat bottomSize II_DEPRECATED_DROP;
@property (nonatomic, assign, readonly) CGFloat bottomViewSize II_DEPRECATED_DROP;
@property (nonatomic, assign, readonly) CGFloat bottomLedgeSize II_DEPRECATED_DROP;
@property (nonatomic, assign) CGFloat maxSize;
@property (nonatomic, assign) CGFloat centerViewOpacity;
@property (nonatomic, assign) CGFloat centerViewCornerRadius;
@property (nonatomic, assign) BOOL shadowEnabled;
@property (nonatomic, assign) BOOL resizesCenterView;
@property (nonatomic, assign) IIViewDeckPanningMode panningMode;
@property (nonatomic, assign) BOOL panningCancelsTouchesInView;
@property (nonatomic, assign) IIViewDeckCenterHiddenInteractivity centerhiddenInteractivity;
@property (nonatomic, assign) IIViewDeckNavigationControllerBehavior navigationControllerBehavior II_DEPRECATED_DROP;
@property (nonatomic, assign) BOOL automaticallyUpdateTabBarItems II_DEPRECATED_DROP;
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
- (id)initWithCenterViewController:(UIViewController*)centerController topViewController:(UIViewController*)topController II_DEPRECATED_DROP;
- (id)initWithCenterViewController:(UIViewController*)centerController bottomViewController:(UIViewController*)bottomController II_DEPRECATED_DROP;
- (id)initWithCenterViewController:(UIViewController*)centerController topViewController:(UIViewController*)topController bottomViewController:(UIViewController*)bottomController II_DEPRECATED_DROP;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController topViewController:(UIViewController*)topController bottomViewController:(UIViewController*)bottomController II_DEPRECATED_DROP;

- (void)setLeftSize:(CGFloat)leftSize completion:(void(^)(BOOL finished))completion;
- (void)setRightSize:(CGFloat)rightSize completion:(void(^)(BOOL finished))completion;
- (void)setTopSize:(CGFloat)leftSize completion:(void(^)(BOOL finished))completion II_DEPRECATED_DROP;
- (void)setBottomSize:(CGFloat)rightSize completion:(void(^)(BOOL finished))completion II_DEPRECATED_DROP;
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

- (BOOL)toggleTopView II_DEPRECATED_DROP;
- (BOOL)openTopView II_DEPRECATED_DROP;
- (BOOL)closeTopView II_DEPRECATED_DROP;
- (BOOL)toggleTopViewAnimated:(BOOL)animated II_DEPRECATED_DROP;
- (BOOL)toggleTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)openTopViewAnimated:(BOOL)animated II_DEPRECATED_DROP;
- (BOOL)openTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)openTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced II_DEPRECATED_DROP;
- (BOOL)openTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)closeTopViewAnimated:(BOOL)animated II_DEPRECATED_DROP;
- (BOOL)closeTopViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)closeTopViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)closeTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced II_DEPRECATED_DROP;
- (BOOL)closeTopViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;

- (BOOL)toggleBottomView II_DEPRECATED_DROP;
- (BOOL)openBottomView II_DEPRECATED_DROP;
- (BOOL)closeBottomView II_DEPRECATED_DROP;
- (BOOL)toggleBottomViewAnimated:(BOOL)animated II_DEPRECATED_DROP;
- (BOOL)toggleBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)openBottomViewAnimated:(BOOL)animated II_DEPRECATED_DROP;
- (BOOL)openBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)openBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced II_DEPRECATED_DROP;
- (BOOL)openBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)closeBottomViewAnimated:(BOOL)animated II_DEPRECATED_DROP;
- (BOOL)closeBottomViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)closeBottomViewAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;
- (BOOL)closeBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced II_DEPRECATED_DROP;
- (BOOL)closeBottomViewBouncing:(IIViewDeckControllerBounceBlock)bounced completion:(IIViewDeckControllerBlock)completed II_DEPRECATED_DROP;

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

- (CGFloat)statusBarHeight II_DEPRECATED_DROP;

- (IIViewDeckSide)sideForController:(UIViewController*)controller II_DEPRECATED_DROP;

- (void)disablePanOverViewsOfClass:(Class)viewClass;
- (void)enablePanOverViewsOfClass:(Class)viewClass;
- (BOOL)canPanOverViewsOfClass:(Class)viewClass;
- (NSArray*)viewClassesWithDisabledPan;

@end


// Delegate protocol

@protocol IIViewDeckControllerDelegate <NSObject>

@optional
- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldPan:(UIPanGestureRecognizer*)panGestureRecognizer;

- (void)viewDeckController:(IIViewDeckController*)viewDeckController applyShadow:(CALayer*)shadowLayer withBounds:(CGRect)rect II_DEPRECATED_DROP;

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

- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldBeginPanOverView:(UIView*)view;

@end


// category on UIViewController to provide access to the viewDeckController in the 
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (UIViewDeckItem) 

@property(nonatomic,readonly,retain) IIViewDeckController *viewDeckController; 

@end

#pragma clang diagnostic pop


