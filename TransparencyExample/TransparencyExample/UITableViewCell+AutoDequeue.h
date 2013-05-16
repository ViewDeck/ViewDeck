
//
//  UITableViewCell+AutoDequeue.h
//  Faering
//
//  Created by Tom Adriaenssen on 12/02/12.
//  Copyright (c) 2012 Interface Implementation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (AutoDequeue)

+ (id)tableViewAutoDequeueCell:(UITableView*)tableView;
+ (void)tableViewRegisterAutoDequeueFromNib:(UITableView*)tableView;
   
@end
