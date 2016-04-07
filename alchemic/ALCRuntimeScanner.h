//
//  ALCRuntimeScanner.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

/**
 Used to scan the runtime looking for Alchemic methods.

 @discussion These methods are then called to perform the various registration that build Alchemic's model of objects.
 */
@interface ALCRuntimeScanner : NSObject

+(nullable NSSet<NSBundle *> *) scanBundles:(NSSet<NSBundle *> *) bundles context:(id<ALCContext>) context;

-(nullable NSSet<NSBundle *> *) scanClass:(Class) aClass;

@end

NS_ASSUME_NONNULL_END
