//
//  ALCException.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCException.h"

@implementation ALCException
@end

#define declareExceptionImpl(name) \
@implementation Alchemic ## name ## Exception \
@end

declareExceptionImpl(Resolving)
declareExceptionImpl(Injection)
declareExceptionImpl(TooManyResults)
declareExceptionImpl(IllegalArgument)
declareExceptionImpl(ReferenceObjectNotSet)
declareExceptionImpl(NoDependenciesFound)
declareExceptionImpl(DuplicateName)
declareExceptionImpl(InjectionNotFound)
declareExceptionImpl(IncorrectNumberOfValues)
declareExceptionImpl(TypeMissMatch)
declareExceptionImpl(SelectorNotFound)
declareExceptionImpl(IncorrectNumberOfArguments)
declareExceptionImpl(UnableToSetReference)
declareExceptionImpl(Lifecycle)
declareExceptionImpl(NilValue)
declareExceptionImpl(NilParentObject)
declareExceptionImpl(MethodNotFound)
