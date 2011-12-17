//
//  IIViewDeckController.h
//  ViewDeckExample
//
//  Created by Tom Adriaenssen on 03/12/11.
//  Copyright (c) 2011 Adriaenssen BVBA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    IIViewDeckNoPanning,
    IIViewDeckFullViewPanning,
    IIViewDeckNavigationBarPanning,
} IIViewDeckPanningMode;

@interface IIViewDeckController : UIViewController

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

@interface UIViewController (UIViewDeckItem) 

@property(nonatomic,readonly,retain) IIViewDeckController *viewDeckController; // If this view controller has been pushed onto a navigation controller, return it.

@end
