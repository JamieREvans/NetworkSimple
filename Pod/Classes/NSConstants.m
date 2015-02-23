//
//  NSConstants.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#ifndef NetworkSimple_NSConstants_m
#define NetworkSimple_NSConstants_m

NSString * const kContentLengthKey = @"Content-Length";
NSString * const kContentTypeKey   = @"Content-Type";

NSString * const kHTTPMethodGet    = @"GET";
NSString * const kHTTPMethodPost   = @"POST";
NSString * const kHTTPMethodPut    = @"PUT";
NSString * const kHTTPMethodDelete = @"DELETE";

NSString * const kContentTypeData      = @"x-www-form-urlencoded";
NSString * const kContentTypeJSON      = @"application/json";
NSString * const kContentTypeMultipart = @"multipart/form-data";

NSString * const kResponseHeadersKey          = @"kResponseHeadersDictionaryKey";
NSString * const kResponseHeadersNotification = @"kNewResponseHeadersNotification";

#endif
