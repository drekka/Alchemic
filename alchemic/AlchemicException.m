//
//  ALCException.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/AlchemicException.h>

@implementation AlchemicException
@end

#define declareExceptionImpl(name) \
@implementation Alchemic ## name ## Exception \
@end

declareExceptionImpl(CircularReference)
declareExceptionImpl(IllegalArgument)
declareExceptionImpl(ReferencedObjectNotSet)
declareExceptionImpl(NoDependenciesFound)
declareExceptionImpl(DuplicateName)
declareExceptionImpl(InjectionNotFound)
declareExceptionImpl(TooManyValues)
declareExceptionImpl(TypeMissMatch)
declareExceptionImpl(SelectorNotFound)
declareExceptionImpl(IncorrectNumberOfArguments)
