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

typedef enum {
    IIViewDeckNoPanning,
    IIViewDeckFullViewPanning,
    IIViewDeckNavigationBarPanning,
} IIViewDeckPanningMode;

@interface IIViewDeckController : UIViewController

@property (nonatomic, retain) id<IIViewDeckControllerDelegate> delegate;
@property (nonatomic, retain) UIViewController* centerController;
@property (nonatomic, retain) UIViewController* leftController;
@property (nonatomic, retain) UIViewController* rightController;
@property (nonatomic, readonly, retain) UIViewController* slidingController;

@property (nonatomic) CGFloat leftLedge;
@property (nonatomic) CGFloat rightLedge;
@property (nonatomic) CGFloat leftGap;
@property (nonatomic) CGFloat rightGap;
@property (nonatomic) BOOL resizesCenterView;
@property (nonatomic) IIViewDeckPanningMode panningMode;

- (id)initWithCenterViewController:(UIViewController*)centerController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController;
- (id)initWithCenterViewController:(UIViewController*)centerController rightViewController:(UIViewController*)rightController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController;

- (void)showCenterView;
- (void)showCenterView:(BOOL)animated;

- (void)toggleLeftView;
- (void)openLeftView;
- (void)closeLeftView;
- (void)toggleLeftViewAnimated:(BOOL)animated;
- (void)openLeftViewAnimated:(BOOL)animated;
- (void)closeLeftViewAnimated:(BOOL)animated;
- (void)closeLeftViewBouncing:(void(^)(IIViewDeckController* controller))bounced;

- (void)toggleRightView;
- (void)openRightView;
- (void)closeRightView;
- (void)toggleRightViewAnimated:(BOOL)animated;
- (void)openRightViewAnimated:(BOOL)animated;
- (void)closeRightViewAnimated:(BOOL)animated;
- (void)closeRightViewBouncing:(void(^)(IIViewDeckController* controller))bounced;

@end


// Delegate protocol

@protocol IIViewDeckControllerDelegate <NSObject>

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willShowCenterView:

@end


// category on UIViewController to provide access to the viewDeckController in the 
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (UIViewDeckItem) 

@property(nonatomic,readonly,retain) IIViewDeckController *viewDeckController; 

@end
