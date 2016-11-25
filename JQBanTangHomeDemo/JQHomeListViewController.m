//
//  DAPageContainerScrollView.m
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAPagesContainer.h"

#import "DAPagesContainerTopBar.h"
#import "DAPageIndicatorView.h"


@interface DAPagesContainer () <DAPagesContainerTopBarDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) DAPagesContainerTopBar *topBar;

@property (weak,   nonatomic) UIScrollView *observingScrollView;
@property (strong, nonatomic) UIView *pageIndicatorView;

@property (          assign, nonatomic) BOOL shouldObserveContentOffset;
@property (readonly, assign, nonatomic) CGFloat scrollWidth;
@property (readonly, assign, nonatomic) CGFloat scrollHeight;
@property (nonatomic, assign) BOOL pageIndicatorStayTopBar;  // 是否留在TopBar.


//@property (nonatomic, weak)UITableView 

- (void)layoutSubviews;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
- (void)stopObservingContentOffset;

@end


@implementation DAPagesContainer

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    [self stopObservingContentOffset];
}

- (void)setUp
{
    _topBarHeight = 30.;
    _topBarBackgroundColor = [UIColor whiteColor];
    _topBarItemLabelsFont = [UIFont systemFontOfSize:14];
    _pageIndicatorViewSize = CGSizeMake(76./2., 2.);
    _pageIndicatorStayTopBar = NO;
    self.pageItemsTitleColor = [UIColor redColor];
    self.selectedPageItemTitleColor = [UIColor redColor];
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldObserveContentOffset = YES;
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.,
                                                                     self.topBarHeight,
                                                                     CGRectGetWidth(self.view.frame),
                                                                     CGRectGetHeight(self.view.frame) - self.topBarHeight)];
    
    
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self startObservingContentOffsetForScrollView:self.scrollView];
    
    self.topBar = [[DAPagesContainerTopBar alloc] initWithFrame:CGRectMake(0.,
                                                                           0.,
                                                                           CGRectGetWidth(self.view.frame),
                                                                           self.topBarHeight)];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.itemTitleColor = self.pageItemsTitleColor;
    self.topBar.delegate = self;
    [self.view addSubview:self.topBar];
    self.topBar.backgroundColor = self.topBarBackgroundColor;
}

- (void)viewDidUnload
{
    [self stopObservingContentOffset];
    self.scrollView = nil;
    self.topBar = nil;
    self.pageIndicatorView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutSubviews];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    NSAssert(selectedIndex < self.viewControllers.count, @"selectedIndex should belong within the range of the view controllers array");
    //    DDLogDebug(@"setSelectedIndex %lu",(unsigned long)selectedIndex);
    if (_delegate && [_delegate respondsToSelector:@selector(pagesCaontainer:didSelectedIndex:)]) {
        [_delegate pagesCaontainer:self didSelectedIndex:selectedIndex];
    }
    
    
    
    
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
    
    ///FIX:( segment类型判断错误。
    //      if ((self.selectedIndex - selectedIndex) <=1 ) {
    
    if ((self.selectedIndex - selectedIndex) == 0) {
        if (selectedIndex == _selectedIndex) {
            if (self.pageIndicatorStayTopBar) {
                self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                            [self pageIndicatorCenterY]);
            }
        }
        [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:animated];
    } else {
        // This means we should "jump" over at least one view controller
        self.shouldObserveContentOffset = NO;
        BOOL scrollingRight = (selectedIndex > self.selectedIndex);
        UIViewController *leftViewController = self.viewControllers[MIN(self.selectedIndex, selectedIndex)];
        UIViewController *rightViewController = self.viewControllers[MAX(self.selectedIndex, selectedIndex)];
        leftViewController.view.frame = CGRectMake(0., 0., self.scrollWidth, self.scrollHeight);
        rightViewController.view.frame = CGRectMake(self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
        self.scrollView.contentSize = CGSizeMake(2 * self.scrollWidth, self.scrollHeight);
        
        CGPoint targetOffset;
        if (scrollingRight) {
            self.scrollView.contentOffset = CGPointZero;
            targetOffset = CGPointMake(self.scrollWidth, 0.);
        } else {
            self.scrollView.contentOffset = CGPointMake(self.scrollWidth, 0.);
            targetOffset = CGPointZero;
            
        }
        [self.scrollView setContentOffset:targetOffset animated:YES];
        
        
        ///FIX:(周建权） tabBar动画和下面scrollView动画不统一
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (self.pageIndicatorStayTopBar) {
                self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                            [self pageIndicatorCenterY]);
            } else {
                [self goAndAlignIndicatorWithNext:selectedIndex];
            }
            
            self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:selectedIndex];
            [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
            [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
            
            for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
                UIViewController *viewController = self.viewControllers[i];
                viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
                [self.scrollView addSubview:viewController.view];
            }
            self.scrollView.contentSize = CGSizeMake(self.scrollWidth * self.viewControllers.count, self.scrollHeight);
            [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:NO];
            
            
            self.shouldObserveContentOffset = YES;
            
            
        } completion:^(BOOL finished) {
            
        }];
        
        
        
        //        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        //            if (self.pageIndicatorStayTopBar) {
        //                self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
        //                                                            [self pageIndicatorCenterY]);
        //            } else {
        //                [self goAndAlignIndicatorWithNext:selectedIndex];
        //            }
        //
        //            self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:selectedIndex];
        //            [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
        //            [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
        //        } completion:^(BOOL finished) {
        //            for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
        //                UIViewController *viewController = self.viewControllers[i];
        //                viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
        //                [self.scrollView addSubview:viewController.view];
        //            }
        //            self.scrollView.contentSize = CGSizeMake(self.scrollWidth * self.viewControllers.count, self.scrollHeight);
        //            [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:NO];
        //
        //            if (finished) {
        //                self.shouldObserveContentOffset = YES;
        //
        //            }
        //        }];
        
    }
    _selectedIndex = selectedIndex;
}

- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation
{
    [self layoutSubviews];
}

#pragma mark * Overwritten setters

- (void)setPageIndicatorViewSize:(CGSize)size
{
    if ([self.pageIndicatorView isKindOfClass:[DAPageIndicatorView class]]) {
        if (!CGSizeEqualToSize(self.pageIndicatorView.frame.size, size)) {
            _pageIndicatorViewSize = size;
            [self layoutSubviews];
        }
    }
}

- (void)setPageItemsTitleColor:(UIColor *)pageItemsTitleColor
{
    if (![_pageItemsTitleColor isEqual:pageItemsTitleColor]) {
        _pageItemsTitleColor = pageItemsTitleColor;
        self.topBar.itemTitleColor = pageItemsTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedPageItemTitleColor:(UIColor *)selectedPageItemTitleColor
{
    if (![_selectedPageItemTitleColor isEqual:selectedPageItemTitleColor]) {
        _selectedPageItemTitleColor = selectedPageItemTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setTopBarBackgroundColor:(UIColor *)topBarBackgroundColor
{
    _topBarBackgroundColor = topBarBackgroundColor;
    self.topBar.backgroundColor = topBarBackgroundColor;
    if ([self.pageIndicatorView isKindOfClass:[DAPageIndicatorView class]]) {
        [(DAPageIndicatorView *)self.pageIndicatorView setColor:topBarBackgroundColor];
    }
}

- (void)setTopBarBackgroundImage:(UIImage *)topBarBackgroundImage
{
    self.topBar.backgroundImage = topBarBackgroundImage;
}

- (void)setTopBarHeight:(NSUInteger)topBarHeight
{
    if (_topBarHeight != topBarHeight) {
        _topBarHeight = topBarHeight;
        [self layoutSubviews];
    }
}

- (void)setTopBarItemLabelsFont:(UIFont *)font
{
    self.topBar.font = font;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers != viewControllers) {
        
        _viewControllers = viewControllers;
        self.topBar.itemTitles = [viewControllers valueForKey:@"title"];
        for (UIViewController *viewController in viewControllers) {
            [self addChildViewController:viewController];
            [viewController willMoveToParentViewController:self];
            viewController.view.frame = CGRectMake(0., 0., CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
            [viewController didMoveToParentViewController:self];
        }
        [self layoutSubviews];
        self.selectedIndex = 0;
        
        // DefaultColor
        UIButton *selectedDefaultButton = self.topBar.itemViews[_selectedIndex];
        [selectedDefaultButton setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
        
        self.pageIndicatorView.frame = CGRectMake(0, 0, selectedDefaultButton.bounds.size.width, self.pageIndicatorView.bounds.size.height);
        
        if (self.pageIndicatorStayTopBar) {
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                        [self pageIndicatorCenterY]);
            
        } else {
            self.pageIndicatorView.center = CGPointMake([self.topBar itemCenterXForSelectedItemAtIndex:self.selectedIndex],
                                                        [self pageIndicatorCenterY]);
            
        }
        
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
    _pageIndicatorImage = pageIndicatorImage;
    self.pageIndicatorViewSize = (pageIndicatorImage) ? pageIndicatorImage.size : self.pageIndicatorViewSize;
    if ((pageIndicatorImage && [self.pageIndicatorView isKindOfClass:[DAPageIndicatorView class]]) || (!pageIndicatorImage && [self.pageIndicatorView isKindOfClass:[UIImageView class]])) {
        [self.pageIndicatorView removeFromSuperview];
        self.pageIndicatorView = nil;
    }
    if (pageIndicatorImage) {
        if ([self.pageIndicatorView isKindOfClass:[DAPageIndicatorView class]]) {
            [self.pageIndicatorView removeFromSuperview];
            self.pageIndicatorView = nil;
        }
        [(UIImageView *)self.pageIndicatorView setImage:pageIndicatorImage];
    } else {
        if ([self.pageIndicatorView isKindOfClass:[UIImageView class]]) {
            [self.pageIndicatorView removeFromSuperview];
            self.pageIndicatorView = nil;
        }
        [(DAPageIndicatorView *)self.pageIndicatorView setColor:self.topBarBackgroundColor];
    }
}

- (UIViewController *)currentSelectedViewController {
    
    return self.viewControllers[self.selectedIndex];
}

#pragma mark - Private

- (void)layoutSubviews
{
    self.topBar.frame = CGRectMake(0., 0., CGRectGetWidth(self.view.bounds), self.topBarHeight);
    CGFloat x = 0.;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize = CGSizeMake(x, self.scrollHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectedIndex * self.scrollWidth, 0.) animated:YES];
    
    if (self.pageIndicatorStayTopBar) {
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    [self pageIndicatorCenterY]);
        
    } else {
        self.pageIndicatorView.center = CGPointMake([self.topBar itemCenterXForSelectedItemAtIndex:self.selectedIndex],
                                                    [self pageIndicatorCenterY]);
        
    }
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
}

- (CGFloat)pageIndicatorCenterY
{
    return CGRectGetMaxY(self.topBar.frame) - 2. + CGRectGetHeight(self.pageIndicatorView.frame) / 2.;
}

- (UIView *)pageIndicatorView
{
    if (!_pageIndicatorView) {
        if (self.pageIndicatorImage) {
            _pageIndicatorView = [[UIImageView alloc] initWithImage:self.pageIndicatorImage];
        } else {
            _pageIndicatorView = [[DAPageIndicatorView alloc] initWithFrame:CGRectMake(0.,
                                                                                       44,
                                                                                       self.pageIndicatorViewSize.width,
                                                                                       self.pageIndicatorViewSize.height)];
            [(DAPageIndicatorView *)_pageIndicatorView setColor:self.topBarBackgroundColor];
        }
    }
    
    if (!_pageIndicatorView.superview) {
        if (self.pageIndicatorStayTopBar) {
            [self.view addSubview:_pageIndicatorView];
        } else {
            [self.topBar.scrollView addSubview:_pageIndicatorView];
        }
    }
    
    return _pageIndicatorView;
}

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.frame) - self.topBarHeight;
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.scrollView.frame);
}

- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.observingScrollView = scrollView;
}

- (void)stopObservingContentOffset
{
    if (self.observingScrollView) {
        [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observingScrollView = nil;
    }
}

- (BOOL)updateSelectedIndexIfNeeded
{
    BOOL ret = NO;
    CGFloat width = [self scrollWidth];
    CGFloat halfWidth = width / 2.f;
    
    CGFloat startOffsetX = self.scrollView.contentOffset.x + halfWidth;
    NSUInteger selectedIndex = startOffsetX / width;
    
    if (self.selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        ret = YES;
    }
    
    return ret;
}

- (void)updatePageIndicatorViewFrame
{
    CGFloat previousOffsetX = self.selectedIndex * [self scrollWidth];
    CGFloat haldWidth = [self scrollWidth] / 2;
    NSUInteger currentIndex = fabs((self.scrollView.contentOffset.x + haldWidth) / [self scrollWidth]);
    
    NSUInteger nextIndex = currentIndex;
    if (previousOffsetX < self.scrollView.contentOffset.x) {
        
        nextIndex = currentIndex + 1;
    } else if (previousOffsetX > self.scrollView.contentOffset.x) {
        
        nextIndex = currentIndex - 1;
    }
    
    if (nextIndex >= 0
        && nextIndex <= (self.viewControllers.count - 1)
        && currentIndex != nextIndex) {
        
        UIButton *currentItem = self.topBar.itemViews[currentIndex];
        UIButton *nextItem = self.topBar.itemViews[nextIndex];
        
        CGFloat diffWidth = nextItem.bounds.size.width - currentItem.bounds.size.width;
        CGFloat nextOffsetX = nextIndex * [self scrollWidth];
        CGFloat diffOffsetX = nextIndex > currentIndex
        ? nextOffsetX - self.scrollView.contentOffset.x
        : self.scrollView.contentOffset.x - nextOffsetX;
        
        CGFloat absRatio = fabs(1.f - diffOffsetX / [self scrollWidth]);
        
        self.pageIndicatorView.frame = CGRectMake(0, 0, currentItem.bounds.size.width + (absRatio * diffWidth), self.pageIndicatorView.bounds.size.height);
        
        if (!self.pageIndicatorStayTopBar) {
            
            CGFloat diffTopBarScrollOffsetX = nextItem.center.x - currentItem.center.x;
            self.pageIndicatorView.center = CGPointMake(currentItem.center.x + (diffTopBarScrollOffsetX * absRatio), [self pageIndicatorCenterY]);
        }
    }
}


- (void)goAndAlignIndicatorWithNext:(NSInteger)nextIndex
{
    UIButton *nextItem = self.topBar.itemViews[nextIndex];
    self.pageIndicatorView.frame = CGRectMake(nextItem.frame.origin.x,
                                              _pageIndicatorView.frame.origin.y,
                                              nextItem.frame.size.width,
                                              self.pageIndicatorView.bounds.size.height);
}

#pragma mark - DAPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(DAPagesContainerTopBar *)bar
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    CGFloat oldX = self.selectedIndex * CGRectGetWidth(self.scrollView.frame);
    if (oldX != self.scrollView.contentOffset.x && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.viewControllers.count) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;
            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
            UIButton *previosSelectedItem = self.topBar.itemViews[self.selectedIndex];
            UIButton *nextSelectedItem = self.topBar.itemViews[targetIndex];
            
            
            
            CGFloat red, green, blue, alpha, highlightedRed, highlightedGreen, highlightedBlue, highlightedAlpha;
            [self getRed:&red green:&green blue:&blue alpha:&alpha fromColor:self.pageItemsTitleColor];
            [self getRed:&highlightedRed green:&highlightedGreen blue:&highlightedBlue alpha:&highlightedAlpha fromColor:self.selectedPageItemTitleColor];
            
            CGFloat absRatio = fabs(ratio);
            UIColor *prev = [UIColor colorWithRed:red * absRatio + highlightedRed * (1 - absRatio)
                                            green:green * absRatio + highlightedGreen * (1 - absRatio)
                                             blue:blue * absRatio + highlightedBlue  * (1 - absRatio)
                                            alpha:alpha * absRatio + highlightedAlpha  * (1 - absRatio)];
            UIColor *next = [UIColor colorWithRed:red * (1 - absRatio) + highlightedRed * absRatio
                                            green:green * (1 - absRatio) + highlightedGreen * absRatio
                                             blue:blue * (1 - absRatio) + highlightedBlue * absRatio
                                            alpha:alpha * (1 - absRatio) + highlightedAlpha * absRatio];
            
            [previosSelectedItem setTitleColor:prev forState:UIControlStateNormal];
            [nextSelectedItem setTitleColor:next forState:UIControlStateNormal];
            
            [self updateSelectedIndexIfNeeded];
            [self updatePageIndicatorViewFrame];
            
            if (scrollingTowards) {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX +
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                if (_pageIndicatorStayTopBar) {
                    self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX +
                                                                (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                                [self pageIndicatorCenterY]);
                    
                }
                
            } else {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX -
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                if (_pageIndicatorStayTopBar) {
                    self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX -
                                                                (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                                [self pageIndicatorCenterY]);
                }
            }
            
        }
    }
}

- (void)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha fromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    if (colorSpaceModel == kCGColorSpaceModelRGB && CGColorGetNumberOfComponents(color.CGColor) == 4) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    } else if (colorSpaceModel == kCGColorSpaceModelMonochrome && CGColorGetNumberOfComponents(color.CGColor) == 2) {
        *red = *green = *blue = components[0];
        *alpha = components[1];
    } else {
        *red = *green = *blue = *alpha = 0;
    }
}




@end
