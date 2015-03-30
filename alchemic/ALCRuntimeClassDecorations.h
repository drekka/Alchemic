//
//  ALCRuntimeClassDecorations.h
//  alchemic
//
//  Created by Derek Clarkson on 29/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCRuntimeClassDecorations : NSObject

+(BOOL) classIsDecorated:(Class) class;

/**
 Adds functions to a Class so that Alchemic can give it instructions.
 
 @param class the class to manipulate.
 */
+(void) decorateClass:(Class) class;

#pragma mark - Methods being added

+(void) addInjectionToClass:(Class) class injection:(NSString *) inj qualifier:(NSString *) qualifier;

+(void) resolveDependenciesInClass:(Class) class withModel:(NSDictionary *) model dependencyResolvers:(NSArray *) dependencyResolvers;

+(void) injectDependenciesInto:(id) object usingDependencyInjectors:(NSArray *) dependencyInjectors;

@end
