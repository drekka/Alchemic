//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCType.h>

#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCModelSearchCriteria.h>

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

+(instancetype) bool {
    return [[ALCType alloc] initWithValueType:ALCValueTypeBool];
}

+(instancetype) char {
    return [[ALCType alloc] initWithValueType:ALCValueTypeChar];
}

+(instancetype) charPointer {
    return [[ALCType alloc] initWithValueType:ALCValueTypeCharPointer];
}

+(instancetype) double {
    return [[ALCType alloc] initWithValueType:ALCValueTypeDouble];
}

+(instancetype) float {
    return [[ALCType alloc] initWithValueType:ALCValueTypeFloat];
}

+(instancetype) int {
    return [[ALCType alloc] initWithValueType:ALCValueTypeInt];
}

+(instancetype) long {
    return [[ALCType alloc] initWithValueType:ALCValueTypeLong];
}

+(instancetype) longLong {
    return [[ALCType alloc] initWithValueType:ALCValueTypeLongLong];
}

+(instancetype) short {
    return [[ALCType alloc] initWithValueType:ALCValueTypeShort];
}

+(instancetype) unsignedChar {
    return [[ALCType alloc] initWithValueType:ALCValueTypeUnsignedChar];
}

+(instancetype) unsignedInt {
    return [[ALCType alloc] initWithValueType:ALCValueTypeUnsignedInt];
}

+(instancetype) unsignedLong {
    return [[ALCType alloc] initWithValueType:ALCValueTypeUnsignedLong];
}

+(instancetype) unsignedLongLong {
    return [[ALCType alloc] initWithValueType:ALCValueTypeUnsignedLongLong];
}

+(instancetype) unsignedShort {
    return [[ALCType alloc] initWithValueType:ALCValueTypeUnsignedShort];
}

+(instancetype) CGSize {
    return [[ALCType alloc] initWithValueType:ALCValueTypeCGSize];
}

+(instancetype) CGPoint {
    return [[ALCType alloc] initWithValueType:ALCValueTypeCGPoint];
}

+(instancetype) CGRect {
    return [[ALCType alloc] initWithValueType:ALCValueTypeCGRect];
}

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

#define checkForScalarFromEncoding(scalarType, factoryMethod) \
if (strcmp(encoding, scalarType) == 0) { \
return [ALCType factoryMethod]; \
}

    checkForScalarFromEncoding("B", bool)
    checkForScalarFromEncoding("c", char)
    checkForScalarFromEncoding("*", charPointer)
    checkForScalarFromEncoding("i", int)
    checkForScalarFromEncoding("l", long)
    checkForScalarFromEncoding("q", longLong)
    checkForScalarFromEncoding("s", short)
    checkForScalarFromEncoding("f", float)
    checkForScalarFromEncoding("d", double)
    checkForScalarFromEncoding("C", unsignedChar)
    checkForScalarFromEncoding("I", unsignedInt)
    checkForScalarFromEncoding("L", unsignedLong)
    checkForScalarFromEncoding("Q", unsignedLongLong)
    checkForScalarFromEncoding("S", unsignedShort)
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
            return [self CGSize];
        } else if ([structName isEqualToString:@"CGPoint"]) {
            return [self CGPoint];
        } else if ([structName isEqualToString:@"CGRect"]) {
            return [self CGRect];
        }
    }
    return nil;
}

-(void) setClass:(Class) aClass {
    _type = [aClass isSubclassOfClass:[NSArray class]] ? ALCValueTypeArray : ALCValueTypeObject;
    self->_objcClass = aClass;
}

#pragma mark - Other methods

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
