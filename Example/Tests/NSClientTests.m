//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import <Kiwi.h>
#import <OCMock.h>
#import "NSClient+Parsing.h"
#import "NSClient+Request.h"
#import "Reachability.h"

SPEC_BEGIN(NSClientSpec)

void (^stubSynchronousRequestWithStatusCodeAndURL)(NSUInteger statusCode, NSString *url) = ^(NSUInteger statusCode, NSString *url)
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url]
                                                              statusCode:statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{}];
    
    id connectionMock = OCMClassMock([NSURLConnection class]);
    OCMStub([connectionMock sendSynchronousRequest:[OCMArg any] returningResponse:(NSURLResponse * __autoreleasing *)[OCMArg setTo:response] error:(NSError * __autoreleasing *)[OCMArg anyPointer]]);
};

void (^stubSynchronousRequestWithStatusCodeAndURLAndResponseData)(NSUInteger statusCode, NSString *url, NSData *responseData) = ^(NSUInteger statusCode, NSString *url, NSData *responseData)
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url]
                                                              statusCode:statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{}];
    
    id connectionMock = OCMClassMock([NSURLConnection class]);
    OCMStub([connectionMock sendSynchronousRequest:[OCMArg any] returningResponse:(NSURLResponse * __autoreleasing *)[OCMArg setTo:response] error:(NSError * __autoreleasing *)[OCMArg anyPointer]])
    .andReturn(responseData);
};

describe(@"When allocating the client", ^{
    
    __block NSClient *client = nil;
    __block NSString *baseURL = nil;
    
    void (^sendRequestWithEndpointAndCallback)(NSString *endpoint, NSResponseCallback callback) = ^(NSString *endpoint, NSResponseCallback callback)
    {
        [client sendRequestWithEndpoint:endpoint
                         httpMethodType:NSHTTPMethodTypeGet
                            requestType:NSRequestTypeJSON
                             dataObject:nil
                   requestMutationBlock:nil
                            andCallback:callback];
    };
    
    beforeEach(^{
        
        client = [NSClient clientWithScheme:@"http" andHost:@"api.randomuser.me"];
        baseURL = [client urlWithEndpoint:@""].absoluteString;
    });
    
    it(@"the baseURL should be set", ^{
        
        [[client.baseURL.absoluteString should] equal:@"http://api.randomuser.me/"];
    });
    
    describe(@"and firing off a basic request", ^{
        
        __block id responseObject = nil;
        __block NSNumber *statusCode = nil;
        
        beforeEach(^{
            
            stubSynchronousRequestWithStatusCodeAndURLAndResponseData(200, baseURL, [NSJSONSerialization dataWithJSONObject:@{}
                                                                                                                    options:0
                                                                                                                      error:nil]);
            
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
        });
        
        it(@"should return data and a status code", ^{
            
            [[expectFutureValue(responseObject) shouldEventuallyBeforeTimingOutAfter(0.5f)] beNonNil];
            [[expectFutureValue(statusCode) shouldEventuallyBeforeTimingOutAfter(0.5f)] beGreaterThan:@0];
        });
    });
    
    describe(@"when the network is down", ^{
        
        __block id reachabilityMock;
        __block NSError *error;
        __block NSUInteger statusCode;
        __block id responseObject;
        
        beforeEach(^{
            
            reachabilityMock = OCMClassMock([Reachability class]);
            OCMStub([reachabilityMock reachabilityForInternetConnection]).andReturn(reachabilityMock);
            OCMStub([reachabilityMock isReachable]).andReturn(NO);
            
            [client sendRequest:nil withResponseCallback:^(NSUInteger _statusCode, id _responseObject, NSError *_error)
             {
                 statusCode = _statusCode;
                 responseObject = _responseObject;
                 error = _error;
             }];
        });
        
        afterEach(^{
            
            [reachabilityMock stopMocking];
        });
        
        it(@"should callback immediately with an error with the reason 'Could not reach network.'", ^{
            
            [[theValue(statusCode) should] equal:theValue(0)];
            [[responseObject should] beNil];
            [[error should] beNonNil];
            
            [[error.domain should] equal:@"Could not reach network."];
        });
    });
    
    describe(@"and firing a request that gets redirected, but returns a 200 status code - potentially misconfigured firewall", ^{
        
        __block NSNumber *statusCode;
        
        beforeEach(^{
            
            stubSynchronousRequestWithStatusCodeAndURL(200, @"http://not-the-same-url.com");
            
            sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                                               {
                                                   statusCode = @(responseStatusCode);
                                               });
        });
        
        it(@"should set the status code to 303", ^{
            
            [[expectFutureValue(statusCode) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@(303)];
        });
    });
    
    describe(@"and setting an authentication handler that can handle authentication challenges", ^{
        
        __block NSNumber *authenticationBlockCalled;
        
        beforeEach(^{
            
            authenticationBlockCalled = @NO;
            
            [client setAuthenticationFailureHandler:^BOOL (NSUInteger statusCode, id responseObject, NSMutableURLRequest *originalRequest, NSResponseCallback originalCallback, NSError *error)
             {
                 authenticationBlockCalled = @YES;
                 
                 return YES;
             }];
        });
        
        describe(@"when a request returns 401", ^{
            
            __block NSNumber *statusCode;
            __block NSNumber *callbackCalled;
            
            beforeEach(^{
                
                callbackCalled = @NO;
                
                stubSynchronousRequestWithStatusCodeAndURL(401, @"http://someurl.com");
                
                sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                                                   {
                                                       callbackCalled = @YES;
                                                       statusCode = @(responseStatusCode);
                                                   });
            });
            
            it(@"should not call the callback", ^{
                
                [[expectFutureValue(callbackCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@NO];
            });
            
            it(@"should have called the authentication handler", ^{
                
                [[expectFutureValue(authenticationBlockCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@YES];
            });
        });
        
        describe(@"when a request returns 200", ^{
            
            __block NSNumber *statusCode;
            __block NSNumber *callbackCalled;
            
            beforeEach(^{
                
                callbackCalled = @NO;
                
                stubSynchronousRequestWithStatusCodeAndURL(200, baseURL);
                
                sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                                                   {
                                                       callbackCalled = @YES;
                                                       statusCode = @(responseStatusCode);
                                                   });
            });
            
            it(@"should have called the callback", ^{
                
                [[expectFutureValue(callbackCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@YES];
            });
            
            it(@"should not have called the authentication handler", ^{
                
                [[expectFutureValue(authenticationBlockCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@NO];
            });
        });
    });
    
    describe(@"and setting an authentication handler that cannot handle authentication challenges", ^{
        
        __block BOOL authenticationBlockCalled;
        
        beforeEach(^{
            
            authenticationBlockCalled = NO;
            
            [client setAuthenticationFailureHandler:^BOOL (NSUInteger statusCode, id responseObject, NSURLRequest *originalRequest, NSResponseCallback originalCallback, NSError *error)
             {
                 authenticationBlockCalled = YES;
                 
                 return NO;
             }];
        });
        
        describe(@"when a request returns 401", ^{
            
            __block NSUInteger statusCode;
            __block BOOL callbackCalled;
            
            beforeEach(^{
                
                callbackCalled = NO;
                
                stubSynchronousRequestWithStatusCodeAndURL(401, @"http://someurl.com");
                
                sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                                                   {
                                                       callbackCalled = YES;
                                                       statusCode = responseStatusCode;
                                                   });
            });
            
            it(@"should call the callback", ^{
                
                [[expectFutureValue(theValue(callbackCalled)) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:theValue(YES)];
            });
            
            it(@"should have called the authentication handler", ^{
                
                [[expectFutureValue(theValue(authenticationBlockCalled)) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:theValue(YES)];
            });
        });
        
        describe(@"when a request returns 200", ^{
            
            __block NSUInteger statusCode;
            __block BOOL callbackCalled;
            
            beforeEach(^{
                
                callbackCalled = NO;
                
                stubSynchronousRequestWithStatusCodeAndURL(200, baseURL);
                
                sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                                                   {
                                                       callbackCalled = YES;
                                                       statusCode = responseStatusCode;
                                                   });
            });
            
            it(@"should have called the callback", ^{
                
                [[expectFutureValue(theValue(callbackCalled)) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:theValue(YES)];
            });
            
            it(@"should not have called the authentication handler", ^{
                
                [[expectFutureValue(theValue(authenticationBlockCalled)) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:theValue(NO)];
            });
        });
    });
    
    describe(@"when an exception occurs in the request block", ^{
        
        __block NSUInteger statusCode;
        __block BOOL callbackCalled;
        __block NSError *exceptionError;
        
        beforeEach(^{
            
            stubSynchronousRequestWithStatusCodeAndURL(0, @"");
            
            statusCode = 0;
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:client.baseURL];
            
            id urlMock = OCMClassMock([NSURL class]);
            OCMStub([urlMock absoluteString]).andThrow([NSException exceptionWithName:@"Some exception" reason:@"A reason" userInfo:@{}]);
            id requestMock = OCMPartialMock(request);
            OCMStub([requestMock URL]).andReturn(urlMock);
            
            [client sendRequest:request withResponseCallback:^(NSUInteger responseStatusCode, id responseObject, NSError *error)
             {
                 callbackCalled = YES;
                 statusCode = responseStatusCode;
                 exceptionError = error;
             }];
        });
        
        it(@"should return an error and a 400", ^{
            
            [[expectFutureValue(theValue(statusCode)) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:theValue(400)];
            [[expectFutureValue(exceptionError) shouldEventuallyBeforeTimingOutAfter(0.5f)] beNonNil];
        });
    });
    
    describe(@"when sending a multipart POST request", ^{
        
        __block id clientPartialMock;
        __block id requestMock;
        
        beforeEach(^{
            
            requestMock = OCMClassMock([NSMutableURLRequest class]);
            
            clientPartialMock = OCMPartialMock(client);
            
            OCMExpect([clientPartialMock requestWithURL:[OCMArg any] httpMethod:kHTTPMethodPost]).andReturn(requestMock);
            OCMExpect([clientPartialMock dataFromMultipartObject:[OCMArg any]]).andForwardToRealObject();
            OCMExpect([requestMock setValue:[client contentTypeWithRequestType:NSRequestTypeMultipart] forHTTPHeaderField:kContentTypeKey]);
            OCMExpect([requestMock setHTTPBody:[OCMArg any]]);
            OCMExpect([clientPartialMock sendRequest:requestMock withResponseCallback:nil]);
            
            [client sendRequestWithEndpoint:@""
                             httpMethodType:NSHTTPMethodTypePost
                                requestType:NSRequestTypeMultipart
                                 dataObject:@{@"image" : @"not-actually-an-image"}
                       requestMutationBlock:nil
                                andCallback:nil];
        });
        
        it(@"should have created a request with a POST type, set a multipart content type and a valid body", ^{
            
            OCMVerifyAll(clientPartialMock);
            OCMVerifyAll(requestMock);
        });
    });
    
    describe(@"when sending a JSON PUT request", ^{
        
        __block id clientPartialMock;
        __block id requestMock;
        
        beforeEach(^{
            
            requestMock = OCMClassMock([NSMutableURLRequest class]);
            
            clientPartialMock = OCMPartialMock(client);
            
            OCMExpect([clientPartialMock requestWithURL:[OCMArg any] httpMethod:kHTTPMethodPut]).andReturn(requestMock);
            OCMExpect([clientPartialMock dataFromJSONObject:[OCMArg any]]).andForwardToRealObject();
            OCMExpect([requestMock setValue:kContentTypeJSON forHTTPHeaderField:kContentTypeKey]);
            OCMExpect([requestMock setHTTPBody:[OCMArg any]]);
            OCMExpect([clientPartialMock sendRequest:requestMock withResponseCallback:nil]);
            
            [client sendRequestWithEndpoint:@""
                             httpMethodType:NSHTTPMethodTypePut
                                requestType:NSRequestTypeJSON
                                 dataObject:@{@"image" : @"not-actually-an-image"}
                       requestMutationBlock:nil
                                andCallback:nil];
        });
        
        it(@"should have created a request with a PUT type, set a json content type and a valid body", ^{
            
            OCMVerifyAll(clientPartialMock);
            OCMVerifyAll(requestMock);
        });
    });
    
    describe(@"when sending a DELETE request", ^{
        
        __block id clientPartialMock;
        __block id requestMock;
        
        beforeEach(^{
            
            requestMock = OCMClassMock([NSMutableURLRequest class]);
            
            clientPartialMock = OCMPartialMock(client);
            
            [[clientPartialMock reject] dataFromMultipartObject:[OCMArg any]];
            [[clientPartialMock reject] dataFromJSONObject:[OCMArg any]];
            [[requestMock reject] setValue:[OCMArg any] forHTTPHeaderField:[OCMArg any]];
            [[requestMock reject] setHTTPBody:[OCMArg any]];
            OCMExpect([clientPartialMock requestWithURL:[OCMArg any] httpMethod:kHTTPMethodDelete]).andReturn(requestMock);
            OCMExpect([clientPartialMock sendRequest:requestMock withResponseCallback:nil]);
            
            [client sendRequestWithEndpoint:@""
                             httpMethodType:NSHTTPMethodTypeDelete
                                requestType:NSRequestTypeURL
                                 dataObject:nil
                       requestMutationBlock:nil
                                andCallback:nil];
        });
        
        it(@"should have created a request with a DELETE type and not called any extra methods", ^{
            
            OCMVerifyAll(clientPartialMock);
            OCMVerifyAll(requestMock);
        });
    });
    
    describe(@"when sending a request with a mutation block", ^{
        
        __block BOOL mutationBlockCalled;
        __block NSMutableURLRequest *urlRequest;
        __block id clientPartialMock;
        
        beforeEach(^{
            
            mutationBlockCalled = NO;
            
            clientPartialMock = OCMPartialMock(client);
            OCMExpect([clientPartialMock sendRequest:[OCMArg any] withResponseCallback:nil]);
            
            [client sendRequestWithEndpoint:@""
                             httpMethodType:NSHTTPMethodTypeGet
                                requestType:NSRequestTypeURL
                                 dataObject:nil
                       requestMutationBlock:^(NSMutableURLRequest *request)
             {
                 mutationBlockCalled = YES;
                 urlRequest = request;
             }
                                andCallback:nil];
        });
        
        it(@"should call the mutation block with a valid request", ^{
            
            [[theValue(mutationBlockCalled) should] equal:theValue(YES)];
            [[theValue([urlRequest isKindOfClass:[NSMutableURLRequest class]]) should] equal:theValue(YES)];
        });
    });
});

describe(@"when creating a client with a base path", ^{
    
    __block NSClient *subject;
    
    beforeEach(^{
        
        subject = [NSClient clientWithBaseURL:[[NSURL alloc] initWithScheme:@"http" host:@"google.ca" path:@"/api"]];
    });
    
    it(@"should have the correct baseURL", ^{
        
        [[subject.baseURL.absoluteString should] equal:@"http://google.ca/api/"];
    });
});

SPEC_END