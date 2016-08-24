//
//  ALCTypeData.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCTypeData.h"

#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCTypeData

-(instancetype) initWithEncoding:(const char *) encoding {
    self = [super init];
    if (self) {

        // Get the type.
        if (AcStrHasPrefix(encoding, "@")) {

            // Start with a result that indicates an Id. We map Ids as NSObjects.
            _objcClass = [NSObject class];

            // Object type.
            NSCharacterSet *typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
            NSArray<NSString *> *defs = [[NSString stringWithUTF8String:encoding] componentsSeparatedByCharactersInSet:typeEncodingDelimiters];

            // If there is no more than 2 in the array then the dependency is an id.
            // Position 3 will be a class name, positions beyond that will be protocols.
            for (NSUInteger i = 2; i < [defs count]; i ++) {
                if ([defs[i] length] > 0) {
                    if (i == 2) {
                        // Update the class.
                        _objcClass = objc_lookUpClass(defs[2].UTF8String);
                    } else {
                        if (!_objcProtocols) {
                            _objcProtocols = [[NSMutableArray alloc] init];
                        }
                        [(NSMutableArray *)_objcProtocols addObject:objc_getProtocol(defs[i].UTF8String)];
                    }
                }
            }
            return self;
        }

        // Not an object type.
        _scalarType = encoding;
    }
    return self;
}

-(ALCType) typeForScalarType:(const char *) scalarType {
    if (strcmp(scalarType, "c") == 0) {
        return ALCTypeChar;
    } else if (strcmp(scalarType, "i") == 0) {
        return ALCTypeInt;
    } else if (strcmp(scalarType, "s") == 0) {
        return ALCTypeShort;
    } else if (strcmp(scalarType, "l") == 0) {
        return ALCTypeLong;
    } else if (strcmp(scalarType, "q") == 0) {
        return ALCTypeLongLong;
    } else if (strcmp(scalarType, "C") == 0) {
        return ALCTypeUnsignedChar;
    } else if (strcmp(scalarType, "I") == 0) {
        return ALCTypeUnsignedInt;
    } else if (strcmp(scalarType, "S") == 0) {
        return ALCTypeUnsignedShort;
    } else if (strcmp(scalarType, "L") == 0) {
        return ALCTypeUnsignedLong;
    } else if (strcmp(scalarType, "Q") == 0) {
        return ALCTypeUnsignedLongLong;
    } else if (strcmp(scalarType, "f") == 0) {
        return ALCTypeFloat;
    } else if (strcmp(scalarType, "d") == 0) {
        return ALCTypeDouble;
    } else if (strcmp(scalarType, "B") == 0) {
        return ALCTypeBool;
    } else if (strcmp(scalarType, "*") == 0) {
        return ALCTypeCharPointer;
    }

}

-(BOOL) canMapToTypeData:(ALCTypeData *) otherTypeData {
    if (otherTypeData.scalarType) {
        switch (otherTypeData.scalarType) {

        }
    }
    return NO;
}

-(NSString *) description {
    if (self.scalarType) {
        return [NSString stringWithFormat:@"Scalar %s", self.scalarType];
    } else {
        NSString *className = self.objcClass ? NSStringFromClass((Class) self.objcClass) : @"";
        NSMutableArray<NSString *> *protocols = [[NSMutableArray alloc] init];
        for (Protocol *protocol in self.objcProtocols) {
            [protocols addObject:NSStringFromProtocol(protocol)];
        }
        if (self.objcProtocols.count > 0) {
            if (self.objcClass) {
                return [NSString stringWithFormat:@"%@<%@>", className, [protocols componentsJoinedByString:@","]];
            } else {
                return [NSString stringWithFormat:@"<%@>", [protocols componentsJoinedByString:@","]];
            }
        } else {
            return [NSString stringWithFormat:@"%@", className];
        }
    }
}

NS_ASSUME_NONNULL_END

@end
