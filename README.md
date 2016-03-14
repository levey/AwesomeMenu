### DO NOT USE IT TO COPY PATH!

---

AwesomeMenu is a menu with the same look as the story menu of [Path](https://path.com/).

---

![demo](https://github.com/brennanMKE/AwesomeMenu/raw/master/AwesomeMenu.gif)

**How To**:


Create the menu by setting up the menu items:

	UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
	UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
	UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
	AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
	// the start item, similar to "add" button of Path
	AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                                       highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
                                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];

Then, setup the menu and options:

	AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.window.bounds startItem:startItem optionMenus:[NSArray arrayWithObjects:starMenuItem1, starMenuItem2]];
	menu.delegate = self;
	[self.window addSubview:menu];

You can also use menu options:

to locate the center of "Add" button:

	menu.startPoint = CGPointMake(160.0, 240.0);

to set the rotate angle:

	menu.rotateAngle = 0.0;

to set the whole menu angle:

	menu.menuWholeAngle = M_PI * 2;

to set the delay of every menu flying out animation:

	menu.timeOffset = 0.036f;

to adjust the bounce animation:

	menu.farRadius = 140.0f;
	menu.nearRadius = 110.0f;

to set the distance between the "Add" button and Menu Items:

	menu.endRadius = 120.0f;

---

Twitter: [@LeveyZhu](https://twitter.com/#!/LeveyZhu)

Sina Weibo: [@LeveyZhu](http://weibo.com/leveyzhu)

Thanks for [pashields](https://github.com/pashields) providing the [youtube demo](http://www.youtube.com/watch?v=vddaYMtETjo) :)

Thanks for [acoomans](https://github.com/acoomans/QuadCurveMenu) for the options.
