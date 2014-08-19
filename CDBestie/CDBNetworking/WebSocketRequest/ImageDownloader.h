//
//  ImageDownloader.h
//  base_test
//
//  Created by xinchen on 14-8-13.
//  Copyright (c) 2014年 co.po. All rights reserved.
//

#import <Foundation/Foundation.h>

/*[[ImageDownloader instanse] startDownload:imageview forUrl:[NSURL URLWithString:info.user.headpic]
 callback:^(UIImageView *view, UIImage *image) {
 //返回 imageview 和下载好的 image ，image＝nil就是下载失败，如果image连续提交2次，url不一样，那第一次的url对应的回调是不会发生的
    if(image!=nil)
        view.image=image;
}];*/
typedef void(^result_callback)(UIView* view, id image);
@interface ImageDownloader : NSObject
@property (strong,nonatomic) NSRunLoop *runloop;
+(ImageDownloader*)instanse;
-(void) startDownload:(UIView*)view forUrl:(NSURL*) url callback:(result_callback)callback;
@end
