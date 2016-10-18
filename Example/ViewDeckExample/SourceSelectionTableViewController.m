//
//  TermTableViewController.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "SourceSelectionTableViewController.h"

#import "LocalDataSource.h"
#import "APODDataSource.h"


@interface Source : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, copy, readonly) id<ItemDataSource>(^dataSourceCreator)(void);

- (instancetype)initWithTitle:(NSString *)title dataSourceCreator:(id<ItemDataSource>(^)(void))creator;

@end


@interface SourceSelectionTableViewController ()

@property (nonatomic, readonly) NSArray<Source *> *sources;

@end


@implementation SourceSelectionTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Sources";
        self.preferredContentSize = CGSizeMake(260.0, 480.0);

        _sources = @[
                     [[Source alloc] initWithTitle:@"Local" dataSourceCreator:^id<ItemDataSource>{ return [[LocalDataSource alloc] initWithFolder:[NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Photos"]]; }],
                     [[Source alloc] initWithTitle:@"APOD" dataSourceCreator:^id<ItemDataSource>{ return [APODDataSource new]; }],
                     ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];

    UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.tableView.backgroundView = backgroundView;
    self.tableView.backgroundColor = UIColor.clearColor;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blur];
    cell.backgroundView = backgroundView;
    cell.backgroundColor = UIColor.clearColor;

    cell.textLabel.text = self.sources[indexPath.row].title;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<ItemDataSource> dataSource = self.sources[indexPath.row].dataSourceCreator();
    [self.delegate sourceSelectionTableViewController:self didSelectDataSpource:dataSource];
}

@end


@implementation Source

- (instancetype)initWithTitle:(NSString *)title dataSourceCreator:(id<ItemDataSource>(^)(void))creator {
    self = [super init];
    if (self) {
        _title = title;
        _dataSourceCreator = [creator copy];
    }
    return self;
}

@end
