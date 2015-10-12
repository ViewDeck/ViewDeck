//
//  WebController.m
//  FeaturesExample
//

#import "WebController.h"

@implementation WebController

@synthesize webView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/Inferis/ViewDeck"]]];
}

@end
