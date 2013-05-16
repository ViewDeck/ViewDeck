//
//  ViewController.m
//  TableViewsExample
//
//  Created by Tom Adriaenssen on 16/05/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "IIViewDeckController.h"

@interface ViewController () <UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;

@end

@implementation ViewController {
    NSArray* _methods;
    NSArray* _allMethods;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _searchable = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    uint count;
    Method* methodlist = class_copyMethodList([UITableView class], &count);
    
    NSMutableArray* methods = [NSMutableArray new];
    for (int i=0; i<count; ++i) {
        NSString* name = NSStringFromSelector(method_getName(methodlist[i]));
        if ([name rangeOfString:@"_"].location != 0)
            [methods addObject:name];
    }
    
    _allMethods = [methods sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    [self filter:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(doEdit)];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    
    self.view; // fdj
    self.searchBar.tintColor = tintColor;
}

- (void)setSearchable:(BOOL)searchable {
    _searchable = searchable;
    
    self.view;
    if (searchable) {
        self.tableView.tableHeaderView = self.searchBar;
    }
    else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UITableViewController*)self.viewDeckController.leftController).tableView.scrollsToTop = NO;
    UINavigationController* nc = self.viewDeckController.centerController;
    ((UITableViewController*)nc.topViewController).tableView.scrollsToTop = NO;
    ((UITableViewController*)self.viewDeckController.rightController).tableView.scrollsToTop = NO;
    self.tableView.scrollsToTop = YES;
}

- (void)filter:(NSString*)filter {
    if (filter) {
        _methods = [_allMethods filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self beginswith[cd] %@", filter]];
    }
    else {
        _methods = _allMethods;
    }
    
    [[self tableView] reloadData];
}

#pragma mark - search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filter:searchText];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _methods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = _methods[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.showsReorderControl = YES;

    return cell;
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate


- (void)doEdit {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doEdit)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(doEdit)];
}

@end
