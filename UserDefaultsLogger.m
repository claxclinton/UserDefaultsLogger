//
//  UserDefaultsLogger.m
//  Rebtel2
//
//  Created by Claes Lilliesköld on 10/6/12.
//  Copyright (c) 2012 Rebtel Services S.à.r.l. All rights reserved.
//

#import "UserDefaultsLogger.h"

enum kUserDefaultsType
{
    kUserDefaultsTypeData = 0,
    kUserDefaultsTypeString = 1,
    kUserDefaultsTypeNumber = 2,
    kUserDefaultsTypeDate = 3,
    kUserDefaultsTypeArray = 4,
    kUserDefaultsTypeDictionary = 5,
    kUserDefaultsTypeUnknown = -1,
};

@implementation UserDefaultsLogger

- (enum kUserDefaultsType)defaultsTypeForObject:(id)object
{
    enum kUserDefaultsType defaultsType;
    if ([object isKindOfClass:[NSData class]]) {
        defaultsType = kUserDefaultsTypeData;
    } else if ([object isKindOfClass:[NSString class]]) {
        defaultsType = kUserDefaultsTypeString;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        defaultsType = kUserDefaultsTypeNumber;
    } else if ([object isKindOfClass:[NSDate class]]) {
        defaultsType = kUserDefaultsTypeDate;
    } else if ([object isKindOfClass:[NSArray class]]) {
        defaultsType = kUserDefaultsTypeArray;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        defaultsType = kUserDefaultsTypeDictionary;
    } else {
        defaultsType = kUserDefaultsTypeUnknown;
    }
    
    return defaultsType;
}

- (BOOL)isPropertyList:(id)object
{
    return ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]);
}

- (void)logValueOfProperty:(id)property
{
    
}

- (void)logValueOfPropertyKey:(NSString *)key withObject:(id)object andType:(enum kUserDefaultsType)type
{
    switch (type) {
        case kUserDefaultsTypeData:
            NSLog(@"property:\"%@\" type:NSData", key);
            break;
        case kUserDefaultsTypeString:
            NSLog(@"property:\"%@\" type:NSString value:\"%@\"", key, object);
            break;
        case kUserDefaultsTypeNumber:
            NSLog(@"property:\"%@\" type:NSNumber value:\"%@\"", key, object);
            break;
        case kUserDefaultsTypeDate:
            NSLog(@"property:\"%@\" type:NSDate value:\"%@\"", key, object);
            break;
        case kUserDefaultsTypeUnknown:
        default:
            NSLog(@"property:\"%@\" type:Unknown value:\"%@\"", key, object);
            break;            
    }
}

- (void)logValuesOfDictionary:(id)dictionary withName:(NSString *)name
{
    if ([self isPropertyList:dictionary]) {
        id <NSFastEnumeration>list = dictionary;
        
        for (NSString *key in list) {
            id object = [dictionary objectForKey:key];
            enum kUserDefaultsType defaultsType = [self defaultsTypeForObject:object];
            
            switch (defaultsType) {
                case kUserDefaultsTypeData:
                case kUserDefaultsTypeString:
                case kUserDefaultsTypeNumber:
                case kUserDefaultsTypeDate:
                case kUserDefaultsTypeArray:
                    [self logValueOfPropertyKey:key withObject:object andType:defaultsType];
                    break;
                case kUserDefaultsTypeDictionary:
                    [self logValuesOfDictionary:object withName:key];
                    break;
                case kUserDefaultsTypeUnknown:
                default:
                    NSLog(@"Strange");
                    ;
            }
        }
    } else {
        [self logValueOfProperty:dictionary];
    }
}

- (void)logUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *allPersistentDomainNames = [userDefaults persistentDomainNames];
    for (NSString *currentPersistenceDomain in allPersistentDomainNames) {
        NSLog(@"Persistent Domain %@", currentPersistenceDomain);
        NSLog(@"====================================");
        NSDictionary *userDefaultsDictionary = [userDefaults persistentDomainForName:currentPersistenceDomain];
        [self logValuesOfDictionary:userDefaultsDictionary withName:currentPersistenceDomain];
    }
}

@end
