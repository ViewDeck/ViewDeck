//
//  AppDelegate.h
//  ViewDeckExample
//

#import <UIKit/UIKit.h>

@class ViewController;
@class IIViewDeckController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) UIViewController *centerController;
@property (retain, nonatomic) UIViewController *leftController;

- (IIViewDeckController*)generateControllerStack;

@end
