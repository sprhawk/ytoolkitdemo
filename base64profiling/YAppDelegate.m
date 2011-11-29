//Copyright 2011 Hongbo YANG (hongbo@yang.me). All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are
//permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of
//conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list
//of conditions and the following disclaimer in the documentation and/or other materials
//provided with the distribution.
//
//THIS SOFTWARE IS PROVIDED BY Hongbo YANG ''AS IS'' AND ANY EXPRESS OR IMPLIED
//WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
//CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//The views and conclusions contained in the software and documentation are those of the
//authors and should not be interpreted as representing official policies, either expressed
//or implied, of Hongbo YANG.


#import "YAppDelegate.h"


#import "base64.h"
#import "cdecode.h"
#import "cencode.h"

#import <ytoolkit/ybase64.h>


#import "NSData+Base64.h"
#import <ytoolkit/NSData+YBase64String.h>
#import <ytoolkit/NSString+YBase64toData.h>
#import <ytoolkit/ytiming.h>
#import <ytoolkit/ymacros.h>

#import <CommonCrypto/CommonDigest.h>

extern void compareToNSDataAddition(void);
extern void compareToGNUImp(void);
void compareToLibb64Imp(void);

@implementation YAppDelegate

@synthesize window = _window;
- (void)profilingThread:(id)arg {
    @autoreleasepool {
        [NSThread sleepForTimeInterval:1];
        NSLog(@"compareToLibb64Imp");
        compareToLibb64Imp();
        NSLog(@"compareToLibb64Imp");
        compareToGNUImp();
        NSLog(@"compareToLibb64Imp");
        compareToNSDataAddition();
        NSLog(@"end");
    }
}
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [NSThread detachNewThreadSelector:@selector(profilingThread:) toTarget:self withObject:nil];
    return YES;
}

@end


void compareToLibb64Imp() {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"png"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    const void * pdata = data.bytes;
    const size_t len = data.length;
    
    {
        void * outData1 = malloc(len * 2);
        size_t outLen1 = len * 2;
        YTIMING(50, 
               base64_encodestate _state;
               base64_init_encodestate(&_state);
               outLen1 = base64_encode_block(pdata, len, outData1, &_state);
               outLen1 += base64_encode_blockend(outData1, &_state);
               base64_init_encodestate(&_state);,
               "Libb64 Imp encode (data size:%d)", (int)len)
        free(outData1);
        outData1 = NULL;
    }
    
    {
        size_t l = ybase64_encode(pdata, len, NULL, 0);
        void * outData2 = malloc(l);
        YTIMING(50, 
               ybase64_encode(pdata, len, NULL, 0);
               l = ybase64_encode(pdata, len, outData2, l);,
               "__oauth Imp encode (data size:%d)", (int)len)
        
        free(outData2);
        outData2 = NULL;
    }
    void * outData1 = malloc(len * 2);
    size_t outLen1 = len * 2;
    memset(outData1, 0, outLen1);
    base64_encodestate _enstate;
    base64_init_encodestate(&_enstate);
    outLen1 = base64_encode_block(pdata, len, outData1, &_enstate);
    outLen1 += base64_encode_blockend(outData1, &_enstate);
    base64_init_encodestate(&_enstate);
    free(outData1);
    outData1 = NULL;
    
    size_t outLen2 = ybase64_encode(pdata, len, NULL, 0);
    void * outData2 = malloc(outLen2);
    size_t l = ybase64_encode(pdata, len, outData2, outLen2);
    
    //    assert(l == outLen1);
    //    assert(0 == memcmp(outData2, outData1, l));
    
    void * referenceData = outData2;
    size_t referenceLen = outLen2;
    outData2 = NULL;
    {
        void * outData1 = malloc(len * 2);
        size_t outLen1 = len * 2;
        YTIMING(50, 
               base64_decodestate _state;
               base64_init_decodestate(&_state);
               size_t l = strlen(referenceData);
               outLen1 = base64_decode_block(referenceData, l, outData1, &_state);
               base64_init_decodestate(&_state);,
               "Libb64 Imp decode (data size:%d)", (int)l)
        
        free(outData1);
    }
    {
        size_t l = strlen(referenceData);
        size_t outLen2 = ybase64_decode(referenceData, l, NULL, 0);
        void * outData2 = malloc(outLen2);
        YTIMING(50, 
               ybase64_decode(referenceData, l, NULL, 0);
               ybase64_decode(referenceData, l, outData2, outLen2);,
               "__oauth Imp decode (data size:%d)", l)
        
        free(outData2);
    }
    
    outData1 = malloc(len * 2);
    outLen1 = len * 2;
    memset(outData1, 0, outLen1);
    base64_decodestate _decodestate;
    base64_init_decodestate(&_decodestate);
    outLen1 = base64_decode_block(referenceData, len, outData1, &_decodestate);
    base64_init_decodestate(&_decodestate);
    free(outData1);
    outData1 = NULL;
    
    l = strlen(referenceData);
    outLen2 = ybase64_decode(referenceData, l, NULL, 0);
    outData2 = malloc(outLen2);
    l = ybase64_decode(referenceData, l, outData2, outLen2);
    
    //    assert(outLen1 == outLen2);
    //    assert(0 == memcmp(outData1, outData2, outLen2));
    
    free(outData2);
    free(referenceData);
    outData2 = NULL;
    referenceData = NULL;    
}

void compareToGNUImp() {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"png"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    const void * pdata = data.bytes;
    const size_t len = data.length;
    {
        size_t outLen1 = len * 2;
        void * outData1 = malloc(outLen1);
        YTIMING(50, 
               base64_encode(pdata, len, outData1, outLen1);,
               "GNU Imp encode (data size:%d)", (int)len)
        free(outData1);
    }
    
    {
        size_t l = ybase64_encode(pdata, len, NULL, 0);
        void * outData2 = malloc(l);
        YTIMING(50, 
               ybase64_encode(pdata, len, NULL, 0);
               l = ybase64_encode(pdata, len, outData2, l);,
               "__oauth Imp encode (data size:%d)", (int)len)
        free(outData2);
    }
    
    
    void * outData1 = NULL;
    size_t outLen1 = 0;
    outLen1 = base64_encode_alloc(pdata, len, (char **)&outData1);
    
    size_t outLen2 = ybase64_encode(pdata, len, NULL, 0);
    void * outData2 = malloc(outLen2);
    size_t l = ybase64_encode(pdata, len, outData2, outLen2);
    
    assert(l == outLen1 + 1);
    assert(0 == memcmp(outData2, outData1, l));
    free(outData2);
    outData2 = NULL;
    
    void * referenceData = outData1;
    size_t referenceLen = outLen1;
    outData1 = NULL;
    
    {
        size_t l = strlen(referenceData);
        size_t outLen1 = l;
        void * outData1 = malloc(l);
        YTIMING(50, 
               base64_decode(referenceData, l, outData1, &outLen1);,
               "GNU Imp decode(data size:%d)", (int)l)
        free(outData1);
    }
    
    {
        size_t l = strlen(referenceData);
        size_t outLen2 = ybase64_decode(referenceData, l, NULL, 0);
        void * outData2 = malloc(outLen2);
        YTIMING(50, 
               ybase64_decode(referenceData, l, outData2, outLen2);,
               "__oauth Imp decode (data size:%d)", (int)referenceLen)
        free(outData2);
    }
    
    outLen1 = 0;
    l = strlen(referenceData);
    base64_decode_alloc(referenceData, l, (char **)&outData1, &outLen1);
    outLen2 = ybase64_decode(referenceData, l, NULL, 0);
    outData2 = malloc(outLen2);
    l = ybase64_decode(referenceData, l, outData2, outLen2);
    
    assert(outLen1 == outLen2);
    assert(0 == memcmp(outData1, outData2, outLen2));
    
    free(outData1);
    free(outData2);
    free(referenceData);
    outData1 = NULL;
    outData2 = NULL;
    referenceData = NULL;    
}

void compareToNSDataAddition() {
    @autoreleasepool {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"png"];
        NSData * data = [NSData dataWithContentsOfFile:path];
        
        @autoreleasepool {
            YTIMING(5, 
                   [data base64String]; ,
                   "__oauth_base64 implementation: encoding(size:%d)", data.length)
        }
        
        @autoreleasepool {
            YTIMING(5, 
                   [data base64EncodedString];
                   , "NSData+Base64String implementation: encoding(size:%d)", data.length)
        }
        
        NSString * b1 = [data base64String]; 
        NSString * b2 =[data base64EncodedString];
        
        assert(b1 && [b1 isEqualToString:b2]);
        
        @autoreleasepool {
            YTIMING(5,
                   [b1 base64toData]; ,
                   "__oauth_base64 implementation: decoding (size:%d)", b1.length)
        }
        
        @autoreleasepool {
            YTIMING(5,
                   [NSData dataFromBase64String:b2]; ,
                   "NSData+Base64String implementation: decoding (size:%d)", b2.length)
        }
        
        NSData * d1 = [b1 base64toData];
        NSData * d2 = [NSData dataFromBase64String:b2];
        
        unsigned char md1[CC_SHA1_DIGEST_LENGTH] = {0};
        unsigned char md2[CC_SHA1_DIGEST_LENGTH] = {0};
        unsigned char md3[CC_SHA1_DIGEST_LENGTH] = {0};
        
        CC_SHA1(data.bytes, data.length, md1);
        CC_SHA1(d1.bytes, data.length, md2);
        CC_SHA1(d2.bytes, d2.length, md3);
#if TARGET_IPHONE_SIMULATOR
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count]) {
            NSString * path = [paths objectAtIndex:0];
            NSError * error = nil;
            BOOL ret = [b1 writeToFile:[path stringByAppendingPathComponent:@"example1.base64"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (NO == ret && error) {
                NSLog(@"write %@ failed:%@", path, error);
            }
            error = nil;
            ret = [b2 writeToFile:[path stringByAppendingPathComponent:@"example2.base64"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (NO == ret && error) {
                NSLog(@"write %@ failed:%@", path, error);
            }
            
            error = nil;
            ret = [d1 writeToFile:[path stringByAppendingPathComponent:@"example1.png"] atomically:YES];
            if (NO == ret && error) {
                NSLog(@"write %@ failed:%@", path, error);
            }
        }
#endif
        assert(d1 && [d1 isEqualToData:data]);
        //        assert(d2 && [d2 isEqualToData:data]); // it seems te NSData+Base64's decode program has some bugs.
    }
}
