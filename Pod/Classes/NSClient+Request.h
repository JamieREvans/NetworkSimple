//
//  NSClient+Request.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "NSClient.h"

@interface NSClient (Request)

// Do not include '/' at the start of the endpoint
- (NSURL *)urlWithEndpoint:(NSString *)endpoint;
- (NSURL *)urlWithEndpoint:(NSString *)endpoint andParameters:(NSDictionary *)parameters;

- (NSString *)contentTypeWithRequestType:(NSRequestType)requestType;
- (NSString *)httpMethodFromType:(NSHTTPMethodType)methodType;

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url httpMethod:(NSString *)httpMethod;

@end
