//
//  NSClient+Parsing.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "NSClient+Parsing.h"
#import "NSJSONSerialization+RemovingNulls.h"

const NSString *lineBreakString = @"\r\n";

const NSString * kContentDispositionKey = @"Content-Disposition";

#if TARGET_OS_IPHONE
#define IMAGE_CLASS [UIImage class]
#elif TARGET_OS_MAC
#define IMAGE_CLASS [NSImage class]
#endif

@implementation NSClient (Parsing)

#pragma mark - To Data -

+ (NSData *)dataFromString:(NSString *)string
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)dataFromJSONObject:(id)jsonObject
{
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
}

- (NSData *)dataFromMultipartObject:(NSDictionary *)mulitpartObject
{
    NSString *boundaryString = [NSString stringWithFormat:@"--%@%@", [self boundaryString], lineBreakString];
    
    NSMutableData *multipartData = [NSMutableData new];
    for(NSString *key in mulitpartObject.allKeys)
    {
        NSObject *object = mulitpartObject[key];
        
        // Initial boundary data - DRY!
        [multipartData appendData:[[self class] dataFromString:boundaryString]];
        
        NSMutableString *multipartString = [NSMutableString new];
        if([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]])
        {
            [multipartString appendFormat:@"%@: form-data; name=\"%@\";%@", kContentDispositionKey, key, lineBreakString];
            [multipartString appendFormat:@"%@: text/plain%@%@", kContentTypeKey, lineBreakString, lineBreakString];
            [multipartString appendFormat:@"%@%@", object, lineBreakString];
            [multipartData appendData:[[self class] dataFromString:multipartString]];
        }
        else if([object isKindOfClass:IMAGE_CLASS])
        {
            [multipartString appendFormat:@"%@: form-data; name=\"%@\"; filename=\"webshare.jpg\"%@", kContentDispositionKey, key, lineBreakString];
            [multipartString appendFormat:@"%@: image/jpeg%@%@", kContentTypeKey, lineBreakString, lineBreakString];
            [multipartData appendData:[[self class] dataFromString:multipartString]];
            
#if TARGET_OS_IPHONE
            [multipartData appendData:UIImageJPEGRepresentation((UIImage *)object, 1.0f)];
#elif TARGET_OS_MAC
            [multipartData appendData:[(NSImage *)object TIFFRepresentation]];
#endif
            
            [multipartData appendData:[[self class] dataFromString:lineBreakString.copy]];
        }
        else if([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]])
        {
            [multipartString appendFormat:@"%@: form-data; name=\"%@\";%@", kContentDispositionKey, key, lineBreakString];
            [multipartString appendFormat:@"%@: %@%@%@", kContentTypeKey, kContentTypeJSON, lineBreakString, lineBreakString];
            [multipartString appendFormat:@"%@%@", [[NSString alloc] initWithData:[[self class] dataFromJSONObject:object] encoding:NSUTF8StringEncoding], lineBreakString];
            [multipartData appendData:[[self class] dataFromString:multipartString]];
        }
    }
    
    [multipartData appendData:[[self class] dataFromString:[NSString stringWithFormat:@"--%@--%@", self.boundaryString, lineBreakString]]];
    
    return multipartData;
}

- (NSData *)dataFromObject:(id <NSObject>)object withRequestType:(NSRequestType)requestType
{
    switch(requestType)
    {
        case NSRequestTypeData:      return (NSData *)object;
        case NSRequestTypeJSON:      return [[self class] dataFromJSONObject:object];
        case NSRequestTypeMultipart: return [self dataFromMultipartObject:(NSDictionary *)object];
        default:                     return nil;
    }
}

#pragma mark - From Data -

+ (NSString *)stringFromParameters:(NSDictionary *)parameters
{
    NSMutableString *parameterString = [NSMutableString new];
    
    for(NSString *key in parameters.allKeys)
    {
        NSObject *object = parameters[key];
        
        // We only want to add NSString or NSNumber objects to the string
        if([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]])
        {
            [parameterString appendFormat:@"%@%@=%@", (parameterString.length ? @"&" : @"?"), key, object];
        }
    }
    
    return parameterString.copy;
}

+ (id)jsonObjectFromData:(NSData *)data
{
    return (!data ? nil :
            ([NSJSONSerialization JSONObjectWithData:data options:0 error:nil removingNulls:YES ignoreArrays:NO] ? :
             [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]));
}

@end
