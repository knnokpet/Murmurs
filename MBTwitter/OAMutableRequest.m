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
#import "OARequestparameter.h"
#import "OAHMAC-SHA1SignatureProvider.h"
#import "NSString+OAURLEncodingAdditions.h"
#import "NSURL+SignatureBased.h"

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
- (void)prepareRequest
{
    // configure secret
    NSString *consumerSecret = [self.consumer.secret encodedString];
    NSString *tokenSecret = [self.token.secret encodedString];
    NSString *secretForSignature = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret];
    
    // configure signature
    NSString *signatureBasedString = [self signatureBasedString];
    _signature = [self.signatureProvider signatureText:signatureBasedString secret:secretForSignature];

    // if exist token
    NSString *oauthTokenString;
    if (YES == [self.token.key isEqualToString:@""]) {
        oauthTokenString = @"";
    } else {
        oauthTokenString = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [self encodedString:self.token.key]];
    }
    
    // configure oauthHeader
    NSString *oauthRealm = [self.realm encodedString];
    NSString *oauthConsumerKey = [self.consumer.key encodedString];
    NSString *oauthNonce = [self.nonce encodedString];
    NSString *oauthSignature = [self.signature encodedString];
    NSString *oauthSignatureMethod = [[self.signatureProvider name] encodedString];
    NSString *oauthTimeStamp = [self.timeStamp encodedString];
    NSString *oauthVersion = [OAUTH_VERSION encodedString];
    /*
    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", %@oauth_version=\"%@\"",
                             oauthRealm,
                             oauthConsumerKey,
                             oauthNonce,
                             oauthSignature,
                             oauthSignatureMethod,
                             oauthTimeStamp,
                             oauthTokenString,
                             oauthVersion];*/
    //NSLog(@"consumerKey = %@", oauthConsumerKey);
    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", %@oauth_version=\"%@\"",
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

- (NSString *)signatureBasedString
{
    int defaultParameteCount = 7;
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:( defaultParameteCount + [self.parameters count])];
    
    // require Parameters
    [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_consumer_key" value:self.consumer.key] encodedNameValuePair]];
    [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_nonce" value:self.nonce] encodedNameValuePair]];
    [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_signature_method" value:[self.signatureProvider name]] encodedNameValuePair]];
    [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_timestamp" value:self.timeStamp] encodedNameValuePair]];
    [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_version" value:OAUTH_VERSION] encodedNameValuePair]];
    
    // use pin_based authenication
    if (self.token.key.length > 0) {
        [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_token" value:self.token.key] encodedNameValuePair]];
        [parameters addObject:[[OARequestparameter requestParameterWithName:@"oauth_verifier" value:self.token.pin] encodedNameValuePair]];
    }
    
    // join require & option parameter
    for (OARequestparameter *parameter in self.parameters) {
        [parameters addObject:[parameter encodedNameValuePair]];
    }
    
    // configure normalized Parameter String
    NSArray *sortedParameters = [parameters sortedArrayUsingSelector:@selector(compare:)];
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
    
    if (YES == [[self HTTPMethod] isEqualToString:@"GET"] || YES == [[self HTTPMethod] isEqualToString:@"DELETE"]) {
        encodedParameters = [[self URL] query];
        
    } else { // POST, PUT
        encodedParameters = [[NSString alloc] initWithData:[self HTTPBody] encoding:NSASCIIStringEncoding];
    }
    
    if (encodedParameters == nil || YES == [encodedParameters isEqualToString:@""]) {
        return nil;
    }
    
    NSArray *encodedParameterPair = [encodedParameters componentsSeparatedByString:@"&"];
    NSMutableArray *requestParameters = [NSMutableArray arrayWithCapacity:16];
    for (NSString *pair in encodedParameterPair) {
        NSArray *separatedPair = [pair componentsSeparatedByString:@"="];
        OARequestparameter *requestParameter = [OARequestparameter requestParameterWithName:[[separatedPair objectAtIndex:0] encodedString] value:[[separatedPair objectAtIndex:1] encodedString]];
        
        [requestParameters addObject:requestParameter];
    }
    
    return requestParameters;
}

- (void)setParameters:(NSArray *)parameters
{
    NSMutableString *parameterString = [NSMutableString stringWithCapacity:256];
    
    // configure parameter String
    int appendPosition = 1;
    for (OARequestparameter *param in parameters) {
        NSString *nameValuePair = [param encodedNameValuePair];
        [parameterString appendString:nameValuePair];
        if (appendPosition < [parameters count]) {
            [parameterString appendString:@"&"];
        }
        appendPosition++;
    }

    // add Parameter. Separate for each HTTPMEthod
    if (YES == [[self HTTPMethod] isEqualToString:@"GET"] || YES == [[self HTTPMethod] isEqualToString:@"DELETE"]) {
        NSString *quaryURL = [NSString stringWithFormat:@"%@?%@", [[self URL] URLStringWithoutQuery], parameterString];
        [self setURL:[NSURL URLWithString:quaryURL]];
        
    } else { // POST, PUT
        NSData *parameterData = [parameterString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        if (parameterData == nil) {
            
        }
        [self setHTTPBody:parameterData];
        [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[parameterData length]] forHTTPHeaderField:@"Content-Length"];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //[self setValue:@"client_credentials" forHTTPHeaderField:@"grant_type"];
        
    }
    
}

- (NSString *)encodedString:(NSString *)string
{
    // remove space and encode
    return [[string decodedString] encodedString];
}

@end
