//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCType.h"

#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCModelSearchCriteria.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALCValue (copying)
-(void) setValue:(NSValue *) value completion:(nullable ALCSimpleBlock) completion;
@end

@implementation ALCType {
    NSString *_typeDesc;
}

#pragma mark - Factory methods

+(ALCValue *) typeForIvar:(Ivar) ivar {
    return [self typeWithEncoding:ivar_getTypeEncoding(ivar)];
}

+(instancetype) typeWithEncoding:(const char *) encoding {
    ALCType *typeData = [[ALCType alloc] initPrivate];
    [typeData setObjectType:encoding] || [typeData setScalarType:encoding];
    return typeData;
}

+(instancetype) typeWithClass:(Class) aClass {
    ALCType *type = [[ALCType alloc] initPrivate];
    [type setClass:aClass];
    return type;
}

#pragma mark - Initializers

-(instancetype) initPrivate {
    self = [super init];
    if (self) {
        _type = ALCValueTypeUnknown;
    }
    return self;
}

-(BOOL) setObjectType:(const char *) encoding {

    if (! AcStrHasPrefix(encoding, "@")) {
        return NO;
    }

    // Start with a result that indicates an Id. We map Ids as NSObjects.
    [self setClass:[NSObject class]];

    // Object type.
    NSCharacterSet *typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
    NSArray<NSString *> *defs = [[NSString stringWithUTF8String:encoding] componentsSeparatedByCharactersInSet:typeEncodingDelimiters];

    // If there is no more than 2 in the array then the dependency is an id.
    // Position 3 will be a class name, positions beyond that will be protocols.
    for (NSUInteger i = 2; i < [defs count]; i ++) {
        if ([defs[i] length] > 0) {
            if (i == 2) {
                // Update the class.
                [self setClass:objc_lookUpClass(defs[2].UTF8String)];
            } else {
                if (!_objcProtocols) {
                    _objcProtocols = [[NSMutableArray alloc] init];
                }
                [(NSMutableArray *)_objcProtocols addObject:objc_getProtocol(defs[i].UTF8String)];
            }
        }
    }
    return YES;
}

-(BOOL) setScalarType:(const char *) encoding {
    return [self setScalarType:"c" encoding:encoding type:ALCValueTypeChar desc:@"char"]
    || [self setScalarType:"i" encoding:encoding type:ALCValueTypeInt desc:@"int"]
    || [self setScalarType:"s" encoding:encoding type:ALCValueTypeShort desc:@"short"]
    || [self setScalarType:"l" encoding:encoding type:ALCValueTypeLong desc:@"long"]
    || [self setScalarType:"q" encoding:encoding type:ALCValueTypeLongLong desc:@"long long"]
    || [self setScalarType:"C" encoding:encoding type:ALCValueTypeUnsignedChar desc:@"unsigned char"]
    || [self setScalarType:"I" encoding:encoding type:ALCValueTypeUnsignedInt desc:@"unsigned int"]
    || [self setScalarType:"S" encoding:encoding type:ALCValueTypeUnsignedShort desc:@"unsigned short"]
    || [self setScalarType:"L" encoding:encoding type:ALCValueTypeUnsignedLong desc:@"unsigned long"]
    || [self setScalarType:"Q" encoding:encoding type:ALCValueTypeUnsignedLongLong desc:@"unsigned long long"]
    || [self setScalarType:"f" encoding:encoding type:ALCValueTypeFloat desc:@"float"]
    || [self setScalarType:"d" encoding:encoding type:ALCValueTypeDouble desc:@"double"]
    || [self setScalarType:"B" encoding:encoding type:ALCValueTypeBool desc:@"boolean"]
    || [self setScalarType:"*" encoding:encoding type:ALCValueTypeCharPointer desc:@"char array"];
}

-(BOOL) setScalarType:(const char *) scalarType encoding:(const char *) encoding type:(ALCValueType) type desc:(NSString *) desc {
    if (strcmp(encoding, scalarType) == 0) {
        _scalarType = scalarType;
        _type = type;
        _typeDesc = desc;
        _methodNameFragment = [desc.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@""];
        return YES;
    }
    return NO;
}

#pragma mark - Other methods

-(ALCValue *) withValue:(NSValue *) value completion:(nullable ALCSimpleBlock) completion {
    ALCType *valueObj = [[ALCValue alloc] initPrivate];
    valueObj->_type = _type;
    valueObj->_typeDesc = _typeDesc;
    valueObj->_methodNameFragment = _methodNameFragment;
    valueObj->_scalarType = _scalarType;
    valueObj->_objcClass = _objcClass;
    valueObj->_objcProtocols = _objcProtocols;
    [(ALCValue *)valueObj setValue:value completion:completion];
    return (ALCValue *) valueObj;
}

-(NSString *) description {
    if (self.objcClass) {
        NSString *className = self.objcClass ? NSStringFromClass((Class) self.objcClass) : @"";

        if (self.objcProtocols.count > 0) {

            NSMutableArray<NSString *> *protocols = [[NSMutableArray alloc] init];
            for (Protocol *protocol in self.objcProtocols) {
                [protocols addObject:NSStringFromProtocol(protocol)];
            }

            if (self.objcClass) {
                return str(@"plass %@<%@>", className, [protocols componentsJoinedByString:@","]);
            } else {
                return str(@"protocols <%@>", [protocols componentsJoinedByString:@","]);
            }

        } else {
            return str(@"Class %@", className);
        }
    }

    return str(@"scalar %@", _typeDesc);
}

-(void) setClass:(Class) aClass {
    if ([aClass isSubclassOfClass:[NSArray class]]) {
        _type = ALCValueTypeArray;
        _typeDesc = @"Array";
        _methodNameFragment = @"Array";
    } else {
        _type = ALCValueTypeObject;
        _typeDesc = @"Object";
        _methodNameFragment = @"Object";
    }
    _objcClass = aClass;
}



@end

NS_ASSUME_NONNULL_END
