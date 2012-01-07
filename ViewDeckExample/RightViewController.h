//
//  RightViewController.h
//  ViewDeckExample
//

#import <UIKit/UIKit.h>

@interface RightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)defaultCenterPressed:(id)sender;
- (IBAction)swapLeftAndCenterPressed:(id)sender;
- (IBAction)centerNavController:(id)sender;

@end
