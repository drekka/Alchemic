//
//  ALCObjectFactorySelector.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCInternalMacros.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^Criteria) (NSString *name, id<ALCObjectFactory> objectFactory);

#pragma mark - Core

@implementation ALCModelSearchCriteria {
    Criteria _acceptCriteria;
    BOOL _unique;
    NSString *_desc;
    ALCModelSearchCriteria *_nextModelSearchCriteria;
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

-(void) appendSearchCriteria:(ALCModelSearchCriteria *) criteria {
    
    if (_unique || criteria->_unique) {
        throwException(IllegalArgument, @"Name criteria must be the only critieria.");
    }
    
    if (_nextModelSearchCriteria) {
        [_nextModelSearchCriteria appendSearchCriteria:criteria];
    } else {
        _nextModelSearchCriteria = criteria;
    }
}

-(instancetype) initWithDesc:(NSString *) desc acceptorBlock:(Criteria) criteriaBlock {
    self = [super init];
    if (self) {
        _desc = desc;
        _acceptCriteria = criteriaBlock;
    }
    return self;
}

-(BOOL) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name {
    return _acceptCriteria(name, valueFactory)
    && (_nextModelSearchCriteria == nil || [_nextModelSearchCriteria acceptsObjectFactory:valueFactory name:name]);
}

-(NSString *)description {
    NSString *nextDesc = _nextModelSearchCriteria.description;
    return nextDesc ? str(@"%@ and %@", _desc, nextDesc) : _desc;
}

@end

NS_ASSUME_NONNULL_END
