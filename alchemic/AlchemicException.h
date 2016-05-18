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
@interface AlchemicException : NSException
@end

#define declareException(name) \
@interface Alchemic ## name ## Exception : AlchemicException \
@end

declareException(CircularReference)
declareException(IllegalArgument)
declareException(ReferencedObjectNotSet)
declareException(NoDependenciesFound)
declareException(DuplicateName)
declareException(InjectionNotFound)
declareException(TooManyValues)
declareException(TypeMissMatch)
declareException(SelectorNotFound)
declareException(IncorrectNumberOfArguments)


