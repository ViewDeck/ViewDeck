//
//  IIViewDeckController+IIViewDeckController_Private.h
//  Pods
//
//  Created by Michael Ochs on 5/26/16.
//
//

#import "IIViewDeckController.h"

@class IIViewDeckLayoutSupport;
@interface IIViewDeckController (Private)

@property (nonatomic, readonly) IIViewDeckLayoutSupport *layoutSupport;

- (void)openSide:(IIViewDeckSide)side animated:(BOOL)animated notify:(BOOL)notify completion:(nullable void(^)(void))completion;
- (void)closeSide:(BOOL)animated notify:(BOOL)notify completion:(nullable void(^)(void))completion;

@end
