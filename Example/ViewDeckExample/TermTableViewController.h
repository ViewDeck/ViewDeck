//
//  TermTableViewController.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TermTableViewController;
@protocol TermsTableViewControllerDelegate <NSObject>

- (void)termTableViewController:(TermTableViewController *)termTableViewController didPickTerm:(NSString *)term;

@end


@interface TermTableViewController : UITableViewController

@property (nonatomic, weak) id<TermsTableViewControllerDelegate> delegate;

@end
