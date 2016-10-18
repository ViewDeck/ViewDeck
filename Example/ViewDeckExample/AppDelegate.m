//
//  AppDelegate.m
//  ViewDeckExample
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


#import "AppDelegate.h"

#import <ViewDeck/ViewDeck.h>
#import "ItemCollectionViewController.h"
#import "SourceSelectionTableViewController.h"

#import "LocalDataSource.h"

@interface AppDelegate () <SourceSelectionTableViewControllerDelegate>

@property (nonatomic) IIViewDeckController *viewDeckController;
@property (nonatomic) ItemCollectionViewController *itemController;

@end


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor colorWithRed:0.071 green:0.42 blue:0.694 alpha:1.0];

    LocalDataSource *dataSource = [[LocalDataSource alloc] initWithFolder:[NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Photos"]];

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    ItemCollectionViewController *itemController = [[ItemCollectionViewController alloc] initWithCollectionViewLayout:layout];
    itemController.dataSource = dataSource;
    self.itemController = itemController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:itemController];

    SourceSelectionTableViewController *sourceSelectionTableViewController = [[SourceSelectionTableViewController alloc] init];
    sourceSelectionTableViewController.delegate = self;
    UINavigationController *sideNavigationController = [[UINavigationController alloc] initWithRootViewController:sourceSelectionTableViewController];

    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:navigationController leftViewController:sideNavigationController];

    self.viewDeckController = viewDeckController;
    
    self.window.rootViewController = viewDeckController;
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark <TermTableViewControllerDelegate>

- (void)sourceSelectionTableViewController:(SourceSelectionTableViewController *)termTableViewController didSelectDataSpource:(id<ItemDataSource>)dataSource {
    self.itemController.dataSource = dataSource;
    [self.viewDeckController closeSide:YES];
}

@end
