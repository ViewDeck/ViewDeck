//
//  IIViewDeckTransitionCoordinator.h
//  Pods
//
//  Created by Michael Ochs on 7/9/16.
//
//

#import <Foundation/Foundation.h>

#import "IIEnvironment.h"


NS_ASSUME_NONNULL_BEGIN

@class IIViewDeckController;
@interface IIViewDeckLayoutSupport : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithViewDeckController:(IIViewDeckController *)viewDeckController NS_DESIGNATED_INITIALIZER;

- (CGRect)frameForSide:(IIViewDeckSide)side openSide:(IIViewDeckSide)openSide;

@end

NS_ASSUME_NONNULL_END
