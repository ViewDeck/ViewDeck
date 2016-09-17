//
//  Item.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Item

- (instancetype)init {
    return [self initWithDict:@{}];
}

- (instancetype)initWithDict:(NSDictionary<NSString *, id> *)dict {
    self = [super init];
    if (self) {
        _title = dict[@"collectionName"];
        _imageURL = [NSURL URLWithString:dict[@"artworkUrl100"]];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
