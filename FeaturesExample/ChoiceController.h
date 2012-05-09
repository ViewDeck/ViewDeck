//
//  ChoiceController.h
//  FeaturesExample
//

#import <UIKit/UIKit.h>

@interface ChoiceController : UIViewController

@property (nonatomic, retain) UIView* panningView;

- (IBAction)pressedNavigate:(id)sender;
- (IBAction)panningChanged:(id)sender;
- (IBAction)centerHiddenChanged:(id)sender;
- (IBAction)navigationChanged:(id)sender;
- (IBAction)rotationChanged:(id)sender;
- (IBAction)elasticChanged:(id)sender;
- (IBAction)maxLedgeChanged:(id)sender;

@end
