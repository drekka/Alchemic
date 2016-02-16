//
//  ALCInternalMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#define str(template, ...) [NSString stringWithFormat:template, ## __VA_ARGS__ ]

#define blockSelf __weak __typeof(self) weakSelf = self;__typeof(self) strongSelf = weakSelf

#define throwException(exceptionName, template, ...) \
@throw [NSException \
        exceptionWithName:exceptionName \
        reason:str(template, ## __VA_ARGS__) \
        userInfo:nil]


typedef void (^SimpleBlock) (void);