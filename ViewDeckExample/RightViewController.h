//
//  RightViewController.h
//  ViewDeckExample
//

#import <UIKit/UIKit.h>

@interface RightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIButton* pushButton;

- (IBAction)defaultCenterPressed:(id)sender;
- (IBAction)swapLeftAndCenterPressed:(id)sender;
- (IBAction)centerNavController:(id)sender;
- (IBAction)pushOverCenter:(id)sender;
- (IBAction)moveToLeft:(id)sender;

@end
