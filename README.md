# github-users

Just a simple list-detail application just to demonstrate my coding. It can be used to search for GitHub users by username without authentication at this search end-point e.g. username containing tom here:  https://api.github.com/search/users?q=tom 

Results can be viewed on a Grid/List layout, and a new page of results is added at the end of the list if there is one.
Results are persisted using Core Data, so even if killed from your device and relaunched - should restore the last set of results found.

The List/Grid Screen is implemented using UIKit, but just for fun I created the User Detail screen using SwiftUI as I love seeing the screen render on the canvas as I code.

## Installation

Simply download the source from here and open the workspace .xcworkspace file in Xcode.

These frameworks have been added via CocoaPods, but have also been added to git so you don't need to re-install yourself, but if you need to just run pod install.

* Kingfisher
* Lottie
* SwiftLint

It has been built in Xcode 11 for iOS 13, and been tested on iOS13.0 & iOS 13.5

## Screenshots

### Landing screen
![Image description](https://cathalfarrell.com/repo-images/github1.png)
### Landing screen with List of results
![Image description](https://cathalfarrell.com/repo-images/github2.png)
### Landing screen with Grid of results
![Image description](https://cathalfarrell.com/repo-images/github3.png)
### User Detail Screen via SwiftUI
![Image description](https://cathalfarrell.com/repo-images/github4.png)

## Warning
If you hit the search too often you may get a denied permission error from the GitHub server as it is rate-limited. I could have implemented Authentication to avoid this but it would have added so much extra work and time.
