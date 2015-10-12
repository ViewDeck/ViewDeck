//
//  FirstViewController.m
//  TabbedExample
//
//  Created by Tom Adriaenssen on 03/02/12.
//  Copyright (c) 2012 Adriaenssen BVBA. All rights reserved.
//

#import "FirstViewController.h"
#import "FourthViewController.h"
#import "ThirdViewController.h"

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First2", @"First");

        NSLog(@"first init");
        self.tabBarItem.title = NSLocalizedString(@"FirstLike", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first.png"];
    }
    return self;
}
							
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Firstx";

    NSLog(@"first VDL");
    self.tabBarItem.title = NSLocalizedString(@"FirstLike", @"First");
    self.tabBarItem.image = [UIImage imageNamed:@"first.png"];
    
}

- (IBAction)pushed:(id)sender {
    NSLog(@"first pushed");
    NSArray* controllers = [self.tabBarController viewControllers];
    controllers = [controllers arrayByAddingObject:[[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil]];
    [self.tabBarController setViewControllers:controllers animated:YES];

    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:[[FourthViewController alloc] initWithNibName:@"FourthViewController" bundle:nil] animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}


@end
