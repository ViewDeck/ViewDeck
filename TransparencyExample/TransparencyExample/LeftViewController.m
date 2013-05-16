//
//  LeftViewController.m
//  TransparencyExample
//
//  Created by Tom Adriaenssen on 25/04/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "LeftViewController.h"
#import "UITableViewCell+AutoDequeue.h"
#import "IIViewDeckController.h"

@interface LeftViewController () <IIViewDeckControllerDelegate>

- (IIViewDeckController*)topViewDeckController;

@end

@implementation LeftViewController

- (IIViewDeckController*)topViewDeckController {
    return self.viewDeckController.viewDeckController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell tableViewAutoDequeueCell:tableView];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", arc4random() % 1000 + (1000 * (arc4random() % 1000))];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
