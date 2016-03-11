//
//  ALCInternalMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#pragma mark - Block type defs

typedef void (^ALCSimpleBlock) (void);

#pragma mark - Useful code defines

#define str(template, ...) [NSString stringWithFormat:template, ## __VA_ARGS__ ]

#define blockSelf __weak __typeof(self) weakSelf = self;__typeof(self) strongSelf = weakSelf

#define throwException(exceptionName, template, ...) \
@throw [NSException \
        exceptionWithName:exceptionName \
        reason:str(template, ## __VA_ARGS__) \
        userInfo:nil]

#pragma mark - Assertions

#define methodNotImplemented \
NSAssert(NO, @"Abstract method [%@ %@] not implemented.", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

#define methodReturningObjectNotImplemented \
methodNotImplemented; \
return nil

#define methodReturningIntNotImplemented \
methodNotImplemented; \
return 0

#define methodReturningBooleanNotImplemented \
methodNotImplemented; \
return NO

#define methodReturningBlockNotImplemented \
methodNotImplemented; \
return NULL

