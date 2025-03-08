<p align="center">
      <img src="https://i.ibb.co/qmqv7ZY/2024-04-13-17-42-50.png" width="200">
</p>

<p align="center">
   <img src="https://img.shields.io/badge/Engine-XCode v15.3-blueviolet">
   <img src="https://img.shields.io/badge/Version-v1.0-blue">
   <img src="https://img.shields.io/badge/License-MIT-green">
</p>

## About

The PET project for practicing the creation of interface elements and the practice of going through the stages of app placement in the Appstore.
Multi-user mode. Localization in three languages.Calculation of the bzhu data for the user.


**The project uses:**

* UITableViewController
* UserInterface
* segue
* custom TableViewCell
* localization
* delegation



### Terms of reference for the project:

The application contains two parts - the BZHU calculator and the result.
Multiple users can take turns using the app on the same device.
The user changes by clicking on the icon of the current user.
Editing the list of users is done via the side hiding menu.
When activating the side menu, other actions and interface elements are closed to the user.
The interface language is determined automatically depending on the selected device language.


![screenshot of sample](https://i.ibb.co/DfDxPxR/1734503008328-2.jpg)

## Documentation

### Models:

      Profile - the basic data model
      TeamMember - to display the development team

#### Managers:

      StorageManager - work with UserDefaults

### ViewControllers:

      ViewController - the main screen of the application
      HelpViewController - contains information about the calculation method
      GreetingViewContoller - the screen when adding a new user
      MenuViewController - drop-down side menu
      TeamViewController - screen with the development team

### Cells:
      ImageCollectionViewCell - to select an icon
      TeamViewCell - information about the developer's team member
  

## Developers

- [Irina Muravyova](https://github.com/IrinaMuravyova)

## License
Project CalorieCalculation is distributed under the MIT license.
