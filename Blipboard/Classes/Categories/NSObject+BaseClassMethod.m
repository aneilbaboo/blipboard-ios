//
//  NSObject+BaseClassMethod.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/31/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "NSObject+BaseClassMethod.h"

@implementation NSObject (BaseClassMethod)

+(NSArray *)classHierarchyToAncestor:(Class)ancestor {
    return [self internalClassHierarchyToAncestor:ancestor array:[NSMutableArray arrayWithCapacity:2]];
}

+(NSArray *)internalClassHierarchyToAncestor:(Class)ancestor array:(NSMutableArray *)array {
    if (self == ancestor) {
        return array;
    }
    else {
        [array addObject:self];
        return [[self superclass] internalClassHierarchyToAncestor:ancestor array:array];
    }
}

+(Class)baseClassForClassMethod:(SEL)selector {
    if (![self respondsToSelector:selector]) {
        return nil;
    }
    else {
        Class baseClass = [[self superclass] baseClassForClassMethod:selector];
        if (baseClass) {
            return baseClass;
        }
        else {
            return self;
        }
    }
}

+(Class)baseClassForInstanceMethod:(SEL)selector {
    if (![self instancesRespondToSelector:selector]) {
        return nil;
    }
    else {
        Class baseClass = [[self superclass] baseClassForInstanceMethod:selector];
        if (baseClass) {
            return baseClass;
        }
        else {
            return self;
        }
    }
}

@end
