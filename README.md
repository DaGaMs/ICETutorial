ICETutorial
===========

### Welcome to ICETutorial.
This small project is an implementation of the tutorial view introduced by the Path 3.X app.
Very simple and efficient tutorial, composed with N full-screen pictures that you can swipe for switching to the next/previous page.

Here are the features :
* Compose your own tutorial with N pictures
* Fixed incrusted title (can be easily replaced by an UIImageView, or just removed)
* Scrolling sub-titles for page, with associated descriptions (change the texts, font, color...)
* Auto-scrolling (enable/disable, loop, setup duration)
* Cross fade between next/previous background

![ICETutorial](https://github.com/icepat/ICETutorial/blob/master/screen_shot.jpg?raw=true)

### Setting-up the ICETutorial
The code is commented, and I guess, easy to read/understand/modify.
All the available settings for the scrolling are located in the header : ICETutorial.h :

**Texts and pictures :**
```objective-c
    // Init the pages texts, and pictures.
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 1"
                                                            description:@"Champs-Elysées by night"
                                                            pictureName:@"tutorial_background_00@2x.jpg"];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 2"
                                                            description:@"The Eiffel Tower with\n cloudy weather"
                                                            pictureName:@"tutorial_background_01@2x.jpg"];
    [...] 
```

**Common styles for SubTitles and Descriptions :**
```objective-c
    // Set the common style for SubTitles and Description (can be overrided on each page).
    ICETutorialLabelStyle *subStyle = [[ICETutorialLabelStyle alloc] init];
    [subStyle setFont:TUTORIAL_SUB_TITLE_FONT];
    [subStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [subStyle setLinesNumber:TUTORIAL_SUB_TITLE_LINES_NUMBER];
    [subStyle setOffset:TUTORIAL_SUB_TITLE_OFFSET];
    
    ICETutorialLabelStyle *descStyle = [[ICETutorialLabelStyle alloc] init];
    [descStyle setFont:TUTORIAL_DESC_FONT];
    [descStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [descStyle setLinesNumber:TUTORIAL_DESC_LINES_NUMBER];
    [descStyle setOffset:TUTORIAL_DESC_OFFSET];

    // Load into an array.
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
  
```

**Init and load :**
```objective-c
    self.viewController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPhone"
                                                                  bundle:nil
                                                                   pages:tutorialLayers];

    // Set the common styles, and start scrolling (auto scroll, and looping enabled by default)
    [self.viewController setCommonPageSubTitleStyle:subStyle];
    [self.viewController setCommonPageDescriptionStyle:descStyle];
	
	// The ICETutorialController will notify the delegate when a page is flipped or a button is pressed
	self.viewController.delegate = self;
	// Customize the headline and button labels
	self.viewController.overlayTitle = @"Main Title";
	self.viewController.leftButtonTitle = @"Do nothing";
	self.viewController.rightButtonTitle = @"Stop";
	
	// add the viewController to the view hierarchy, e.g. if we're in the app delegate
	self.window.rootViewController = self.viewController;
	
    // Run it.
    [self.viewController startScrolling];
```

**There are a number of delegate methods you can optionally implement: **
```objective-c
	-(void)tutorialControllerLeftButtonPressed:(ICETutorialController *)controller;
	-(void)tutorialControllerRightButtonPressed:(ICETutorialController *)controller;
	-(void)tutorialController:(ICETutorialController *)controller willTransitionFromPageIndex:(NSUInteger)fromPage toPageIndex:(NSUInteger)toPage;
	-(void)tutorialController:(ICETutorialController *)controller didTransitionFromPageIndex:(NSUInteger)fromPage toPageIndex:(NSUInteger)toPage;
	-(void)tutorialControllerReachedLastPage:(ICETutorialController *)controller;
```

Originally developed by [@Icepat](https://github.com/icepat/) (email patrick.trillsam\_at\_gmail.com if you have questions).


###License :

The MIT License

Copyright (c) 2013 Patrick Trillsam - ICETutorial

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
