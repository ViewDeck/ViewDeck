//
//  NestViewController.h
//  ViewDeckExample
//

#import <UIKit/UIKit.h>

@interface NestViewController : UIViewController

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, retain) IBOutlet UILabel* levelLabel;

- (IBAction)pressedGoDeeper:(id)sender;
@end
