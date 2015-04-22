//
//  ALCDependencyInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependency;

@protocol ALCDependencyInjector <NSObject>

-(BOOL) injectObject:(id) object dependency:(ALCDependency *) dependency;

@end
