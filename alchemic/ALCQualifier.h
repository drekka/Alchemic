//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 Indicates what type of qualifier this is.
 */
typedef NS_ENUM(NSUInteger, QualifierType) {
    QualifierTypeString,
    QualifierTypeClass,
    QualifierTypeProtocol
};


/**
 Wraps an argument so that it can be conveniantly passed around. 
 
 Usually arguments are classes, protocols or names.
 */
@interface ALCQualifier : NSObject

@property (nonatomic, assign, readonly) QualifierType type;
@property (nonatomic, strong, readonly) id value;

+(instancetype) qualifierWithValue:(id) value;

-(BOOL) matchesBuilder:(id<ALCBuilder>) builder;

-(BOOL) isEqualToQualifier:(ALCQualifier *) qualifier;

@end

NS_ASSUME_NONNULL_END