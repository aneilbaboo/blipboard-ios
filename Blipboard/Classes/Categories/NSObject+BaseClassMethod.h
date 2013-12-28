//
//  NSObject+BaseClassMethod.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/31/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BaseClassMethod)
/** returns the class hierarchy from the current class up to, but not including the ancestor
 */
+(NSArray *)classHierarchyToAncestor:(Class)ancestor;

/** returns the most base class that responds to the provided class method
 */
+(Class)baseClassForClassMethod:(SEL)selector;

/** returns the most base class that responds to the provided instance method
 */
+(Class)baseClassForInstanceMethod:(SEL)selector;
@end
