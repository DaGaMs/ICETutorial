//
//  ICETutorialController.m
//
//
//  Created by Patrick Trillsam on 25/03/13.
//  Copyright (c) 2013 Patrick Trillsam. All rights reserved.
//

#import "ICETutorial.h"

@interface ICETutorialController ()
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *frontLayerView;
@property (weak, nonatomic) IBOutlet UIImageView *backLayerView;

@end

@implementation ICETutorialController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        _autoScrollEnabled = YES;
        _autoScrollLooping = YES;
        _autoScrollDurationOnPage = TUTORIAL_DEFAULT_DURATION_ON_PAGE;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                pages:(NSArray *)pages{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        _pages = pages;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    _windowSize = [[UIScreen mainScreen] bounds].size;
    
    // ScrollView configuration.
    [_scrollView setContentSize:CGSizeMake([self numberOfPages] * _windowSize.width,
                                           _scrollView.contentSize.height)];
    [_scrollView setPagingEnabled:YES];
    
    // PageControl configuration.
    [_pageControl setNumberOfPages:[self numberOfPages]];
    [_pageControl setCurrentPage:0];
    
    // force reload of titles
    if (self.rightButtonTitle) {
        [self setRightButtonTitle:self.rightButtonTitle];
    }
    if (self.leftButtonTitle) {
        [self setLeftButtonTitle:self.leftButtonTitle];
    }
    if (self.overlayTitle) {
        [self setOverlayTitle:self.overlayTitle];
    }
    
    // Overlays.
    [self setOverlayTexts];
    
    // Preset the origin state.
    [self setOriginLayersState];

    // Run the auto-scrolling.
    [self autoScrollToNextPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)didClickOnLeftButton:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialControllerLeftButtonPressed:)]) {
        [self.delegate tutorialControllerLeftButtonPressed:self];
    }
}

- (IBAction)didClickOnRightButton:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialControllerRightButtonPressed:)]) {
        [self.delegate tutorialControllerRightButtonPressed:self];
    }
}

- (IBAction)didClickOnPageControl:(UIPageControl *)sender {
    _currentState = ScrollingStateManual;
    
    // Make the scrollView animation.
    if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialController:willTransitionFromPageIndex:toPageIndex:)])
    {
        [self.delegate tutorialController:self willTransitionFromPageIndex:_currentPageIndex toPageIndex:sender.currentPage];
    }
    [_scrollView setContentOffset:CGPointMake(sender.currentPage * _windowSize.width,0)
                         animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialController:didTransitionFromPageIndex:toPageIndex:)]) {
        NSUInteger curPage = _currentPageIndex;
        NSUInteger nextPage = sender.currentPage;
        
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate tutorialController:self didTransitionFromPageIndex:curPage toPageIndex:nextPage];
            if (nextPage+1 == [_pages count]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialControllerReachedLastPage:)]) {
                    [self.delegate tutorialControllerReachedLastPage:self];
                }
            }
        });
        
    }
    // Set the PageControl on the right page.
    [_pageControl setCurrentPage:sender.currentPage];
}

#pragma mark - Pages

- (NSUInteger)numberOfPages{
    if (_pages)
        return [_pages count];
    
    return 0;
}

#pragma mark - Animations
- (void)animateScrolling{
    if (_currentState & ScrollingStateManual)
        return;
    
    // Jump to the next page...
    int nextPage = _currentPageIndex + 1;
    if (nextPage == [self numberOfPages]){
        // ...stop the auto-scrolling or...
        if (!_autoScrollLooping){
            _currentState = ScrollingStateManual;
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialController:willTransitionFromPageIndex:toPageIndex:)]) {
            [self.delegate tutorialController:self willTransitionFromPageIndex:_currentPageIndex toPageIndex:0];
        }
        
        // ...jump to the first page.
        nextPage = 0;
        _currentState = ScrollingStateLooping;
        
        // Set alpha on layers.
        [self setLayersPrimaryAlphaWithPageIndex:0];
        [self setBackLayerPictureWithPageIndex:-1];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialController:willTransitionFromPageIndex:toPageIndex:)]) {
            [self.delegate tutorialController:self willTransitionFromPageIndex:_currentPageIndex toPageIndex:nextPage];
        }
        _currentState = ScrollingStateAuto;
    }
    
    // Make the scrollView animation.
    [_scrollView setContentOffset:CGPointMake(nextPage * _windowSize.width,0)
                         animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialController:didTransitionFromPageIndex:toPageIndex:)]) {
        NSUInteger curPage = _currentPageIndex;
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate tutorialController:self didTransitionFromPageIndex:curPage toPageIndex:nextPage];
            if (nextPage+1 == [_pages count] && !self.autoScrollLooping) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialControllerReachedLastPage:)]) {
                    [self.delegate tutorialControllerReachedLastPage:self];
                }
            }
        });
        
    }
    
    // Set the PageControl on the right page.
    [_pageControl setCurrentPage:nextPage];
    
    // Call the next animation after X seconds.
    [self autoScrollToNextPage];
}

// Call the next animation after X seconds.
- (void)autoScrollToNextPage{
    if (_autoScrollEnabled)
        [self performSelector:@selector(animateScrolling)
                   withObject:nil
                   afterDelay:_autoScrollDurationOnPage];
}

#pragma mark - Scrolling management
// Run it.
- (void)startScrolling{
    [self autoScrollToNextPage];
}

// Manually stop the scrolling
- (void)stopScrolling{
    _currentState = ScrollingStateManual;
}

#pragma mark - Manage labels
// Setup the Title Label.
- (void)setOverlayTitle:(NSString *)title {
    
    _overlayTitle = title;
    if (self.titleLabel)
        [self.titleLabel setText:title];
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle {
    _leftButtonTitle = leftButtonTitle;
    if (self.leftButton) {
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateHighlighted];
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateSelected];
    }
}

- (void)setRightButtonTitle:(NSString *)rightButtonTitle {
    _rightButtonTitle = rightButtonTitle;
    if (self.rightButton) {
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateHighlighted];
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateSelected];
    }
}

// Setup the SubTitle/Description style/text.
- (void)setOverlayTexts{
    int index = 0;    
    for(ICETutorialPage *page in _pages){
        // SubTitles.
        if ([[[page subTitle] text] length]){
            UILabel *subTitle = [self overlayLabelWithText:[[page subTitle] text]
                                                     layer:[page subTitle]
                                               commonStyle:_commonPageSubTitleStyle
                                                     index:index];
            [_scrollView addSubview:subTitle];
        }
        // Description.
        if ([[[page description] text] length]){
            UILabel *description = [self overlayLabelWithText:[[page description] text]
                                                        layer:[page description]
                                                  commonStyle:_commonPageDescriptionStyle
                                                        index:index];
            [_scrollView addSubview:description];
        }
        
        index++;
    }
}

- (UILabel *)overlayLabelWithText:(NSString *)text
                            layer:(ICETutorialLabelStyle *)style
                      commonStyle:(ICETutorialLabelStyle *)commonStyle
                            index:(NSUInteger)index{
    // SubTitles.
    UILabel *overlayLabel = [[UILabel alloc] initWithFrame:CGRectMake((index  * _windowSize.width),
                                                                      _windowSize.height - [commonStyle offset],
                                                                      _windowSize.width,
                                                                      TUTORIAL_LABEL_HEIGHT)];
    [overlayLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [overlayLabel setNumberOfLines:[commonStyle linesNumber]];
    [overlayLabel setBackgroundColor:[UIColor clearColor]];
    [overlayLabel setTextAlignment:NSTextAlignmentCenter];  

    // Datas and style.
    [overlayLabel setText:text];
    [style font] ? [overlayLabel setFont:[style font]] :
                   [overlayLabel setFont:[commonStyle font]];
    if ([style textColor])
        [overlayLabel setTextColor:[style textColor]];
    else
        [overlayLabel setTextColor:[commonStyle textColor]];
  
    return overlayLabel;
}

#pragma mark - Layers management
// Handle the background layer image switch.
- (void)setBackLayerPictureWithPageIndex:(NSInteger)index{
    [self setBackgroundImage:_backLayerView withIndex:index + 1];
}

// Handle the front layer image switch.
- (void)setFrontLayerPictureWithPageIndex:(NSInteger)index{
    [self setBackgroundImage:_frontLayerView withIndex:index];
}

// Handle page image's loading
- (void)setBackgroundImage:(UIImageView *)imageView withIndex:(NSInteger)index{
    if (index >= [_pages count]){
        [imageView setImage:nil];
        return;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[[_pages objectAtIndex:index] pictureName]];
    [imageView setImage:[UIImage imageNamed:imageName]];
}

// Setup layer's alpha.
- (void)setLayersPrimaryAlphaWithPageIndex:(NSInteger)index{
    [_frontLayerView setAlpha:1];
    [_backLayerView setAlpha:0];
}

// Preset the origin state.
- (void)setOriginLayersState{
    _currentState = ScrollingStateAuto;
    [_backLayerView setBackgroundColor:[UIColor blackColor]];
    [_frontLayerView setBackgroundColor:[UIColor blackColor]];
    [self setLayersPicturesWithIndex:0];
}

// Setup the layers with the page index.
- (void)setLayersPicturesWithIndex:(NSInteger)index{
    _currentPageIndex = index;
    [self setLayersPrimaryAlphaWithPageIndex:index];
    [self setFrontLayerPictureWithPageIndex:index];
    [self setBackLayerPictureWithPageIndex:index];
}

// Animate the fade-in/out (Cross-disolve) with the scrollView translation.
- (void)disolveBackgroundWithContentOffset:(float)offset{
    if (_currentState & ScrollingStateLooping){
        // Jump from the last page to the first.
        [self scrollingToFirstPageWithOffset:offset];
    } else {
        // Or just scroll to the next/previous page.
        [self scrollingToNextPageWithOffset:offset];
    }
}

// Handle alpha on layers when the auto-scrolling is looping to the first page.
- (void)scrollingToFirstPageWithOffset:(float)offset{
    // Compute the scrolling percentage on all the page.
    offset = (offset * _windowSize.width) / (_windowSize.width * [self numberOfPages]);
    
    // Scrolling finished...
    if (offset == 0){
        // ...reset to the origin state.
        [self setOriginLayersState];
        return;
    }
    
    // Invert alpha for the back picture.
    float backLayerAlpha = (1 - offset);
    float frontLayerAlpha = offset;
    
    // Set alpha.
    [_backLayerView setAlpha:backLayerAlpha];
    [_frontLayerView setAlpha:frontLayerAlpha];
}

// Handle alpha on layers when we are scrolling to the next/previous page.
- (void)scrollingToNextPageWithOffset:(float)offset{
    // Current page index in scrolling.
    NSInteger page = (int)(offset);
    
    // Keep only the float value.
    float alphaValue = offset - (int)offset;
    
    // This is only when you scroll to the right on the first page.
    // That will fade-in black the first picture.
    if (alphaValue < 0 && _currentPageIndex == 0){
        [_backLayerView setImage:nil];
        [_frontLayerView setAlpha:(1 + alphaValue)];
        return;
    }
    
    // Switch pictures, and imageView alpha.
    if (page != _currentPageIndex)
        [self setLayersPicturesWithIndex:page];
    
    // Invert alpha for the front picture.
    float backLayerAlpha = alphaValue;
    float frontLayerAlpha = (1 - alphaValue);
    
    // Set alpha.
    [_backLayerView setAlpha:backLayerAlpha];
    [_frontLayerView setAlpha:frontLayerAlpha];
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // Get scrolling position, and send the alpha values.
    float scrollingPosition = scrollView.contentOffset.x / _windowSize.width;
    [self disolveBackgroundWithContentOffset:scrollingPosition];
    
    if (_scrollView.isTracking)
        _currentState = ScrollingStateManual;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // Update the page index.
    [_pageControl setCurrentPage:_currentPageIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialController:didTransitionFromPageIndex:toPageIndex:)]) {
        [self.delegate tutorialController:self didTransitionFromPageIndex:_previousPageIndex toPageIndex:_currentPageIndex];
        _previousPageIndex = _currentPageIndex;
        if (_currentPageIndex+1 == [_pages count]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialControllerReachedLastPage:)]) {
                [self.delegate tutorialControllerReachedLastPage:self];
            }
        }
    }
}

@end
