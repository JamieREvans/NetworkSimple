//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "Kiwi.h"
#import "NSClient+Parsing.h"

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

SPEC_END