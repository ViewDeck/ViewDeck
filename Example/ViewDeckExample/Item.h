//
//  Item.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSURL *imageURL;

- (instancetype)initWithDict:(NSDictionary<NSString *, id> *)dict NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
