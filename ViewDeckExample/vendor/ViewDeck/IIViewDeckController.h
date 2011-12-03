//
//  IIViewDeckController.h
//  ViewDeckExample
//
//  Created by Tom Adriaenssen on 03/12/11.
//  Copyright (c) 2011 Adriaenssen BVBA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IIViewDeckController : UIViewController

- (id)initWithCenterViewController:(UIViewController*)centerController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController;
- (id)initWithCenterViewController:(UIViewController*)centerController leftViewController:(UIViewController*)leftController rightViewController:(UIViewController*)rightController;

- (void)toggleLeftView;
- (void)openLeftView;
- (void)closeLeftView;
- (void)toggleLeftViewAnimated:(BOOL)animated;
- (void)openLeftViewAnimated:(BOOL)animated;
- (void)closeLeftViewAnimated:(BOOL)animated;

- (void)toggleRightView;
- (void)openRightView;
- (void)closeRightView;
- (void)toggleRightViewAnimated:(BOOL)animated;
- (void)openRightViewAnimated:(BOOL)animated;
- (void)closeRightViewAnimated:(BOOL)animated;

@end

@interface UIViewController (Stuff) 

@property(nonatomic,readonly,retain) IIViewDeckController *viewDeckController; // If this view controller has been pushed onto a navigation controller, return it.

@end
