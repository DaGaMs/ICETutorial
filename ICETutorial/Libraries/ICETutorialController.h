//
//  ICETutorialController.h
//
//
//  Created by Patrick Trillsam on 25/03/13.
//  Copyright (c) 2013 Patrick Trillsam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETutorialPage.h"

#define TUTORIAL_LABEL_TEXT_COLOR               [UIColor whiteColor]
#define TUTORIAL_LABEL_HEIGHT                   34
#define TUTORIAL_SUB_TITLE_FONT                 [UIFont fontWithName:@"Helvetica-Bold" size:17.0f]
#define TUTORIAL_SUB_TITLE_LINES_NUMBER         1
#define TUTORIAL_SUB_TITLE_OFFSET               180
#define TUTORIAL_DESC_FONT                      [UIFont fontWithName:@"Helvetica" size:15.0f]
#define TUTORIAL_DESC_LINES_NUMBER              2
#define TUTORIAL_DESC_OFFSET                    150
#define TUTORIAL_DEFAULT_DURATION_ON_PAGE       3.0f

// Scrolling state.
typedef NS_OPTIONS(NSUInteger, ScrollingState) {
    ScrollingStateAuto      = 1 << 0,
    ScrollingStateManual    = 1 << 1,
    ScrollingStateLooping   = 1 << 2,
};

@class ICETutorialController;
@class ICETutorialPage;
@protocol ICETutorialDelegate <NSObject>

@optional
-(void)tutorialControllerLeftButtonPressed:(ICETutorialController *)controller;
-(void)tutorialControllerRightButtonPressed:(ICETutorialController *)controller;
-(void)tutorialController:(ICETutorialController *)controller willTransitionFromPageIndex:(NSUInteger)fromPage toPageIndex:(NSUInteger)toPage;
-(void)tutorialController:(ICETutorialController *)controller didTransitionFromPageIndex:(NSUInteger)fromPage toPageIndex:(NSUInteger)toPage;
-(void)tutorialControllerReachedLastPage:(ICETutorialController *)controller;
@end

@interface ICETutorialController : UIViewController <UIScrollViewDelegate> {
    CGSize _windowSize;
    NSUInteger _previousPageIndex;
    NSUInteger _currentPageIndex;
}

@property (nonatomic, assign) BOOL autoScrollEnabled;
@property (nonatomic, assign) BOOL autoScrollLooping;
@property (nonatomic, assign) CGFloat autoScrollDurationOnPage;
@property (nonatomic, strong) NSString *overlayTitle;
@property (nonatomic, strong) NSString *leftButtonTitle;
@property (nonatomic, strong) NSString *rightButtonTitle;
@property (nonatomic, retain) ICETutorialLabelStyle *commonPageSubTitleStyle;
@property (nonatomic, retain) ICETutorialLabelStyle *commonPageDescriptionStyle;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, assign, readonly) ScrollingState currentState;
@property (nonatomic, weak) id<ICETutorialDelegate> delegate;

// Inits.
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                pages:(NSArray *)pages;

// Pages management.
- (NSUInteger)numberOfPages;

// Scrolling.
- (void)startScrolling;
- (void)stopScrolling;

@end
