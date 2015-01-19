//
//  NSClient.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "NSClient+Parsing.h"
#import "NSClient+Request.h"
#import "Reachability.h"

@implementation NSClient

+ (instancetype)clientWithScheme:(NSString *)scheme andHost:(NSString *)host
{
    NSClient *client = [self new];
    [client setScheme:scheme];
    [client setHost:host];
    return client;
}

- (void)sendRequest:(NSMutableURLRequest *)request withResponseCallback:(NSResponseCallback)callback
{
    // If the network isn't reachable, don't perform request
    if([Reachability reachabilityForInternetConnection].isReachable)
    {
        callback(0, nil, [NSError errorWithDomain:@"Could not reach network." code:0 userInfo:nil]);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       NSURLResponse *response = nil;
                       NSError *error = nil;
                       NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                       
                       NSUInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                       // Try parsing as JSON
                       id parsedObject = [[self class] jsonObjectFromData:responseData];
                       
                       if(callback)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              callback(statusCode, parsedObject, error);
                                          });
                       }
                   });
}

- (void)sendRequestWithEndpoint:(NSString *)endpoint
                 httpMethodType:(NSHTTPMethodType)httpMethodType
                    requestType:(NSRequestType)requestType
                     dataObject:(id <NSObject>)dataObject
           requestMutationBlock:(NSURLRequestMutationBlock)requestMutationBlock
                    andCallback:(NSResponseCallback)callback
{
    NSMutableURLRequest *request = [self requestWithURL:[self urlWithEndpoint:endpoint]
                                             httpMethod:[self httpMethodFromType:httpMethodType]];
    
    if(requestType != NSRequestTypeURL)
    {
        [request setValue:[self contentTypeWithRequestType:requestType] forHTTPHeaderField:kContentTypeKey];
        
        if(dataObject)
        {
            NSData *bodyData = [self dataFromObject:dataObject withRequestType:requestType];
            [request setHTTPBody:bodyData];
            [request setValue:@(bodyData.length).stringValue forHTTPHeaderField:kContentLengthKey];
        }
    }
    
    if(requestMutationBlock)
    {
        requestMutationBlock(request);
    }
    
    [self sendRequest:request withResponseCallback:callback];
}

#pragma mark - Private Implementation -

- (NSString *)boundaryString
{
    return (_boundaryString ? : (_boundaryString = [NSUUID UUID].UUIDString));
}

@end