//
//  ALCObjectStandIn.h
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependencyInfo;

/**
 This proxy will be used when doing initial injections. When the parent object sends it's first message to the proxy, it will transform itself into the desired object.
 */
@interface ALCLazyDependency : NSProxy

-(instancetype) initWithDependencyInfo:(ALCDependencyInfo *) dependencyInfo;

@end
