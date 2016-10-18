//
//  ItemCollectionViewController.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SourceSelectionTableViewController.h"


NS_ASSUME_NONNULL_BEGIN


@protocol Item <NSObject>

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) UIImage *image;

- (void)resolveFuture:(void(^)())completionHandler;

@end


@protocol ItemDataSource <NSObject>

- (void)prepareData:(void(^)())completionHandler;

@property (nonatomic, readonly) NSUInteger numberOfItems;

- (id<Item>)itemAtIndex:(NSUInteger)index;

@end


@interface ItemCollectionViewController : UICollectionViewController

@property (nonatomic, nullable) id<ItemDataSource> dataSource;

@end


NS_ASSUME_NONNULL_END
