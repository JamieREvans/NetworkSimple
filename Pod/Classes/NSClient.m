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
    if(![Reachability reachabilityForInternetConnection].isReachable)
    {
        callback(0, nil, [NSError errorWithDomain:@"Could not reach network." code:0 userInfo:nil]);
        return;
    }
    
    __block typeof(self) selfBlockReference = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       @try
                       {
                           NSHTTPURLResponse *response;
                           NSError *error;
                           NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                           
                           NSUInteger statusCode = response.statusCode;
                           
                           // If the url has changed, but not set a redirect status code, change the status code
                           if(![request.URL.absoluteString isEqualToString:response.URL.absoluteString] && statusCode < 300 && statusCode >= 200)
                           {
                               statusCode = 303;
                           }
                           
                           // Post Response Headers
                           if(response.allHeaderFields)
                           {
                               [[NSNotificationCenter defaultCenter] postNotificationName:kResponseHeadersNotification
                                                                                   object:selfBlockReference
                                                                                 userInfo:@{kResponseHeadersKey : response.allHeaderFields}];
                           }
                           
                           // Try parsing as JSON
                           id parsedObject = [[selfBlockReference class] jsonObjectFromData:responseData];
                           
                           void (^sendCallback)() = ^
                           {
                               if(callback)
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^
                                                  {
                                                      callback(statusCode, parsedObject, error);
                                                  });
                               }
                           };
                           
                           // Handle authentication
                           if(statusCode == 401 && selfBlockReference.authenticationFailureHandler)
                           {
                               // Check if the authentication failure handler wants to handle the response, otherwise calling back
                               if(!selfBlockReference.authenticationFailureHandler(statusCode, parsedObject, request, callback, error))
                               {
                                   sendCallback();
                               }
                           }
                           else
                           {
                               sendCallback();
                           }
                       }
                       @catch(NSException *exception)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              callback(400, nil, [NSError errorWithDomain:@"NSClient Request Exception" code:400 userInfo:@{@"exception" : exception}]);
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