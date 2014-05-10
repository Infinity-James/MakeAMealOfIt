# Make A Meal Of It

Make a Meal Of It is an app that is to be used by anybody who wants to find a recipe in as specific or general a manner as they wish. It uses the Yummly database to access over a million recipes, and filters the results cleverly to provide the user with a recipe that suits their needs.

#### Why Open Source It?

The app works at a level where I would be happy to have people using it on a dailt basis. It was on the App Store for a period of a few months until the server costs were at a point where it was not worth it to me to keep it available. The people who had bought it could keep it, and still use it, but I removed it so that it was no longer available to be purchased. 

I had made the app with the intention of helping people with specific dietary requirements, as well as with the goal to get a full time job. After getting a permanent position at a good company I felt it best to remove the app and now I would like to give the code to anybody who may find it helpful.

#### Quality of Code

The code is certainly not a good reflection of my own standards at this point in time. I began development a year ago, and a lot has changed since then. In the source you will find questionable decisions when it comes to the responsibility of certain classes, odd naming of classes, and a few rather long and convoluted methods.

As I say, I need to point out that I am aware of 99% of the places where I went wrong in creating this app.

## Downloading & Using the App

- Clone the project or download it as a .zip. 
- Create an app at [Yummly’s Developer website](https://developer.yummly.com)
- In the file YummlyAPIKeys.h declare you unique ID’s like so:
```objc
//	this should be the app ID you get from developer.yummly.com when you register your app
static NSString *const kYummlyAppID = @“HERE”;
//	this should be the app key you get from developer.yummly.com when you register your app
static NSString *const kYummlyAppKey = @“HERE”;
//	unfortunately, because I did this poorly, you need to put the app ID and app key here as well
static NSString *const kYummlyAuthorisationURLExtension	= @"_app_id=YOUR_APP_ID_HERE&_app_key=YOUR_APP_KEY_”HERE
```
- You will then be able to run the app on any iPhone device running iOS 7 and above.

## Contributing

Contributions are not only welcome, but encouraged. This app is mainly here as an example of a fairly advanced app that uses the REST API to communicate with a large database, and display the results to the user. However, if you feel that you have something to add, or improve, or even if you want to optimise or clean up some of the code, please feel free to do a Pull Request.

* `Fork it`_
* Create a topic branch to house your changes
* Get all of your commits in the new topic branch
* Submit a `pull request`_

.. _pull request: http://help.github.com/pull-requests/
.. _Fork it: http://help.github.com/forking/
