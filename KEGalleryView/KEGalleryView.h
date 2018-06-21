//
//  KEGalleryView.h
//  KEesail
//
//  Created by yanglukai on 16/8/9.
//  Copyright © 2016年 LK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KEGalleryView;

@protocol KEGalleryViewDataSource <NSObject>
@required
- (NSInteger)numberOfPagesInGalleryView:(KEGalleryView *)galleryView;
- (UIView *)galleryView:(KEGalleryView *)galleryView pageAtIndex:(NSInteger)index;
@end

@protocol KEGalleryViewDelegate <NSObject>
@optional
- (void)galleryView:(KEGalleryView *)galleryView didSelectPageAtIndex:(NSInteger)index;
@end

@interface KEGalleryView : UIView

@property (nonatomic, weak) id<KEGalleryViewDataSource> dataSource;
@property (nonatomic, weak) id<KEGalleryViewDelegate> delegate;

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

@property (nonatomic, strong, readonly) UIScrollView *contentScrollView;

/**
 *  是否允许自动轮播 默认为NO
 */
@property (nonatomic, assign) BOOL autoScrollEnable;

/**
 *  轮播间隔时间，仅当autoScrollEnable == YES时生效，默认为2.0
 */
@property (nonatomic, assign) NSTimeInterval autoScrollInterval;

- (void)reloadData;

- (void)autoScrollSuspend;
- (void)autoScrollResume;

@end
