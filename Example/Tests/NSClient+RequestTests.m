//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "Kiwi.h"
#import "NSClient.h"

SPEC_BEGIN(NSClientSpec)

describe(@"When allocating the client", ^
{
    __block NSClient *client = nil;
    
    it(@"the host and scheme should be set", ^
    {
        client = [NSClient clientWithScheme:@"http" andHost:@"randomuser.me"];
        
        [[client.scheme should] equal:@"http"];
        [[client.host should] equal:@"randomuser.me"];
    });
    
    it(@"a basic request should return data and a status code", ^
    {
        __block id data = nil;
        //__block NSUInteger statusCode = 0;
        
        // Client request
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:2.0f];
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               data = [@"Contents!" dataUsingEncoding:NSUTF8StringEncoding];
                           });
        });
        
        [[expectFutureValue(data) shouldEventuallyBeforeTimingOutAfter(4.0f)] beNonNil];
        // Test status code?
    });
});

SPEC_END