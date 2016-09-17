//
//  ItemFinder.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Item;
@interface ItemFinder : NSObject

+ (instancetype)sharedInstance;

- (void)findItemsWithTerm:(NSString *)term completionHandler:(void(^)(NSArray<Item *> * _Nullable, NSError  * _Nullable))completionHandler;
- (void)fetchImageForItem:(Item *)item completionHandler:(void(^)(UIImage * _Nullable, NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
