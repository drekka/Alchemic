//
//  ALCException.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Simple extension to NSException for the soul purposes of being caught in try-catches.
 */
@interface ALCException : NSException
@end

#define declareException(name) \
@interface Alchemic ## name ## Exception : ALCException \
@end

declareException(Resolving)
declareException(Injection)

declareException(CircularReference)
declareException(IllegalArgument)
declareException(ReferenceObjectNotSet)
declareException(NoDependenciesFound)
declareException(DuplicateName)
declareException(InjectionNotFound)
declareException(IncorrectNumberOfValues)
declareException(TypeMissMatch)
declareException(SelectorNotFound)
declareException(IncorrectNumberOfArguments)
declareException(UnableToSetReference)
declareException(Lifecycle)
declareException(NilValue)
declareException(NilParentObject)
declareException(MethodNotFound)


