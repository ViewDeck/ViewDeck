//
//  WrappedController.m
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

#define II_CGRectOffsetRightAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y, __r.size.width-__o, __r.size.height }; })
#define II_CGRectOffsetTopAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) {{ __r.origin.x, __r.origin.y + __o}, {__r.size.width, __r.size.height-__o }}; })
#define II_CGRectOffsetBottomAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y, __r.size.width, __r.size.height-__o }; })
#define II_CGRectShrink(rect, w, h) ({__typeof__(rect) __r = (rect); __typeof__(w) __w = (w); __typeof__(h) __h = (h); (CGRect) { __r.origin, __r.size.width - __w, __r.size.height - __h }; })

#import "WrapController.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface UIViewController (WrappedItem_Internal) 

// internal setter for the wrapController property on UIViewController
- (void)setWrapController:(WrapController *)wrapController;

@end

@implementation WrapController

@synthesize wrappedController = _wrappedController;
@synthesize onViewDidLoad = _onViewDidLoad;
@synthesize onViewWillAppear = _onViewWillAppear;
@synthesize onViewDidAppear = _onViewDidAppear;
@synthesize onViewWillDisappear = _onViewWillDisappear;
@synthesize onViewDidDisappear = _onViewDidDisappear;

#pragma mark - View lifecycle

- (id)initWithViewController:(UIViewController *)controller {
    if ((self = [super init])) {
        II_RETAIN(controller);
        _wrappedController = controller;
        [controller setWrapController:self];
    }
          
    return self;
}

- (CGFloat)statusBarHeight {
//    if (![[self.referenceView superview] isKindOfClass:[UIWindow class]]) 
//        return 0;
//    
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) 
    ? [UIApplication sharedApplication].statusBarFrame.size.width 
    : [UIApplication sharedApplication].statusBarFrame.size.height;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
#if __IPHONE_5_0
    if ([self respondsToSelector:@selector(addChildViewController:)])
        [self addChildViewController:self.wrappedController];
#endif
    
    self.view = II_AUTORELEASE([[UIView alloc] initWithFrame:II_CGRectOffsetTopAndShrink(self.wrappedController.view.frame, [self statusBarHeight])]);
    self.view.autoresizingMask = self.wrappedController.view.autoresizingMask;
    self.wrappedController.view.frame = self.view.bounds;
    self.wrappedController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.wrappedController.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.onViewDidLoad) 
        self.onViewDidLoad(self);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.wrappedController.view removeFromSuperview];
}

- (void)dealloc {
#if __IPHONE_5_0
    if ([_wrappedController respondsToSelector:@selector(removeFromParentViewController)]) {
        [_wrappedController removeFromParentViewController];
    }
#endif
    [_wrappedController setWrapController:nil];
    II_RELEASE(_wrappedController);
    _wrappedController = nil;
#if !II_ARC_ENABLED
    [super dealloc];
#endif
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}

- (UITabBarItem *)tabBarItem {
    return _wrappedController.tabBarItem;
}

-(void)setTabBarItem:(UITabBarItem *)tabBarItem {
    [_wrappedController setTabBarItem:tabBarItem];
}

- (BOOL)hidesBottomBarWhenPushed {
    return _wrappedController.hidesBottomBarWhenPushed;
}

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed {
    [_wrappedController setHidesBottomBarWhenPushed:hidesBottomBarWhenPushed];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.onViewWillAppear) 
        self.onViewWillAppear(self, animated);

    [self.wrappedController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.onViewDidAppear) 
        self.onViewDidAppear(self, animated);

    [self.wrappedController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.onViewWillDisappear) 
        self.onViewWillDisappear(self, animated);

    [self.wrappedController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.onViewDidDisappear) 
        self.onViewDidDisappear(self, animated);

    [self.wrappedController viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.wrappedController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.wrappedController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.wrappedController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
    [self.wrappedController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.wrappedController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.wrappedController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    [self.wrappedController didReceiveMemoryWarning];
}

@end

@implementation UIViewController (WrapControllerItem) 

@dynamic wrapController;

static const char* wrapControllerKey = "WrapController";

- (WrapController*)wrapController_core {
    return objc_getAssociatedObject(self, wrapControllerKey);
}

- (WrapController*)wrapController {
    id result = [self wrapController_core];
    if (!result && self.navigationController) 
        return [self.navigationController wrapController];
    
    return result;
}

- (void)setWrapController:(WrapController *)wrapController {
    objc_setAssociatedObject(self, wrapControllerKey, wrapController, OBJC_ASSOCIATION_ASSIGN);
}

- (UINavigationController*)wc_navigationController {
    UIViewController* controller = self.wrapController_core ? self.wrapController_core : self;
    return [controller wc_navigationController]; // when we get here, the wc_ method is actually the old, real method
}

- (UINavigationItem*)wc_navigationItem {
    UIViewController* controller = self.wrapController_core ? self.wrapController_core : self;
    return [controller wc_navigationItem]; // when we get here, the wc_ method is actually the old, real method
}

+ (void)wc_swizzle {
    SEL nc = @selector(navigationController);
    SEL wcnc = @selector(wc_navigationController);
    method_exchangeImplementations(class_getInstanceMethod(self, nc), class_getInstanceMethod(self, wcnc));
    
    SEL ni = @selector(navigationItem);
    SEL wcni = @selector(wc_navigationItem);
    method_exchangeImplementations(class_getInstanceMethod(self, ni), class_getInstanceMethod(self, wcni));
}

+ (void)load {
    [super load];
    [self wc_swizzle];
}

@end