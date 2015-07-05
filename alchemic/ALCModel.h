//
//  ALCModel.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCBuilder.h"

/**
 Core object management.
 */
@interface ALCModel : NSObject

/**
 Adds a builder to the model.

 @param builder	the builder to be added.
 */
-(void) addBuilder:(id<ALCBuilder> __nonnull) builder;

/**
 Finds all builder which build objects of the passed class. 
 
 Note that any builder that builds the class or a decendant of the class will be returned.

 @param class	the class to search on.

 @return a NSSet of builders that return objects of the class.
 */
-(nonnull NSSet<id<ALCBuilder>> *) buildersWithClass:(Class __nonnull) class;

/**
 FInds all builders which build objects with a passed protocol.

 @param protocol the protocol to look for.

 @return a NSSet of builders that will builds objects with the protocol.
 */
-(nonnull NSSet<id<ALCBuilder>> *) buildersWithProtocol:(Protocol __nonnull *) protocol;

/**
 Finds all builders with a passed name.

 @param name the name to search for.

 @return a NSSet containing all the builders that use the name.
 */
-(nonnull NSSet<id<ALCBuilder>> *) buildersWithName:(NSString __nonnull *) name;

@end
