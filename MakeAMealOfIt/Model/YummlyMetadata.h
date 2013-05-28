//
//  YummlyMetadata.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 27/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyAPI.h"

#pragma mark - Yummly Metadata Public Interface

@interface YummlyMetadata : NSObject

#pragma mark - Public Properties

+ (NSDictionary *)allMetadata;
+ (void)forceMetadataRefresh:(NSString *)metadataKey;

@end