//
//  ItemFinder.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "ItemFinder.h"

#import "Item.h"


NS_ASSUME_NONNULL_BEGIN

@interface ItemFinder ()

@property (nonatomic) NSURLSession *session;

@end


@implementation ItemFinder

+ (instancetype)sharedInstance {
    static ItemFinder *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        _session = session;
    }
    return self;
}

- (NSURLRequest *)requestWithTerm:(NSString *)term {
    NSParameterAssert(term);

    NSLocale *locale = NSLocale.currentLocale;

    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"https://itunes.apple.com/search"];
    NSArray *queryItems = @[
                            [NSURLQueryItem queryItemWithName:@"term" value:term],
                            [NSURLQueryItem queryItemWithName:@"country" value:locale.countryCode],
                            [NSURLQueryItem queryItemWithName:@"media" value:@"tvShow"],
                            [NSURLQueryItem queryItemWithName:@"entity" value:@"tvSeason"],
                            [NSURLQueryItem queryItemWithName:@"attribute" value:@"showTerm"],
                            ];
    components.queryItems = queryItems;

    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    return request;
}

- (void)findItemsWithTerm:(NSString *)term completionHandler:(void(^)(NSArray<Item *> * _Nullable, NSError * _Nullable))completionHandler {
    NSParameterAssert(term);
    NSParameterAssert(completionHandler);

    NSURLRequest *request = [self requestWithTerm:term];
    NSURLSession *session = self.session;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSError *jsonError;
            NSDictionary<NSString *, id> *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonData) {
                NSMutableArray<Item *> *items = [NSMutableArray new];
                for (NSDictionary<NSString *, id> *jsonItem in jsonData[@"results"]) {
                    Item *item = [[Item alloc] initWithDict:jsonItem];
                    [items addObject:item];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(items.copy, nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, jsonError);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
        }
    }];
    [task resume];
}

- (void)fetchImageForItem:(Item *)item completionHandler:(void(^)(UIImage * _Nullable, NSError * _Nullable))completionHandler {
    NSParameterAssert(item);
    NSParameterAssert(completionHandler);

    NSURLSessionDataTask *task = [self.session dataTaskWithURL:item.imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [[UIImage alloc] initWithData:data];

            // decompress image
            UIGraphicsBeginImageContext(CGSizeMake(1.0, 1.0));
            [image drawAtPoint:CGPointZero];
            UIGraphicsEndImageContext();

            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(image, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
        }
    }];

    [task resume];
}

@end

NS_ASSUME_NONNULL_END
