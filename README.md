# FamilyPlanner

![FamilyPlanner logo](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/Icon-76%402x.png)

An application to keep your family or any group of people in sync.

## API
The API for **FamilyPlanner** is written in Ruby on Rails and the sourcecode can be found [here](https://github.com/mileandra/familyPlanner-api)

The API is currently hosted on Heroku at the endpoint *https://evening-badlands-8128.herokuapp.com/api/*

## Usage

All frameworks and configuration are included in the XCode Project, so you should be able to just build and run it in the simulator or on a physical device.
The application is written in Swift 2.

### Login
![Login](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/login.png) 
Whenever you did log out of the app or if it is the first time you are opening it, you will be asked to log into the application with an existing account. If you do not have an account, you can press the *Sign Up* button to create a new account.

### Sign Up
![Sign Up](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/sign_up.png)
On the sign up screen you can create a new account. All fields are required and you will see an error message if you leave any of the fields blank.
The keyboard will disappear if you tap anywhere outside of the keyboard.

### Create or join family
When you sign in or sign up for the first time and you are not assigned to a family yet, you will be able to either create a new family (or group), or join an existing one by entering an invitation code.

### Dashboard
![Dashboard](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/dashboard.png)
Once you are signed in and assigned to a family, you will be presented with your dashboard on every application launch. It will tell you the number of uncompleted todos and unread messages.
You will also see a hamburger-icon at the top to access the side menu and toggle quickly between views. 
The same menu can be opened and closed by swiping to the left or right with your finger.

![Menu](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/menu.png)

### Todos
![Todos](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/todo_list.png)
In the todo view you can create new todos by clicking the "new" button in the top header, or mark existing todos as completed.

### Messages
![Message](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/new_message.png)
To stay in sync with your group, you can send email-like messages with a subject that other members can respond to. Messages are sent to the whole group (like announcements) - it is currently not possible to send a message to specific targets.

### Manage Group
![Manage Group](https://dl.dropboxusercontent.com/u/3950128/FamilyPlanner/manage_group.png)
This screen is only available for family creators (which makes them admins). You can create new invitation codes for your family to invite other members and share that code through an Activity Panel.
You are also able to remove any members, as long as it is not your own account.

## Not Included
While the application is useful as it is, there are a couple things still on the todo-list, that are not yet implemented for specific reasons:

### Push Notifications
Usually an app like this would show a new notification whenever a new todo or message is posted. Unfortunately this would have required a private developer account to be set up and I did not want to sign up for a private subscription and neither use a company one.

### Live Update
For the messages, it would have been great if they would live update, but as this is mainly a submission and private project, I had to draw a line somewhere. Setting up a Redis Server would have been nice, but not something to consider at the moment. Maybe someday, somewhen.

### Additional types
Shopping lists, birthdays, expenses - those would all have been great, but as stated above, I had to draw a line at some point. I will definitely continue to work on the project and maybe set up some of them in the future.


## Sync
The application uses CoreData to cache data and will be able (after login) to perform basic tasks (writing messages, creating or editing todos) in offline mode. Those items will be synced to the server whenever an internet connection is available again.
As there is currently no Push-Notification-Implementation, nor a live-update server, the application will try to sync every 60 seconds. To prevent too much data going back and forth, it will save the last sync time for every entity and the api will only return items that were updated after the last sync time.