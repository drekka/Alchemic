//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCType.h"

#import "ALCRuntime.h"
#import "ALCValue.h"
#import "ALCInternalMacros.h"
#import "ALCModelSearchCriteria.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCType

-(instancetype) init {
    self = [super init];
    if (self) {
        _type = ALCValueTypeUnknown;
    }
    return self;
}

-(instancetype) initWithValueType:(ALCValueType) valueType {
    self = [super init];
    if (self) {
        _type = valueType;
    }
    return self;
}

#pragma mark - General factorie

+(ALCValue *) typeForIvar:(Ivar) ivar {
    return [self typeWithEncoding:ivar_getTypeEncoding(ivar)];
}

+(instancetype) typeWithClass:(Class) aClass {
    ALCType *type = [[ALCType alloc] init];
    [type setClass:aClass];
    return type;
}

+(instancetype) typeWithEncoding:(const char *) encoding {

    ALCType *type = [self objectTypeForEncoding:encoding];
    if (!type) {
        type = [self scalarTypeForEncoding:encoding];
        if (!type) {
            type = [self structTypeForEncoding:encoding];
        }
    }

    if (type) {
        return type;
    }

    throwException(AlchemicTypeMissMatchException, @"Encoding %s describes an unknown type", encoding);
}

#pragma mark - Type factories

#define typeFactoryImpl(typeName) \
+(instancetype) type ## typeName { \
    return [[ALCType alloc] initWithValueType:ALCValueType ## typeName]; \
}

typeFactoryImpl(Bool)
typeFactoryImpl(Char)
typeFactoryImpl(CharPointer)
typeFactoryImpl(Double)
typeFactoryImpl(Float)
typeFactoryImpl(Int)
typeFactoryImpl(Long)
typeFactoryImpl(LongLong)
typeFactoryImpl(Short)

typeFactoryImpl(UnsignedChar)
typeFactoryImpl(UnsignedInt)
typeFactoryImpl(UnsignedLong)
typeFactoryImpl(UnsignedLongLong)
typeFactoryImpl(UnsignedShort)

typeFactoryImpl(CGSize)
typeFactoryImpl(CGPoint)
typeFactoryImpl(CGRect)

#pragma mark - Internal

+(nullable ALCType *) objectTypeForEncoding:(const char *) encoding {

    if (! AcStrHasPrefix(encoding, "@")) {
        return nil;
    }

    // Object type.
    ALCType *type = [[ALCType alloc] initWithValueType:ALCValueTypeObject];
    NSCharacterSet *typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
    NSArray<NSString *> *defs = [[NSString stringWithUTF8String:encoding] componentsSeparatedByCharactersInSet:typeEncodingDelimiters];

    // If there is no more than 2 in the array then the dependency is an id.
    // Position 3 will be a class name, positions beyond that will be protocols.
    for (NSUInteger i = 2; i < [defs count]; i ++) {
        if ([defs[i] length] > 0) {
            if (i == 2) {
                // Update the class.
                [type setClass:objc_lookUpClass(defs[2].UTF8String)];
            } else {
                if (!type->_objcProtocols) {
                    type->_objcProtocols = [[NSMutableArray alloc] init];
                }
                [(NSMutableArray *)type->_objcProtocols addObject:objc_getProtocol(defs[i].UTF8String)];
            }
        }
    }
    return type;
}

+(nullable ALCType *) scalarTypeForEncoding:(const char *) encoding {

#define checkForScalarFromEncoding(scalarType, valueType) \
if (strcmp(encoding, scalarType) == 0) { \
return [[ALCType alloc] initWithValueType:ALCValueType ## valueType]; \
}

    checkForScalarFromEncoding("B", Bool)
    checkForScalarFromEncoding("c", Char)
    checkForScalarFromEncoding("r*", CharPointer)
    checkForScalarFromEncoding("*", CharPointer)
    checkForScalarFromEncoding("i", Int)
    checkForScalarFromEncoding("l", Long)
    checkForScalarFromEncoding("q", LongLong)
    checkForScalarFromEncoding("s", Short)
    checkForScalarFromEncoding("f", Float)
    checkForScalarFromEncoding("d", Double)
    checkForScalarFromEncoding("C", UnsignedChar)
    checkForScalarFromEncoding("I", UnsignedInt)
    checkForScalarFromEncoding("L", UnsignedLong)
    checkForScalarFromEncoding("Q", UnsignedLongLong)
    checkForScalarFromEncoding("S", UnsignedShort)
    return nil;
}

+(nullable ALCType *) structTypeForEncoding:(const char *) encoding {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{(\\w+)=.*"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:NULL];
    NSString *strEncoding = [NSString stringWithUTF8String:encoding];
    NSTextCheckingResult *result = [regex firstMatchInString:strEncoding
                                                     options:NSMatchingReportProgress
                                                       range:NSMakeRange(0, strEncoding.length)];
    if (result) {
        NSRange nameRange = [result rangeAtIndex:1];
        NSString *structName = [strEncoding substringWithRange:nameRange];
        if ([structName isEqualToString:@"CGSize"]) {
            return [self typeCGSize];
        } else if ([structName isEqualToString:@"CGPoint"]) {
            return [self typeCGPoint];
        } else if ([structName isEqualToString:@"CGRect"]) {
            return [self typeCGRect];
        }
    }
    return nil;
}

-(void) setClass:(Class) aClass {
    _type = [aClass isSubclassOfClass:[NSArray class]] ? ALCValueTypeArray : ALCValueTypeObject;
    self->_objcClass = aClass;
}

#pragma mark - Other methods

-(BOOL) isObjectType {
    return _type == ALCValueTypeObject || _type == ALCValueTypeArray;
}

-(NSString *) description {

    switch (_type) {

        case ALCValueTypeUnknown: return @"[unknown type]";
        case ALCValueTypeBool: return @"scalar BOOL";
        case ALCValueTypeChar: return @"scalar char";
        case ALCValueTypeCharPointer: return @"scalar char *";
        case ALCValueTypeDouble: return @"scalar double";
        case ALCValueTypeFloat: return @"scalar float";
        case ALCValueTypeInt: return @"scalar int";
        case ALCValueTypeLong: return @"scalar long";
        case ALCValueTypeLongLong: return @"scalar long long";
        case ALCValueTypeShort: return @"scalar short";
        case ALCValueTypeUnsignedChar: return @"scalar unsigned char";
        case ALCValueTypeUnsignedInt: return @"scalar unsigned int";
        case ALCValueTypeUnsignedLong: return @"scalar unsigned long";
        case ALCValueTypeUnsignedLongLong: return @"scalar unsigned long long";
        case ALCValueTypeUnsignedShort: return @"scalar unsigned short";
        case ALCValueTypeCGSize: return str(@"struct CGSize");
        case ALCValueTypeCGPoint: return str(@"struct CGPoint");
        case ALCValueTypeCGRect: return str(@"struct CGRect");
        case ALCValueTypeArray: return @"class NSArray *";

            // Object types.
        case ALCValueTypeObject: {

            if (self.objcProtocols.count > 0) {

                NSMutableArray<NSString *> *protocols = [[NSMutableArray alloc] init];
                for (Protocol *protocol in self.objcProtocols) {
                    [protocols addObject:NSStringFromProtocol(protocol)];
                }

                if (self.objcClass) {
                    return str(@"class %@<%@> *", NSStringFromClass(self.objcClass), [protocols componentsJoinedByString:@","]);
                } else {
                    return str(@"id<%@>", [protocols componentsJoinedByString:@","]);
                }

            } else {
                return self.objcClass ? str(@"class %@ *", NSStringFromClass(self.objcClass)) : @"id";
            }
        }
            
    }
}

@end

NS_ASSUME_NONNULL_END
