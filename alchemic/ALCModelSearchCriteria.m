//
//  ALCObjectFactorySelector.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^Criteria) (NSString *name, id<ALCObjectFactory> objectFactory);

#pragma mark - C wrappers for Swift

ALCModelSearchCriteria * AcWithClass(Class aClass) {
    return [ALCModelSearchCriteria searchCriteriaForClass:aClass];
}

ALCModelSearchCriteria * AcWithProtocol(Protocol *aProtocol) {
    return [ALCModelSearchCriteria searchCriteriaForProtocol:aProtocol];
}

ALCModelSearchCriteria * AcWithName(NSString *name) {
    return [ALCModelSearchCriteria searchCriteriaForName:name];
}

#pragma mark - Core

@implementation ALCModelSearchCriteria {
    Criteria _acceptCriteria;
    BOOL _unique;
    NSString *_desc;
}

#pragma mark - Factory methods

+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz {
    return [[ALCModelSearchCriteria alloc] initWithDesc:str(@"class %@", NSStringFromClass(clazz))
                                          acceptorBlock:^(NSString *objectFactoryName,
                                                          id<ALCObjectFactory> objectFactory) {
                                              return [objectFactory.objectClass isSubclassOfClass:clazz];
                                          }];
}

+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol {
    return [[ALCModelSearchCriteria alloc] initWithDesc:str(@"protocol %@", NSStringFromProtocol(protocol))
                                          acceptorBlock:^(NSString *objectFactoryName,
                                                          id<ALCObjectFactory> objectFactory) {
                                              return [objectFactory.objectClass conformsToProtocol:protocol];
                                          }];
}

+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name {
    ALCModelSearchCriteria *criteria = [[ALCModelSearchCriteria alloc] initWithDesc:str(@"name '%@'", name)
                                                                      acceptorBlock:^(NSString *valueFactoryName,
                                                                                      id<ALCObjectFactory> valueFactory) {
                                                                          return [valueFactoryName isEqualToString:name];
                                                                      }];
    criteria->_unique = YES;
    return criteria;
}

#pragma mark - Tasks

-(void) setNextSearchCriteria:(ALCModelSearchCriteria *) nextSearchCriteria {
    if (_unique || nextSearchCriteria->_unique) {
        throwException(@"AlchemicIllegalArgument", @"You cannot combine model search criteria and constants in the one injection.");
    }
    _nextSearchCriteria = nextSearchCriteria;
}

-(instancetype) initWithDesc:(NSString *) desc acceptorBlock:(Criteria) criteriaBlock {
    self = [super init];
    if (self) {
        _desc = desc;
        _acceptCriteria = criteriaBlock;
    }
    return self;
}

-(ALCModelSearchCriteria *) combineWithCriteria:(ALCModelSearchCriteria *) otherCriteria {
    self.nextSearchCriteria = otherCriteria;
    return self;
}

-(BOOL) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name {
    return _acceptCriteria(name, valueFactory)
    && (_nextSearchCriteria == nil || [_nextSearchCriteria acceptsObjectFactory:valueFactory name:name]);
}

-(NSString *)description {
    NSString *nextDesc = self.nextSearchCriteria.description;
    return nextDesc ? str(@"%@ and %@", _desc, nextDesc) : _desc;
}

@end

NS_ASSUME_NONNULL_END
