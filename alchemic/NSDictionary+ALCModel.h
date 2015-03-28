//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface NSDictionary (ALCModel)

-(NSDictionary *) objectDescriptionsForClass:(Class) aClass
                                   protocols:(NSArray *) protocols
                                   qualifier:(NSString *) qualifier
                              usingResolvers:(NSArray *) resolvers;

-(NSDictionary *) objectDescriptionsForClass:(Class) class;

-(NSDictionary *) objectDescriptionsWithProtocol:(Protocol *) protocol;

@end
