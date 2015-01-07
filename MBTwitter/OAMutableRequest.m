//
//  OAMutableRequest.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OAMutableRequest.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAParameter.h"
#import "OAHMAC-SHA1SignatureProvider.h"
#import "NSString+OAURLEncodingAdditions.h"
#import "NSURL+SignatureBased.h"

#import "NSString+UUID.h"

#define OAUTH_VERSION @"1.0"

@implementation OAMutableRequest
#pragma mark - init
- (id)initWithURL:(NSURL *)URL consumer:(OAConsumer *)consumer token:(OAToken *)token realm:(NSString *)realm signatureProvider:(id<OASignatureProvider>)signatureProvider
{
    self = [super initWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    if (self) {
        _consumer = consumer;
        
        if (token != nil) {
            _token = token;
        } else {
            _token = [[OAToken alloc] init];
        }
        
        if (realm != nil) {
            _realm = realm;
        } else {
            _realm = @"";
        }
        
        if (signatureProvider != nil) {
            self.signatureProvider = signatureProvider;
        } else {
            self.signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
        }
        
        [self generateTimeStamp];
        [self generateNonce];
        
    }
    
    return self;
}

#pragma mark -
#pragma mark global
- (void)configureOAuthHeader
{
    // if exist token
    NSString *oauthTokenString;
    if ([self.token.key isEqualToString:@""]) {
        oauthTokenString = @"";
    } else {
        oauthTokenString = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [self encodedString:self.token.key]];
    }
    
    NSString *oauthRealm = [self.realm encodedString];
    NSString *oauthConsumerKey = [self.consumer.key encodedString];
    NSString *oauthNonce = [self.nonce encodedString];
    NSString *oauthSignature = [self.signature encodedString];
    NSString *oauthSignatureMethod = [[self.signatureProvider name] encodedString];
    NSString *oauthTimeStamp = [self.timeStamp encodedString];
    NSString *oauthVersion = [OAUTH_VERSION encodedString];
    
    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", %@oauth_version=\"%@\"",
                             oauthRealm,
                             oauthConsumerKey,
                             oauthNonce,
                             oauthSignature,
                             oauthSignatureMethod,
                             oauthTimeStamp,
                             oauthTokenString,
                             oauthVersion];
    
    if (self.token.pin.length > 0) {
        NSString *oauthPinAuth = [NSString stringWithFormat:@", oauth_verifier=\"%@\"", self.token.pin];
        oauthHeader = [oauthHeader stringByAppendingString:oauthPinAuth];
    }
    [self setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}

- (void)prepareOAuthRequest
{
    // configure secret
    NSString *consumerSecret = [self.consumer.secret encodedString];
    NSString *tokenSecret = [self.token.secret encodedString];
    NSString *secretForSignature = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret];
    
    // configure signature
    NSString *signatureBasedString = [self signatureBasedStringWithParameters:self.parameters];
    _signature = [self.signatureProvider hmacsha1:signatureBasedString secret:secretForSignature];

    [self configureOAuthHeader];
}


- (void)prepareRequest
{
    // configure secret
    NSString *consumerSecret = [self.consumer.secret encodedString];
    NSString *tokenSecret = [self.token.secret encodedString];
    NSString *secretForSignature = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret];
    
    // configure signature
    NSString *signatureBasedString = ([[self HTTPMethod] isEqualToString:@"GET"]) ? [self signatureBasedStringWithParameters:self.parameters] : [self signatureBasedStringForOAuthOnly];
    _signature = [self.signatureProvider hmacsha1:signatureBasedString secret:secretForSignature];

    [self configureOAuthHeader];
}


#pragma mark - 
#pragma mark private
- (void)generateTimeStamp
{
    _timeStamp = [NSString stringWithFormat:@"%ld", time(NULL)];
}

- (void)generateNonce
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    _nonce = (__bridge NSString *)uuidStringRef;
}

- (NSString *)signatureBasedStringForOAuthOnly
{
    return [self signatureBasedStringWithParameters:nil];
}

- (NSString *)signatureBasedStringWithParameters:(NSArray *)parameters
{
    int defaultParameteCount = 7;
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:( defaultParameteCount + [parameters count])];
    
    // require Parameters
    [params addObject:[[OAParameter requestParameterWithName:@"oauth_consumer_key" value:self.consumer.key] encodedNameValuePair]];
    [params addObject:[[OAParameter requestParameterWithName:@"oauth_nonce" value:self.nonce] encodedNameValuePair]];
    [params addObject:[[OAParameter requestParameterWithName:@"oauth_signature_method" value:[self.signatureProvider name]] encodedNameValuePair]];
    [params addObject:[[OAParameter requestParameterWithName:@"oauth_timestamp" value:self.timeStamp] encodedNameValuePair]];
    [params addObject:[[OAParameter requestParameterWithName:@"oauth_version" value:OAUTH_VERSION] encodedNameValuePair]];
    
    // use pin_based authenication
    if (self.token.key.length > 0) {
        [params addObject:[[OAParameter requestParameterWithName:@"oauth_token" value:self.token.key] encodedNameValuePair]];
        if (self.token.pin.length > 0) {
            [params addObject:[[OAParameter requestParameterWithName:@"oauth_verifier" value:self.token.pin] encodedNameValuePair]];
        }
    }
    
    // join require & option parameter
    for (OAParameter *parameter in parameters) {
        [params addObject:[parameter encodedNameValuePair]];
    }
    
    // configure normalized Parameter String
    NSArray *sortedParameters = [params sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedParametersString = [sortedParameters componentsJoinedByString:@"&"];
    
    // configure signature based string
    NSString *httpMethod = [self HTTPMethod];
    NSString *signatureBasedURL = [self encodedString:[[self URL] URLStringWithoutQuery]];
    NSString *signatureBasedParameter = [self encodedString:normalizedParametersString];
    NSString *signatureBasedString = [NSString stringWithFormat:@"%@&%@&%@", httpMethod, signatureBasedURL, signatureBasedParameter];
    
    return signatureBasedString;
}

- (NSArray *)parameters
{
    NSString *encodedParameters;
    
    if ([[self HTTPMethod] isEqualToString:@"GET"] || [[self HTTPMethod] isEqualToString:@"DELETE"]) {
        encodedParameters = [[self URL] query];
        
    } else { // POST, PUT
        encodedParameters = [[NSString alloc] initWithData:[self HTTPBody] encoding:NSUTF8StringEncoding];
    }
    
    if (encodedParameters == nil || [encodedParameters isEqualToString:@""]) {
        return nil;
    }
    
    NSArray *encodedParameterPair = [encodedParameters componentsSeparatedByString:@"&"];
    NSMutableArray *requestParameters = [NSMutableArray arrayWithCapacity:16];
    for (NSString *pair in encodedParameterPair) {
        NSArray *separatedPair = [pair componentsSeparatedByString:@"="];
        OAParameter *requestParameter = [OAParameter requestParameterWithName:[separatedPair objectAtIndex:0] value:[separatedPair objectAtIndex:1]];
        [requestParameters addObject:requestParameter];
    }
    
    return requestParameters;
}

- (void)setParameters:(NSArray *)parameters
{
    NSMutableString *parameterString = [NSMutableString stringWithCapacity:256];
    
    // configure parameter String
    int appendPosition = 1;
    for (OAParameter *param in parameters) {
        NSString *nameValuePair = [param encodedNameValuePair];
        [parameterString appendString:nameValuePair];
        if (appendPosition < [parameters count]) {
            [parameterString appendString:@"&"];
        }
        appendPosition++;
    }

    // add Parameter. Separate for each HTTPMethod
    if ([[self HTTPMethod] isEqualToString:@"GET"] || [[self HTTPMethod] isEqualToString:@"DELETE"]) {
        NSString *quaryURL = [NSString stringWithFormat:@"%@?%@", [[self URL] URLStringWithoutQuery], parameterString];
        [self setURL:[NSURL URLWithString:quaryURL]];
        
    } else { // POST, PUT
        NSData *parameterData = [parameterString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        if (parameterData == nil) {
            
        }
        [self setHTTPBody:parameterData];
        [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[parameterData length]] forHTTPHeaderField:@"Content-Length"];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //[self setValue:@"client_credentials" forHTTPHeaderField:@"grant_type"];
        
    }
    
}

- (void)setMultiPartPostParameters:(NSDictionary *)parameters
{
    NSString *boundary = [NSString stringWithNewUUID];
    NSData *paramData = [self postBodyWithParameter:parameters boundary:boundary];
    
    [self setValue:@(paramData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:paramData];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [self setValue:contentType forHTTPHeaderField:@"Content-Type"];
}

- (NSData *)postBodyWithParameter:(NSDictionary *)param boundary:(NSString *)boundary
{
    NSMutableData *body = [NSMutableData dataWithLength:0];
    for (NSString *key in param.allKeys) {
        
        id obj = param[key];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *paramData = nil;
        if ([obj isKindOfClass:[NSData class]]) {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"hoge.png\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: base64\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            paramData = (NSData *)obj;
        } else if ([obj isKindOfClass:[NSString class]]) {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            paramData = [[NSString stringWithFormat:@"%@", (NSString *)obj] dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:paramData];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

- (NSString *)encodedString:(NSString *)string
{
    // remove space and encode
    return [[string decodedString] encodedString];
}

@end
