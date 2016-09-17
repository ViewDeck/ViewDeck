//
//  TermTableViewController.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "TermTableViewController.h"

@interface TermTableViewController ()

@property (nonatomic, copy) NSArray<NSString *> *terms;

@end

@implementation TermTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _terms = @[
                   @"Game of Thrones",
                   @"Friends",
                   @"The Big Bang Theory",
                   @"Silicon Valley",
                   ];
        self.title = @"TV Shows";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.terms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.terms[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate termTableViewController:self didPickTerm:self.terms[indexPath.row]];
}

@end
