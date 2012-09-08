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

@protocol IIViewDeckControllerDelegate;

enum {
    IIViewDeckLeftSide = 1,
    IIViewDeckRightSide = 2,
};
typedef UInt32 IIViewDeckSide;

enum {
    IIViewDeckHorizontalOffset = 1,
    IIViewDeckVerticalOffset = 2
};
typedef UInt32 IIViewDeckOffsetOrientation;

enum {
    IIViewDeckNoPanning,              // no panning allowed
    IIViewDeckFullViewPanning,        // the default: touch anywhere in the center view to drag the center view around
    IIViewDeckNavigationBarPanning,   // panning only occurs when you start touching in the navigation bar (when the center controller is a UINavigationController with a visible navigation bar). Otherwise it will behave as IIViewDeckNoPanning. 
    IIViewDeckPanningViewPanning      // panning only occurs when you start touching in a UIView set in panningView property
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

@interface IIViewDeckController : UIViewController {
@private    
    CGFloat _panOrigin;
    BOOL _viewAppeared, _shouldViewDidAppear;
    CGFloat _preRotationWidth, _preRotationCenterWidth, _offset;
    CGFloat _maxLedge, _leftLedge, _rightLedge;
}

typedef void (^IIViewDeckControllerBlock) (IIViewDeckController *controller);

@property (nonatomic, assign) id<IIViewDeckControllerDelegate> delegate;
@property (nonatomic, assign) IIViewDeckDelegateMode delegateMode;

@property (nonatomic, readonly, retain) NSArray* controllers;
@property (nonatomic, retain) UIViewController* centerController;
@property (nonatomic, retain) UIViewController* leftController;
@property (nonatomic, retain) UIViewController* rightController;
@property (nonatomic, readonly, assign) UIViewController* slidingController;

@property (nonatomic, retain) UIView* panningView;
@property (nonatomic, assign) id<UIGestureRecognizerDelegate> panningGestureDelegate;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isElastic) BOOL elastic;

@property (nonatomic) CGFloat leftSize;
@property (nonatomic) CGFloat rightSize;
@property (nonatomic) CGFloat maxSize;
@property (nonatomic) BOOL resizesCenterView;
@property (nonatomic) IIViewDeckPanningMode panningMode;
@property (nonatomic) IIViewDeckCenterHiddenInteractivity centerhiddenInteractivity;
@property (nonatomic) IIViewDeckNavigationControllerBehavior navigationControllerBehavior;
@property (nonatomic) BOOL automaticallyUpdateTabBarItems;
@property (nonatomic) IIViewDeckSizeMode sizeMode;

- (id)initWithCenterViewController:(UIViewController*)centerController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController;
- (id)initWithCenterViewController:(UIViewController*)centerController rightViewController:(UIViewController*)rightController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController;

- (void)showCenterView;
- (void)showCenterView:(BOOL)animated;
- (void)showCenterView:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;


- (void)setLeftSize:(CGFloat)leftSize completion:(void(^)(BOOL finished))completion;
- (void)setRightSize:(CGFloat)rightSize completion:(void(^)(BOOL finished))completion;
- (void)setMaxSize:(CGFloat)maxSize completion:(void(^)(BOOL finished))completion;

- (BOOL)toggleLeftView;
- (BOOL)openLeftView;
- (BOOL)closeLeftView;
- (BOOL)toggleLeftViewAnimated:(BOOL)animated;
- (BOOL)toggleLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewAnimated:(BOOL)animated;
- (BOOL)openLeftViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced;
- (BOOL)openLeftViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeLeftViewAnimated:(BOOL)animated;
- (BOOL)closeLeftViewAnimated:(BOOL)animated completion:(void(^)(IIViewDeckController* controller))completed;
- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBlock)bounced;
- (BOOL)closeLeftViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)toggleRightView;
- (BOOL)openRightView;
- (BOOL)closeRightView;
- (BOOL)toggleRightViewAnimated:(BOOL)animated;
- (BOOL)toggleRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewAnimated:(BOOL)animated;
- (BOOL)openRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced;
- (BOOL)openRightViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewAnimated:(BOOL)animated;
- (BOOL)closeRightViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;
- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBlock)bounced;
- (BOOL)closeRightViewBouncing:(IIViewDeckControllerBlock)bounced completion:(IIViewDeckControllerBlock)completed;

- (BOOL)toggleOpenView;
- (BOOL)toggleOpenViewAnimated:(BOOL)animated;
- (BOOL)toggleOpenViewAnimated:(BOOL)animated completion:(IIViewDeckControllerBlock)completed;

- (BOOL)canRightViewPushViewControllerOverCenterController;
- (void)rightViewPushViewControllerOverCenterController:(UIViewController*)controller;

- (BOOL)isSideClosed:(IIViewDeckSide)viewDeckSize;
- (BOOL)isSideOpen:(IIViewDeckSide)viewDeckSize;

- (CGFloat)statusBarHeight;

@end


// Delegate protocol

@protocol IIViewDeckControllerDelegate <NSObject>

@optional
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

@end


// category on UIViewController to provide access to the viewDeckController in the 
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (UIViewDeckItem) 

@property(nonatomic,readonly,retain) IIViewDeckController *viewDeckController; 

@end
