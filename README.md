QuadCurveMenu is a menu with the same look as [the Path app's menu](https://path.com/)'s story menu.

Here is a [**declaration in my blog**](http://www.lunaapp.com/blog/?p=66) :)

---

**How To**:


Create the menu by setting up the menu items:

	UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
	UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
	UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    QuadCurveMenuItem *starMenuItem1 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];
	QuadCurveMenuItem *starMenuItem2 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];

Then, setup the menu and options:

	QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.window.bounds [NSArray arrayWithObjects:starMenuItem1, starMenuItem2]];
	menu.delegate = self;
	[self.window addSubview:menu];

You can also use menu options:

to locate the center of "Add" button:
	menu.startPoint 

to set the rotate angle:
	menu.rotateAngle 

to set the whole menu angle:
	menu.menuWholeAngle 

to set the delay of every menu flying out animation:
	menu.timeOffset 

to adjust the bounce animation:
	menu.farRadius
	menu.nearRadius

to set the distance between the "Add" button and Menu Items:
	menu.endRadius

---

Twitter: [@LeveyZhu](https://twitter.com/#!/LeveyZhu) 

Sina Weibo: [@SORA-Levey](http://weibo.com/leveyzhu) 

Thanks for [pashields](https://github.com/pashields) providing the [youtube demo](http://www.youtube.com/watch?v=vddaYMtETjo) :)

Thanks for [acoomans](https://github.com/acoomans/QuadCurveMenu) for the options.


![screenshots](http://k.minus.com/ib1kHc4lnLB8bd.gif) ![screenshots](http://k.minus.com/iovTFVTQQ192K.gif) ![screenshots](http://k.minus.com/i4BrO2tfCJxzk.gif)
