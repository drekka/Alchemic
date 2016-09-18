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

#pragma mark - Factory methods

+(ALCValue *) typeForIvar:(Ivar) ivar {
    return [self typeWithEncoding:ivar_getTypeEncoding(ivar)];
}

+(instancetype) typeWithClass:(Class) aClass {
    ALCType *type = [[ALCType alloc] init];
    [type setClass:aClass];
    return type;
}

+(instancetype) typeWithEncoding:(const char *) encoding {
    ALCType *type = [[ALCType alloc] init];
    if ([type setObjectType:encoding]
        || [type setScalarType:encoding]
        || [type setStructType:encoding]) {
        return type;
    }
    throwException(AlchemicTypeMissMatchException, @"Encoding %s describes an unknown type", encoding);
}

-(BOOL) setObjectType:(const char *) encoding {

    if (! AcStrHasPrefix(encoding, "@")) {
        return NO;
    }

    // Object type.
    _type = ALCValueTypeObject;
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
    return [self setScalarType:"c" encoding:encoding type:ALCValueTypeChar]
    || [self setScalarType:"i" encoding:encoding type:ALCValueTypeInt]
    || [self setScalarType:"s" encoding:encoding type:ALCValueTypeShort]
    || [self setScalarType:"l" encoding:encoding type:ALCValueTypeLong]
    || [self setScalarType:"q" encoding:encoding type:ALCValueTypeLongLong]
    || [self setScalarType:"C" encoding:encoding type:ALCValueTypeUnsignedChar]
    || [self setScalarType:"I" encoding:encoding type:ALCValueTypeUnsignedInt]
    || [self setScalarType:"S" encoding:encoding type:ALCValueTypeUnsignedShort]
    || [self setScalarType:"L" encoding:encoding type:ALCValueTypeUnsignedLong]
    || [self setScalarType:"Q" encoding:encoding type:ALCValueTypeUnsignedLongLong]
    || [self setScalarType:"f" encoding:encoding type:ALCValueTypeFloat]
    || [self setScalarType:"d" encoding:encoding type:ALCValueTypeDouble]
    || [self setScalarType:"B" encoding:encoding type:ALCValueTypeBool]
    || [self setScalarType:"*" encoding:encoding type:ALCValueTypeCharPointer];
}

-(BOOL) setStructType:(const char *) encoding {
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
            _type = ALCValueTypeCGSize;
        } else if ([structName isEqualToString:@"CGPoint"]) {
            _type = ALCValueTypeCGPoint;
        } else if ([structName isEqualToString:@"CGRect"]) {
            _type = ALCValueTypeCGRect;
        }
    }
    return _type != ALCValueTypeUnknown;
}

-(BOOL) setScalarType:(const char *) scalarType encoding:(const char *) encoding type:(ALCValueType) type {
    if (strcmp(encoding, scalarType) == 0) {
        _scalarType = [NSString stringWithUTF8String:scalarType];
        _type = type;
    }
    return _type != ALCValueTypeUnknown;
}

#pragma mark - Other methods

-(void) setClass:(Class) aClass {
    _type = [aClass isSubclassOfClass:[NSArray class]] ? ALCValueTypeArray : ALCValueTypeObject;
    self->_objcClass = aClass;
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
