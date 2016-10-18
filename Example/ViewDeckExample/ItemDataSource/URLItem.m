//
//  URLItem.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 10/16/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "URLItem.h"


NS_ASSUME_NONNULL_BEGIN


@interface URLItem () {
    BOOL _resolving;
}

@property (nonatomic, nullable) NSString *title;
@property (nonatomic, nullable) UIImage *image;

@property (nonatomic, readonly) NSURL *url;

@end


@implementation URLItem

+ (NSURLSession *)session {
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    });
    return session;
}

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url {
    self = [super init];
    if (self) {
        _title = title;
        _url = url;
    }
    return self;
}

- (void)resolveFuture:(void(^)())completionHandler {
    NSParameterAssert(completionHandler);
    if (self.image || _resolving) {
        return;
    }

    _resolving = YES;

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSURL *url = self.url;
        if (url.isFileURL) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];
            UIImage *image = [[UIImage alloc] initWithData:data scale:UIScreen.mainScreen.scale];
            
            // unpack image
            UIGraphicsBeginImageContext(CGSizeMake(1.0, 1.0));
            [image drawInRect:CGRectMake(0.0, 0.0, 1.0, 1.0)];
            UIGraphicsEndImageContext();

            dispatch_async(dispatch_get_main_queue(), ^{
                _image = image;
                completionHandler();
            });
        } else {
            __weak typeof(self) weakSelf = self;
            NSURLSessionTask *task = [URLItem.session downloadTaskWithURL:self.url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                typeof(weakSelf) self = weakSelf;
                if (self == nil) { return; }

                NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];
                UIImage *image = [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = image;
                    completionHandler();
                });
            }];
            [task resume];
        }
    });
}

@end


NS_ASSUME_NONNULL_END
