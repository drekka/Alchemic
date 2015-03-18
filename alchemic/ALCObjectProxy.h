//
//  ALCObjectStandIn.h
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;
@class ALCClassInfo;

/**
 During registration, instances of this proxy are placed in the storate area so that dependencies can be resolved.
 */
@interface ALCObjectProxy : NSProxy

/**
 The info on the class being proxied.
 */
@property (nonatomic, strong, readonly) ALCClassInfo *classInfo;

/**
 The object being proxied. Will be nil until instantiated.
 */
@property (nonatomic, strong) id proxiedObject;

/**
 Default initialiser.
 
 @param classInfo Information on the class being proxied.
 @param context the context that created the proxy.
 
 @return an instance of this proxy.
 */
-(instancetype) initWithFutureObjectInfo:(ALCClassInfo *) classInfo context:(__weak ALCContext *) context;

/**
 Tells the proxy to instantiate the referenced object if it is not already created.
 */
-(void) instantiate;

@end
