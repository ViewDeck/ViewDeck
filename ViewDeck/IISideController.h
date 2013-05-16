//
//  IISideController.h
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

#import "IIWrapController.h"

@interface IISideController : IIWrapController

@property (nonatomic, assign) CGFloat constrainedSize;

+ (IISideController*)autoConstrainedSideControllerWithViewController:(UIViewController*)controller;
+ (IISideController*)sideControllerWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize;

- (id)initWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize;

- (void)shrinkSide;
- (void)shrinkSideAnimated:(BOOL)animated;

@end


// category on UIViewController to provide access to the sideController in the
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (IISideController)

@property(nonatomic,readonly,retain) IISideController *sideController;

@end
