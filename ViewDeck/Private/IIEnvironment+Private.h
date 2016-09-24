//
//  IIEnvironment+Private.h
//  IIViewDeck
//
//  Copyright (C) 2016, ViewDeck
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "IIEnvironment.h"


/**
 Checks if the passed in side is describing a side view controller of an `IIViewDeckController`.

 @param side The side you want to check.

 @return `YES` if side is either of type `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
 */
static inline BOOL IIViewDeckSideIsValid(IIViewDeckSide side) {
    return (side == IIViewDeckSideLeft || side == IIViewDeckSideRight);
}


#define IILimitFraction(__value__) IILimit((double)0.0, (double)__value__, (double)1.0)


#ifdef __cplusplus

#import <algorithm>
#define IILimit(__min__, __value__, __max__) std::max(__min__, std::min(__value__, __max__))

#define let const auto

// Geometry overloading
// @see http://stackoverflow.com/questions/18037028/arithmetic-on-two-cgpoints-with-or-operators

// CGPoint

inline CGPoint operator+(const CGPoint &p1, const CGPoint &p2) {
    return { p1.x + p2.x, p1.y + p2.y };
}

inline CGPoint operator-(const CGPoint &p1, const CGPoint &p2) {
    return { p1.x - p2.x, p1.y - p2.y };
}

inline CGPoint operator*(const CGPoint &p, const CGFloat &f) {
    return { p.x * f, p.y * f };
}

inline CGPoint operator*(const CGFloat &f, const CGPoint &p) {
    return { p.x * f, p.y * f };
}

inline CGPoint operator/(const CGPoint &p, const CGFloat &f) {
    return { p.x / f, p.y / f };
}


// CGSize

inline CGSize operator+(const CGSize &s1, const CGSize &s2) {
    return { s1.width + s2.width, s1.height + s2.height };
}

inline CGSize operator-(const CGSize &s1, const CGSize &s2) {
    return { s1.width - s2.width, s1.height - s2.height };
}

inline CGSize operator*(const CGSize &s, const CGFloat &f) {
    return { s.width * f, s.height * f };
}

inline CGSize operator*(const CGFloat &f, const CGSize &s) {
    return { s.width * f, s.height * f };
}

inline CGSize operator/(const CGSize &s, const CGFloat &f) {
    return { s.width / f, s.height / f };
}


// CGRect - not that obvious - handle with care

inline CGRect operator+(const CGRect &r1, const CGRect &r2) {
    return { r1.origin + r2.origin, r1.size + r2.size };
}

inline CGRect operator-(const CGRect &r1, const CGRect &r2) {
    return { r1.origin - r2.origin, r1.size - r2.size };
}

inline CGRect operator*(const CGRect &r, const CGFloat &f) {
    return { r.origin * f, r.size * f };
}

inline CGRect operator*(const CGFloat &f, const CGRect &r) {
    return { r.origin * f, r.size * f };
}

inline CGRect operator/(const CGRect &r, const CGFloat &f) {
    return { r.origin / f, r.size / f };
}

#else

#define IILimit(__min__, __value__, __max__) MAX(__min__, MIN(__value__, __max__))

#endif
