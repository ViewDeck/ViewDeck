//
//  ViewController.h
//  ViewDeckExample
//


#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain) UIPopoverController* popoverController;
@end
