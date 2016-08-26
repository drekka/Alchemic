//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCValue.h"

#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCInternalMacros.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue

-(instancetype) initPrivate {
    self = [super init];
    if (self) {
        _type = ALCValueTypeUnknown;
    }
    return self;
}

+(ALCValue *) valueForIvar:(Ivar) ivar {
    return [self valueWithEncoding:ivar_getTypeEncoding(ivar)];
}

+(instancetype) valueWithEncoding:(const char *) encoding {
    return [self value:nil withEncoding:encoding];
}

+(instancetype) value:(nullable NSValue *) value withEncoding:(const char *) encoding {

    ALCValue *typeData = [[ALCValue alloc] initPrivate];
    typeData.value = value;
    
    [typeData setObjectType:encoding]
    ||[typeData setScalarType:encoding];
    
    return typeData;
}

-(BOOL) setObjectType:(const char *) encoding {
    
    if (! AcStrHasPrefix(encoding, "@")) {
        return NO;
    }
    
    // Start with a result that indicates an Id. We map Ids as NSObjects.
    _type = ALCValueTypeObject;
    _objcClass = [NSObject class];
    _typeDescription = @"Object";
    
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

-(BOOL) setScalarType:(const char *) scalarType
             encoding:(const char *) encoding
                 type:(ALCValueType) type
                 desc:(NSString *) desc {
    if (strcmp(encoding, scalarType) == 0) {
        _scalarType = scalarType;
        _type = type;
        _typeDescription = desc;
        return YES;
    }
    return NO;
}

-(NSString *)methodNamePart {
    return [self.typeDescription.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(NSString *) description {
    if (self.type != ALCValueTypeObject) {
        return [NSString stringWithFormat:@"Scalar %@", _typeDescription];
    } else {
        NSString *className = self.objcClass ? NSStringFromClass((Class) self.objcClass) : @"";

        if (self.objcProtocols.count > 0) {
        
            NSMutableArray<NSString *> *protocols = [[NSMutableArray alloc] init];
            for (Protocol *protocol in self.objcProtocols) {
                [protocols addObject:NSStringFromProtocol(protocol)];
            }
            
            if (self.objcClass) {
                return [NSString stringWithFormat:@"Class %@<%@>", className, [protocols componentsJoinedByString:@","]];
            } else {
                return [NSString stringWithFormat:@"Protocols <%@>", [protocols componentsJoinedByString:@","]];
            }
        
        } else {
            return [NSString stringWithFormat:@"Class %@", className];
        }
    }
}

NS_ASSUME_NONNULL_END

@end
