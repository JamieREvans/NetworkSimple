//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "Kiwi.h"
#import "OCMock.h"
#import "NSClient+Parsing.h"
#import <UIKit/UIKit.h>

#define SAMPLE_STRING @"Sample String"
#define SAMPLE_NUMBER @123

SPEC_BEGIN(NSClientParsingSpec)

describe(@"When parsing JSON", ^
{
    __block NSDictionary *dataDictionary = @{@"first_key" : @"first_value",
                                             @"array_key" : @[@1, @2, @3]};
    
    it(@"the data should be valid", ^
       {
           [[[NSClient dataFromJSONObject:dataDictionary] should] beKindOfClass:[NSData class]];
       });
    
    it(@"the object should be a dictionary / json object", ^
       {
           [[[NSClient jsonObjectFromData:[NSClient dataFromJSONObject:dataDictionary]] should] beKindOfClass:[NSDictionary class]];
       });
    
    describe(@"and I pass string data", ^
             {
                 it(@"the returned object should be a string", ^
                    {
                        [[[NSClient jsonObjectFromData:[NSClient dataFromString:@"Not a json object"]] should] beKindOfClass:[NSString class]];
                    });
             });
    
    describe(@"and I pass invalid JSON object", ^
             {
                 it(@"the returned object should be a string", ^
                    {
                        [[[NSClient jsonObjectFromData:[NSClient dataFromString:@"{ \"object\" = \"value\"}}"]] should] beKindOfClass:[NSString class]];
                    });
             });
});

describe(@"When parsing parameters", ^
{
    it(@"the returned string should equal '?results=20&seed=NS'", ^
       {
           NSDictionary *parameters = @{@"results" : @"20",
                                        @"seed"    : @"NS"};
           
           [[[NSClient stringFromParameters:parameters] should] equal:@"?results=20&seed=NS"];
       });
});

describe(@"when parsing multipart", ^{
    
    __block NSData *multipartData;
    
    describe(@"with an image", ^{
        
        beforeEach(^{
            
            multipartData = [[NSClient new] dataFromMultipartObject:@{@"image" : [UIImage imageNamed:@"sample"]}];
        });
        
        it(@"should return valid data", ^{
            
            [[theValue(multipartData.length) shouldNot] equal:0.0f withDelta:FLT_EPSILON];
        });
        
        it(@"should not be able to be parsed to a string", ^{
            
            NSString *multipartString = [[NSString alloc] initWithData:multipartData encoding:NSUTF8StringEncoding];
            [[multipartString should] beNil];
        });
    });
    
    describe(@"with a string and number", ^{
        
        __block NSString *multipartString;
        
        beforeEach(^{
            
            multipartData = [[NSClient new] dataFromMultipartObject:@{@"string" : SAMPLE_STRING,
                                                                      @"number" : SAMPLE_NUMBER}];
            multipartString = [[NSString alloc] initWithData:multipartData encoding:NSUTF8StringEncoding];
        });
        
        it(@"should return valid data", ^{
            
            [[theValue(multipartData.length) shouldNot] equal:0];
        });
        
        it(@"should not be able to be parsed to a string", ^{
            
            [[multipartString shouldNot] beNil];
            [[theValue(multipartString.length) shouldNot] equal:theValue(0)];
        });
        
        it(@"should have the string, and it's name in the multipart", ^{
            
            NSRange stringRange = [multipartString rangeOfString:SAMPLE_STRING];
            NSRange nameRange = [multipartString rangeOfString:@"string"];
            
            [[theValue(stringRange.location) shouldNot] equal:theValue(NSNotFound)];
            [[theValue(nameRange.location) shouldNot] equal:theValue(NSNotFound)];
            
            [[theValue(stringRange.length) should] equal:theValue([SAMPLE_STRING length])];
            [[theValue(nameRange.length) should] equal:theValue(6)];
        });
        
        it(@"should have the number, and it's name in the multipart", ^{
            
            NSRange numberRange = [multipartString rangeOfString:[SAMPLE_NUMBER stringValue]];
            NSRange nameRange = [multipartString rangeOfString:@"number"];
            
            [[theValue(numberRange.location) shouldNot] equal:theValue(NSNotFound)];
            [[theValue(nameRange.location) shouldNot] equal:theValue(NSNotFound)];
            
            [[theValue(numberRange.length) should] equal:theValue([[SAMPLE_NUMBER stringValue] length])];
            [[theValue(nameRange.length) should] equal:theValue(6)];
        });
    });
    
    describe(@"with a dictionary and array", ^{
        
        __block NSString *multipartString;
        __block id clientMock;
        
        beforeEach(^{
            
            clientMock = OCMClassMock([NSClient class]);
            [[[clientMock expect] andForwardToRealObject] dataFromJSONObject:[OCMArg checkWithBlock:^BOOL(id obj){return [obj isKindOfClass:[NSArray class]];}]];
            [[[clientMock expect] andForwardToRealObject] dataFromJSONObject:[OCMArg checkWithBlock:^BOOL(id obj){return [obj isKindOfClass:[NSDictionary class]];}]];
            
            multipartData = [[NSClient new] dataFromMultipartObject:@{@"dictionary" : @{@"string" : SAMPLE_STRING,
                                                                                        @"number" : SAMPLE_NUMBER},
                                                                      @"array"      : @[SAMPLE_STRING,
                                                                                        SAMPLE_NUMBER]}];
            multipartString = [[NSString alloc] initWithData:multipartData encoding:NSUTF8StringEncoding];
        });
        
        afterEach(^{
            
            [clientMock stopMocking];
        });
        
        it(@"should return valid data", ^{
            
            [[theValue(multipartData.length) shouldNot] equal:0];
        });
        
        it(@"should not be able to be parsed to a string", ^{
            
            [[multipartString shouldNot] beNil];
            [[theValue(multipartString.length) shouldNot] equal:theValue(0)];
        });
        
        it(@"should have the string, and it's name in the multipart", ^{
            
            NSRange stringRange = [multipartString rangeOfString:SAMPLE_STRING];
            NSRange nameRange = [multipartString rangeOfString:@"string"];
            
            [[theValue(stringRange.location) shouldNot] equal:theValue(NSNotFound)];
            [[theValue(nameRange.location) shouldNot] equal:theValue(NSNotFound)];
            
            [[theValue(stringRange.length) should] equal:theValue([SAMPLE_STRING length])];
            [[theValue(nameRange.length) should] equal:theValue(6)];
        });
        
        it(@"should have the number, and it's name in the multipart", ^{
            
            NSRange numberRange = [multipartString rangeOfString:[SAMPLE_NUMBER stringValue]];
            NSRange nameRange = [multipartString rangeOfString:@"number"];
            
            [[theValue(numberRange.location) shouldNot] equal:theValue(NSNotFound)];
            [[theValue(nameRange.location) shouldNot] equal:theValue(NSNotFound)];
            
            [[theValue(numberRange.length) should] equal:theValue([[SAMPLE_NUMBER stringValue] length])];
            [[theValue(nameRange.length) should] equal:theValue(6)];
        });
        
        it(@"should have the array and dictionary names", ^{
            
            NSRange arrayNameRange = [multipartString rangeOfString:@"array"];
            NSRange dictionaryNameRange = [multipartString rangeOfString:@"dictionary"];
            
            [[theValue(arrayNameRange.location) shouldNot] equal:theValue(NSNotFound)];
            [[theValue(dictionaryNameRange.location) shouldNot] equal:theValue(NSNotFound)];
            
            [[theValue(arrayNameRange.length) should] equal:theValue(5)];
            [[theValue(dictionaryNameRange.length) should] equal:theValue(10)];
        });
        
        it(@"should have called dataFromJSONObject: with the dictionary and with the array", ^{
         
            OCMVerifyAll(clientMock);
        });
    });
});

describe(@"Parsing data", ^{
    
    __block NSClient *client;
    __block id clientPartialMock;
    __block id objectToParse;
    
    beforeEach(^{
        
        client = [NSClient clientWithScheme:@"" andHost:@""];
        clientPartialMock = OCMPartialMock(client);
        objectToParse = OCMClassMock([NSObject class]);
    });
    
    describe(@"when parsing json", ^{
        
        beforeEach(^{
            
            OCMExpect([clientPartialMock dataFromJSONObject:objectToParse]);
            
            [client dataFromObject:objectToParse withRequestType:NSRequestTypeJSON];
        });
        
        it(@"should do something", ^{
            
            OCMVerifyAll(clientPartialMock);
        });
    });
    
    describe(@"when parsing multipart", ^{
        
        beforeEach(^{
            
            OCMExpect([clientPartialMock dataFromMultipartObject:objectToParse]);
            
            [client dataFromObject:objectToParse withRequestType:NSRequestTypeMultipart];
        });
        
        it(@"should have called dataFromMultipartObject:", ^{
            
            OCMVerifyAll(clientPartialMock);
        });
    });
    
    describe(@"when parsing raw data", ^{
        
        __block id returnValue;
        
        beforeEach(^{
            
            returnValue = [client dataFromObject:objectToParse withRequestType:NSRequestTypeData];
        });
        
        it(@"should return the data object exactly as is", ^{
            
            [[returnValue should] equal:objectToParse];
        });
    });
    
    describe(@"when passed an invalid request type", ^{
        
        __block id returnValue;
        
        beforeEach(^{
            
            returnValue = [client dataFromObject:objectToParse withRequestType:5];
        });
        
        it(@"should return nil", ^{
            
            [[returnValue should] beNil];
        });
    });
});

SPEC_END