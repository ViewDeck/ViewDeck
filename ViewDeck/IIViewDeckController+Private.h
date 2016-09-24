//
//  IIViewDeckController+IIViewDeckController_Private.h
//  Pods
//
//  Created by Michael Ochs on 5/26/16.
//
//

#import "IIViewDeckController.h"

NS_ASSUME_NONNULL_BEGIN

@class IIViewDeckLayoutSupport;
@interface IIViewDeckController (Private)

@property (nonatomic, readonly) IIViewDeckLayoutSupport *layoutSupport;

- (void)openSide:(IIViewDeckSide)side animated:(BOOL)animated notify:(BOOL)notify completion:(nullable void(^)(BOOL cancelled))completion;
- (void)closeSide:(BOOL)animated notify:(BOOL)notify completion:(nullable void(^)(BOOL cancelled))completion;

@end

NS_ASSUME_NONNULL_END
