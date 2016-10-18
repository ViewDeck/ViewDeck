//
//  TermTableViewController.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemDataSource;
@class SourceSelectionTableViewController;

@protocol SourceSelectionTableViewControllerDelegate <NSObject>

- (void)sourceSelectionTableViewController:(SourceSelectionTableViewController *)termTableViewController didSelectDataSpource:(id<ItemDataSource>)dataSource;

@end


@interface SourceSelectionTableViewController : UITableViewController

@property (nonatomic, weak) id<SourceSelectionTableViewControllerDelegate> delegate;

@end
