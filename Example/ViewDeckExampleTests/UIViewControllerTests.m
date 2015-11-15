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

#import <XCTest/XCTest.h>

#import <ViewDeck/ViewDeck.h>


@interface ViewDeckExampleTests : XCTestCase

@end


@implementation ViewDeckExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testViewDeckControllerReturnsSelf {
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:[UIViewController new]];
    XCTAssertEqual(viewDeckController.viewDeckController, viewDeckController, @"Asking a IIViewDeckController for its viewDeckController should return self");
}

- (void)testViewControllerReturnsNilByDefault {
    UIViewController *controller = [UIViewController new];
    XCTAssertNil(controller.viewDeckController, @"A view controller without a hierarchy should return nil for its viewDeckController");
}

- (void)testViewControllerReturnsViewDeckController {
    UIViewController *centerController = [UIViewController new];
    UIViewController *leftController = [UIViewController new];
    UIViewController *rightController = [UIViewController new];
    
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:leftController rightViewController:rightController];
    
    XCTAssertEqual(centerController.viewDeckController, viewDeckController, @"A view controller should return its viewDeckController as soon as it has been added to it");
    XCTAssertEqual(leftController.viewDeckController, viewDeckController, @"A view controller should return its viewDeckController as soon as it has been added to it");
    XCTAssertEqual(rightController.viewDeckController, viewDeckController, @"A view controller should return its viewDeckController as soon as it has been added to it");
}

@end
