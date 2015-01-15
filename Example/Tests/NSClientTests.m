//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "Kiwi.h"
#import "NSClient+Parsing.h"
#import "NSClient+Request.h"

SPEC_BEGIN(NSClientSpec)

describe(@"When allocating the client", ^
{
    __block NSClient *client = nil;
    
    it(@"the host and scheme should be set", ^
       {
           client = [NSClient clientWithScheme:@"http" andHost:@"api.randomuser.me"];
           
           [[client.scheme should] equal:@"http"];
           [[client.host should] equal:@"api.randomuser.me"];
       });
    
    it(@"a basic request should return data and a status code", ^
       {
           __block id responseObject = nil;
           __block NSNumber *statusCode = nil;
           
           // Client request
           [client sendRequestWithEndpoint:[NSClient stringFromParameters:@{@"results" : @20}]
                            httpMethodType:NSHTTPMethodTypeGet
                               requestType:NSRequestTypeURL
                                dataObject:nil
                      requestMutationBlock:nil
                               andCallback:^(NSUInteger _statusCode, id _responseObject, NSError *error)
            {
                responseObject = _responseObject;
                statusCode = @(_statusCode);
            }];
           
           [[expectFutureValue(responseObject) shouldEventuallyBeforeTimingOutAfter(4.0f)] beNonNil];
           [[expectFutureValue(statusCode) shouldEventuallyBeforeTimingOutAfter(4.0f)] beGreaterThan:@0];
       });
});

SPEC_END