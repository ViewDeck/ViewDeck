//
//  AppDelegate.h
//  ViewDeckExample
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *centerController;
@property (strong, nonatomic) UIViewController *leftController;
@property (strong, nonatomic) UIViewController *imageController;

@end
