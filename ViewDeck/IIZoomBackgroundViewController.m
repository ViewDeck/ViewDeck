//
//  IIZoomBackgroundController.m
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

#import "IIZoomBackgroundViewController.h"

@interface IIZoomBackgroundViewController ()

@end

@implementation IIZoomBackgroundViewController
@synthesize zoomBackgroundColor, zoomBackgroundImage, zoomBackgroundView;

- (id)initWithViewController:(UIViewController*)controller {
    if ((self = [super initWithViewController:controller])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self resetViews];
	if (zoomBackgroundView) {
		[zoomBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
		[self.view addSubview:zoomBackgroundView];
		[self.view sendSubviewToBack:zoomBackgroundView];
	} else if (zoomBackgroundImage) {
		[zoomBackgroundImageView setImage:zoomBackgroundImage];
		[zoomBackgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
		[self.view addSubview:zoomBackgroundImageView];
		[self.view sendSubviewToBack:zoomBackgroundImageView];
	} else if (zoomBackgroundColor) {
		[self.view setBackgroundColor:zoomBackgroundColor];
	} else {
		zoomBackgroundView = [[REBackgroundView alloc] initWithFrame:self.view.bounds];
		[zoomBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
		[self.view addSubview:zoomBackgroundView];
		[self.view sendSubviewToBack:zoomBackgroundView];
		
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)setZoomBackgroundColor:(UIColor *)_zoomBackgroundColor{
	zoomBackgroundColor = _zoomBackgroundColor;
	[self resetViews];
	
}

- (void)setZoomBackgroundImage:(UIImage *)_zoomBackgroundImage{
	zoomBackgroundImage = _zoomBackgroundImage;
	[self resetViews];
	[zoomBackgroundImageView setImage:zoomBackgroundImage];
	[zoomBackgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:zoomBackgroundImageView];
	
}

- (void)setZoomBackgroundView:(UIView *)_zoomBackgroundView{
	zoomBackgroundView = _zoomBackgroundView;
	[self resetViews];
	[zoomBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:zoomBackgroundView];
	[self.view sendSubviewToBack:zoomBackgroundView];
}

- (void)resetViews{
	[zoomBackgroundView removeFromSuperview];
	[zoomBackgroundImageView removeFromSuperview];
	[self.view setBackgroundColor:[UIColor clearColor]];
}

@end



@implementation REBackgroundView

- (void)drawRect:(CGRect)rect{
	[self drawGradientInRect:rect];
}

- (void)drawGradientInRect:(CGRect)rect{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.294 green: 0.2 blue: 0.353 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0.294 green: 0.2 blue: 0.353 alpha: 1];
    UIColor* gradientColor = [UIColor colorWithRed: 0.514 green: 0.333 blue: 0.4 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0.667 green: 0.533 blue: 0.467 alpha: 1];
    UIColor* gradientColor3 = [UIColor colorWithRed: 0.667 green: 0.467 blue: 0.467 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)strokeColor.CGColor,
                               (id)[UIColor colorWithRed: 0.404 green: 0.267 blue: 0.376 alpha: 1].CGColor,
                               (id)gradientColor.CGColor,
                               (id)gradientColor2.CGColor,
                               (id)gradientColor3.CGColor,
                               (id)fillColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 0.16, 0.29, 0.58, 0.8, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, rect.size.width, rect.size.height)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.size.width / 2.0, 0), CGPointMake(rect.size.width / 2.0, rect.size.height), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end


@implementation UIViewController (IIZoomController)

- (IIZoomBackgroundViewController*)sideController {
    return (IIZoomBackgroundViewController*)self.wrapController;
}

@end
