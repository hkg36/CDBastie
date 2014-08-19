//
//  ImageDownloader.m
//  base_test
//
//  Created by xinchen on 14-8-13.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import "ImageDownloader.h"
#import <WebP/decode.h>

@interface ImageDownloader()
@property (strong,nonatomic) NSThread *workthread;
@property (strong,nonatomic) NSMutableDictionary *imgbuffer;
@end


ImageDownloader* one_instanse=nil;
@implementation ImageDownloader
+(ImageDownloader*)instanse
{
    if(one_instanse==nil)
    {
        one_instanse=[ImageDownloader new];
    }
    
    return one_instanse;
}
-(id) init
{
    if(self==nil)
        return nil;
    self.workthread=[[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
    [self.workthread start];
    self.imgbuffer=[NSMutableDictionary new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name: UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}
- (void)threadMain:(id)obj
{
    NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
    [myRunLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    self.runloop=myRunLoop;
    do
    {
        [myRunLoop runMode:NSDefaultRunLoopMode
                beforeDate:[NSDate distantFuture]];
    }
    while (true);
}
-(void) startDownload:(UIView*)img forUrl:(NSURL*) url callback:(result_callback)callback
{
    UIImage *buffimg=nil;
    @synchronized(self.imgbuffer){
        buffimg=[self.imgbuffer objectForKey:url];
    }
    if(buffimg){
        callback(img,buffimg);
        return;
    }
    [img.layer setValue:url forKey:@"download_image_work"];
    [self performSelector:@selector(BackDownload:) onThread:self.workthread withObject:@{@"view":img,@"callback":callback} waitUntilDone:false];
}
-(void) BackDownload:(NSDictionary*)work
{
    UIImageView* img=[work valueForKey:@"view"];
    NSURL *url=[img.layer valueForKey:@"download_image_work"];
    UIImage *buffimg=nil;
    @synchronized(self.imgbuffer)
    {
        buffimg=[self.imgbuffer objectForKey:url];
    }
    if(buffimg){
        [self performSelectorOnMainThread:@selector(FrontSetup:) withObject:@{@"view":img,@"img":buffimg,@"url":url,@"callback":[work objectForKey:@"callback"]} waitUntilDone:false];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(responseData)
    {
        UIImage *resimg=nil;
        if([response.MIMEType caseInsensitiveCompare:@"image/webp"]==NSOrderedSame){
            int width = 0;
            int height = 0;
            CGDataProviderRef provider;
            uint8_t *data = WebPDecodeRGBA([responseData bytes], [responseData length], &width, &height);
            if(data)
            {
                provider = CGDataProviderCreateWithData(NULL, data, width*height*4, free_image_data);
                
                CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
                CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
                CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
                CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4*width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
                resimg = [UIImage imageWithCGImage:imageRef];
            }
        }
        else{
            resimg=[UIImage imageWithData:responseData];
        }
        if(resimg)
        {
            @synchronized(self.imgbuffer){
                [self.imgbuffer setObject:resimg forKey:url];
            }
            [self performSelectorOnMainThread:@selector(FrontSetup:) withObject:@{@"view":img,@"img":resimg,@"url":url,@"callback":[work objectForKey:@"callback"]} waitUntilDone:false];
            return;
        }
    }
    [self performSelectorOnMainThread:@selector(FrontSetup:) withObject:@{@"view":img,@"url":url,@"callback":[work objectForKey:@"callback"]} waitUntilDone:false];
}
-(void)FrontSetup:(NSDictionary*)work
{
    UIImage* img=[work valueForKey:@"img"];
    UIImageView *view=[work valueForKey:@"view"];
    NSURL *url=[view.layer valueForKey:@"download_image_work"];
    NSURL *workurl=[work valueForKey:@"url"];
    result_callback callback=[work valueForKey:@"callback"];
    if([workurl isEqual:url])
    {
        callback(view,img);
    }
}
- (void) handleMemoryWarning:(NSNotification *)notification
{
    @synchronized(self.imgbuffer)
    {
        [self.imgbuffer removeAllObjects];
    }
}
static void free_image_data(void *info, const void *data, size_t size)
{
    if(info != NULL)
    {
        WebPFreeDecBuffer(&(((WebPDecoderConfig *)info)->output));
    }
    else
    {
        free((void *)data);
    }
}
@end
