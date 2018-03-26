# otg-delivery-mobile

This project is the mobile client that users interact with to make coffee orders and receive notifications to pick up coffee. As of now, it consists of some data models that can ask our server for information on pending requests and view controllers that handle user interactions.

**OrderViewController.swift:** handles the user pressing the "Caffeinate me" button. Handles notifications and location tracking as well, which should be moved either to App Delegate or some better place that I'm not aware of.
**CoffeeRequest.swift:** data model that represents a request. Swift lets us use the Codable interface to create these objects from JSON responses in a seemingly but apparently sound way.
**OrderModalViewController.swift:** when user presses "Caffeinate me," this modal is brought up and allows them to input their coffee preferences.
**LoginViewController.swift:** logic for logins. No authentication involved.
