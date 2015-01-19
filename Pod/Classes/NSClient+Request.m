//
//  NSClient+Request.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "NSClient+Request.h"
#import "NSClient+Parsing.h"

@implementation NSClient (Request)

- (NSURL *)urlWithEndpoint:(NSString *)endpoint
{
    return [self urlWithEndpoint:endpoint andParameters:nil];
}

- (NSURL *)urlWithEndpoint:(NSString *)endpoint andParameters:(NSDictionary *)parameters
{
    NSString *path = [NSString stringWithFormat:@"/%@%@", endpoint ? : @"", (parameters.allKeys.count ? [[self class] stringFromParameters:parameters] : @"")];
    return [[NSURL alloc] initWithScheme:self.scheme
                                    host:self.host
                                    path:path];
}

- (NSString *)contentTypeWithRequestType:(NSRequestType)requestType
{
    switch(requestType)
    {
        case NSRequestTypeData:      return kContentTypeData;
        case NSRequestTypeJSON:      return kContentTypeJSON;
        case NSRequestTypeMultipart: return [NSString stringWithFormat:@"%@; boundary=%@", kContentTypeMultipart, self.boundaryString];
        default:                     return nil;
    }
}

- (NSString *)httpMethodFromType:(NSHTTPMethodType)methodType
{
    switch(methodType)
    {
        case NSHTTPMethodTypeGet:    return @"GET";
        case NSHTTPMethodTypePost:   return @"POST";
        case NSHTTPMethodTypePut:    return @"PUT";
        case NSHTTPMethodTypeDelete: return @"DELETE";
        default:                     return nil;
    }
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url httpMethod:(NSString *)httpMethod
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:self.cachingPolicy
                                                       timeoutInterval:self.requestTimeout];
    [request setHTTPMethod:httpMethod];
    return request;
}

@end
