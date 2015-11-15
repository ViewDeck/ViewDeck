//
// IIDelegateProxy.m
//
// Copyright (c) 2013 Peter Steinberger (http://petersteinberger.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// CHANGE NOTICE: This class has been altered from the original version to match
// the ViewDeck styling and naming conventions. The originla PSTDelegateProxy
// can be found on GitHub at: https://github.com/steipete/PSTDelegateProxy

#import "IIDelegateProxy.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

@implementation IIDelegateProxy {
    CFDictionaryRef _signatures;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithDelegate:(id)delegate conformingToProtocol:(Protocol *)protocol defaultReturnValue:(NSValue *)returnValue {
    NSParameterAssert(protocol);
    NSParameterAssert(returnValue == nil || [returnValue isKindOfClass:NSValue.class]);
    if (self) {
        _delegate = delegate;
        _protocol = protocol;
        _defaultReturnValue = returnValue;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p delegate:%@ protocol:%@>", self.class, self, self.delegate, self.protocol];
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [_delegate respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    id delegate = _delegate;
    return [delegate respondsToSelector:selector] ? delegate : self;
}

// Regular message forwarding continues if delegate doesn't respond to selector or is nil.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [_delegate methodSignatureForSelector:selector];
    if (!signature) {
        if (!_signatures) _signatures = [self methodSignaturesForProtocol:_protocol];
        signature = CFDictionaryGetValue(_signatures, selector);
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // Set a default return type if set.
    if (_defaultReturnValue && (strcmp(_defaultReturnValue.objCType, invocation.methodSignature.methodReturnType) == 0 || ([_defaultReturnValue isKindOfClass:NSValue.class] && strcmp(_defaultReturnValue.objCType, "c") == 0 && strcmp(invocation.methodSignature.methodReturnType, "B") == 0))) { // 64bit bool is 'B', but `NSValue` still returns 'c'
        char buffer[invocation.methodSignature.methodReturnLength];
        [_defaultReturnValue getValue:buffer];
        [invocation setReturnValue:&buffer];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (instancetype)copyThatDefaultsTo:(NSValue *)defaultValue {
    return [[self.class alloc] initWithDelegate:_delegate conformingToProtocol:_protocol defaultReturnValue:defaultValue];
}

- (instancetype)copyThatDefaultsToYES {
    return [self copyThatDefaultsTo:@YES];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

static CFMutableDictionaryRef _protocolCache = nil;
static OSSpinLock _lock = OS_SPINLOCK_INIT;

- (CFDictionaryRef)methodSignaturesForProtocol:(Protocol *)protocol {
    OSSpinLockLock(&_lock);
    // Cache lookup
    if (!_protocolCache) _protocolCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryRef signatureCache = CFDictionaryGetValue(_protocolCache, (__bridge const void *)(protocol));

    if (!signatureCache) {
        // Add protocol methods + derived protocol method definitions into protocolCache.
        signatureCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        [self methodSignaturesForProtocol:protocol inDictionary:(CFMutableDictionaryRef)signatureCache];
        CFDictionarySetValue(_protocolCache, (__bridge const void *)(protocol), signatureCache);
        CFRelease(signatureCache);
    }
    OSSpinLockUnlock(&_lock);
    return signatureCache;
}

- (void)methodSignaturesForProtocol:(Protocol *)protocol inDictionary:(CFMutableDictionaryRef)cache {
    void (^enumerateRequiredMethods)(BOOL) = ^(BOOL isRequired) {
        unsigned int methodCount;
        struct objc_method_description *descr = protocol_copyMethodDescriptionList(protocol, isRequired, YES, &methodCount);
        for (NSUInteger idx = 0; idx < methodCount; idx++) {
            NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descr[idx].types];
            CFDictionarySetValue(cache, descr[idx].name, (__bridge const void *)(signature));
        }
        free(descr);
    };
    // We need to enumerate both required and optional protocol methods.
    enumerateRequiredMethods(NO); enumerateRequiredMethods(YES);

    // There might be sub-protocols we need to catch as well.
    unsigned int inheritedProtocolCount;
    Protocol *__unsafe_unretained* inheritedProtocols = protocol_copyProtocolList(protocol, &inheritedProtocolCount);
    for (NSUInteger idx = 0; idx < inheritedProtocolCount; idx++) {
        [self methodSignaturesForProtocol:inheritedProtocols[idx] inDictionary:cache];
    }
    free(inheritedProtocols);
}
@end
