//
//  LocalDataSource.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 10/16/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "LocalDataSource.h"

#import "URLItem.h"


@interface LocalDataSource ()

@property (nonatomic, readonly) NSURL *baseURL;

@property (nonatomic) NSArray<URLItem *> *items;

@end


@implementation LocalDataSource

- (instancetype)initWithFolder:(NSURL *)url {
    self = [super init];
    if (self) {
        NSParameterAssert([url checkResourceIsReachableAndReturnError:NULL]);
        NSParameterAssert(url.isFileURL);

        _baseURL = url;
        _items = @[];
    }
    return self;
}

- (void)prepareData:(void (^)())completionHandler {
    NSMutableArray *items = [NSMutableArray new];
    NSDirectoryEnumerator<NSURL *> *enumerator = [NSFileManager.defaultManager enumeratorAtURL:self.baseURL includingPropertiesForKeys:nil options:0 errorHandler:NULL];
    for (NSURL *url in enumerator) {
        URLItem *item = [[URLItem alloc] initWithTitle:url.URLByDeletingPathExtension.lastPathComponent url:url];
        [items addObject:item];
    }
    self.items = items.copy;
}

- (NSUInteger)numberOfItems {
    return self.items.count;
}

- (id<Item>)itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

@end
