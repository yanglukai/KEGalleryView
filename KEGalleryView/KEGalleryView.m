//
//  KEGalleryView.m
//  KEesail
//
//  Created by yanglukai on 16/8/9.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "KEGalleryView.h"

@interface NSTimer (Addition)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end

@implementation NSTimer (Addition)

- (void)pauseTimer
{
    if (![self isValid]) {
        return;
    }
    [self setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer
{
    if (![self isValid]) {
        return;
    }
    [self setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![self isValid]) {
        return;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end


@interface KEGalleryView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, strong) NSMutableArray *viewMurArray;
@property (nonatomic, strong) NSTimer *autoScrollTimer;

@end

@implementation KEGalleryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _autoScrollInterval = 2.0;
        [self p_prepareViewWithFrame:frame];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        if (self.autoScrollEnable && self.totalPageCount > 1) {
            [self autoScrollResume];
        }
    }else{
        if (self.autoScrollEnable && self.totalPageCount > 1) {
            [self autoScrollSuspend];
        }
    }
}

- (void)p_prepareViewWithFrame:(CGRect)frame
{
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _contentScrollView.scrollsToTop = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentScrollView];
    
    CGRect rect = self.bounds;
    rect.origin.y = rect.size.height - 13 - 8;
    rect.size.height = 8;
    self.pageControl = [[UIPageControl alloc] initWithFrame:rect];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
    
    self.currentPageIndex = 0;
}

#pragma mark - Private Methods
- (void)p_loadData
{
    _pageControl.currentPage = _currentPageIndex;
    
    // 清空subView
    NSArray *subView = [_contentScrollView subviews];
    if (subView.count) {
        [subView makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self p_prepareViewsWithCurrentPageIndex:_currentPageIndex];
    for (int i = 0; i < 3; i++) {
        UIView *view = (_viewMurArray.count > i)?_viewMurArray[i]:nil;
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleGesture:)];
        [view addGestureRecognizer:tapGesture];
        view.frame = CGRectOffset(view.frame, view.frame.size.width * i, 0);
        
        [_contentScrollView addSubview:view];
    }
    [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.frame.size.width, 0)];
}

- (void)p_prepareViewsWithCurrentPageIndex:(NSInteger)pageIndex
{
    NSInteger preIndex = [self p_validPageIndex:(pageIndex - 1)];
    NSInteger nextIndex = [self p_validPageIndex:(pageIndex + 1)];
    
    if (!_viewMurArray) {
        self.viewMurArray = [NSMutableArray array];
    }
    
    [_viewMurArray removeAllObjects];
    
    if (_dataSource) {
        [_viewMurArray addObject:[_dataSource galleryView:self pageAtIndex:preIndex]];
        [_viewMurArray addObject:[_dataSource galleryView:self pageAtIndex:pageIndex]];
        [_viewMurArray addObject:[_dataSource galleryView:self pageAtIndex:nextIndex]];
    }
}

- (NSInteger)p_validPageIndex:(NSInteger)index
{
    if (index < 0) {
        return _totalPageCount - 1;
    }else if (index >= _totalPageCount){
        return 0;
    }
    return index;
}

- (void)p_reloadPageControlTintColor
{
    _pageControl.pageIndicatorTintColor = _pageIndicatorTintColor;
    _pageControl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
}

- (void)p_handleTimer:(NSTimer *)timer
{
    [self p_switchToNextPage];
}

- (void)p_switchToNextPage
{
    CGPoint offset = CGPointMake(_contentScrollView.contentOffset.x + CGRectGetWidth(_contentScrollView.frame), _contentScrollView.contentOffset.y);
    [_contentScrollView setContentOffset:offset animated:YES];
}

- (void)p_createTimerWithTimeInterval:(NSTimeInterval)timeInterval
{
    if (_autoScrollEnable && timeInterval > 0.0) {
        if (_autoScrollTimer) {
            [self p_killTimer];
        }
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollInterval target:self selector:@selector(p_handleTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_autoScrollTimer forMode:NSRunLoopCommonModes];
        [_autoScrollTimer pauseTimer];
    }
}

- (void)p_killTimer
{
    if (_autoScrollTimer) {
        if ([_autoScrollTimer isValid]) {
            [_autoScrollTimer invalidate];
        }
        _autoScrollTimer = nil;
    }
}

#pragma mark - Public Methods
- (void)reloadData
{
    self.totalPageCount = [_dataSource numberOfPagesInGalleryView:self];
    if (!_totalPageCount) {
        _pageControl.hidden = YES;
        self.autoScrollEnable = NO;
        return;
    }else if (_totalPageCount == 1){
        _contentScrollView.scrollEnabled = NO;
        _pageControl.hidden = YES;
        self.autoScrollEnable = NO;
    }else{
        _contentScrollView.scrollEnabled = YES;
        _pageControl.hidden = NO;
    }
    _pageControl.numberOfPages = _totalPageCount;
    [self p_loadData];
    [_autoScrollTimer resumeTimerAfterTimeInterval:_autoScrollInterval];
}

- (void)autoScrollSuspend
{
    [_autoScrollTimer pauseTimer];
}

- (void)autoScrollResume
{
    [_autoScrollTimer resumeTimerAfterTimeInterval:_autoScrollInterval];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollView) {
        [_autoScrollTimer pauseTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == _contentScrollView) {
        [_autoScrollTimer resumeTimerAfterTimeInterval:_autoScrollInterval];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollView) {
        CGFloat offsetX = scrollView.contentOffset.x;
        if (offsetX <= 0) {
            _currentPageIndex = [self p_validPageIndex:(_currentPageIndex - 1)];
            [self p_loadData];
        }else if (offsetX >= (2 * self.bounds.size.width)){
            _currentPageIndex = [self p_validPageIndex:(_currentPageIndex + 1)];
            [self p_loadData];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollView) {
        [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.bounds.size.width, 0) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollView && scrollView.contentOffset.x != scrollView.bounds.size.width) {
        [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.bounds.size.width, 0) animated:YES];
    }
}

#pragma mark - Gesture Recognizer
- (void)p_handleGesture:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(galleryView:didSelectPageAtIndex:)]) {
        [_delegate galleryView:self didSelectPageAtIndex:_currentPageIndex];
    }
}

#pragma mark - Setter
- (void)setDataSource:(id<KEGalleryViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setDelegate:(id<KEGalleryViewDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
{
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self p_reloadPageControlTintColor];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
{
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self p_reloadPageControlTintColor];
}

- (void)setAutoScrollEnable:(BOOL)autoScrollEnable
{
    _autoScrollEnable = autoScrollEnable;
    if (autoScrollEnable) {
        [self p_createTimerWithTimeInterval:_autoScrollInterval];
    }
    else
    {
        [self p_killTimer];
    }
}

- (void)setAutoScrollInterval:(NSTimeInterval)autoScrollInterval
{
    _autoScrollInterval = autoScrollInterval;
    if (_autoScrollEnable) {
        [self p_createTimerWithTimeInterval:autoScrollInterval];
    }
}


@end

