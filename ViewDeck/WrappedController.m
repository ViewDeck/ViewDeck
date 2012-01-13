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


#import "WrappedController.h"

@implementation WrappedController

@synthesize wrappedController = _wrappedController;

#pragma mark - View lifecycle

- (id)initWithViewController:(UIViewController *)controller {
    if ((self = [super init])) {
        _wrappedController = controller;
    }
          
    return self;
}
          
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:self.wrappedController.view.frame];
    self.view.autoresizingMask = self.wrappedController.view.autoresizingMask;
    [self.wrappedController.view removeFromSuperview];
    self.wrappedController.view.frame = self.view.bounds;
    self.wrappedController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.wrappedController.view];
    
    [self.view setNeedsLayout];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.wrappedController.view removeFromSuperview];
}

- (void)dealloc {
    _wrappedController = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.wrappedController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    [self.wrappedController didReceiveMemoryWarning];
}

@end
