//
//  NSClient+Parsing.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "NSClient.h"

@interface NSClient (Parsing)

+ (NSData *)dataFromString:(NSString *)string;
+ (NSData *)dataFromJSONObject:(id)jsonObject;
- (NSData *)dataFromMultipartObject:(NSDictionary *)mulitpartObject;

- (NSData *)dataFromObject:(id <NSObject>)object withRequestType:(NSRequestType)requestType;

+ (NSString *)stringFromParameters:(NSDictionary *)dictionary;
+ (id)jsonObjectFromData:(NSData *)data;

@end
