//
//  ALCObjectFactorySelector.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"

NS_ASSUME_NONNULL_BEGIN

typedef bool (^Criteria) (NSString *name, id<ALCObjectFactory> objectFactory);

@implementation ALCModelSearchCriteria {
    Criteria _acceptCriteria;
}

+(ALCModelSearchCriteria *) searchCriteriaForClass:(Class) clazz {
    return [[ALCModelSearchCriteria alloc] initWithAcceptorBlock:^(NSString *objectFactoryName,
                                                                id<ALCObjectFactory> objectFactory) {
        return [objectFactory.objectClass isSubclassOfClass:clazz];
    }];
}

+(ALCModelSearchCriteria *) searchCriteriaForProtocol:(Protocol *) protocol {
    return [[ALCModelSearchCriteria alloc] initWithAcceptorBlock:^(NSString *objectFactoryName,
                                                                  id<ALCObjectFactory> objectFactory) {
        return [objectFactory.objectClass conformsToProtocol:protocol];
    }];
}

+(ALCModelSearchCriteria *) searchCriteriaForName:(NSString *) name {
    return [[ALCModelSearchCriteria alloc] initWithAcceptorBlock:^(NSString *valueFactoryName,
                                                                id<ALCObjectFactory> valueFactory) {
        return [valueFactoryName isEqualToString:name];
    }];
}

-(instancetype) initWithAcceptorBlock:(Criteria) criteriaBlock {
    self = [super init];
    if (self) {
        _acceptCriteria = criteriaBlock;
    }
    return self;
}

-(bool) acceptsObjectFactory:(id<ALCObjectFactory>) valueFactory name:(NSString *) name {
    return _acceptCriteria(name, valueFactory)
    && (
        _nextSearchCriteria == nil || [_nextSearchCriteria acceptsObjectFactory:valueFactory name:name]
        );
}

@end

NS_ASSUME_NONNULL_END
