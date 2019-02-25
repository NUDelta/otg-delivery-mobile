# otg-delivery-mobile

This project is the mobile client that users interact with to make food orders and receive notifications to pick up food. As of now, it consists of some data models that can ask our server for information on pending requests and view controllers that handle user interactions.

**OrderViewController.swift:** view controller for the main page of the application, where users can make new requests and see their active requests and tasks. Handles notifications and location tracking as well.

**CoffeeRequest.swift:** data model that represents a request. Swift lets us use the Codable interface to create these objects from JSON responses.

**Item.swift:** data model that represents a menu item, that can be requested.

**User.swift:** data model that represents a user.

**Logging.swift:** data model that represents a log entry. 

**CoffeeRequest.swift:** data model that represents a request. Swift lets us use the Codable interface to create these objects from JSON responses.

**OrderModalViewController.swift:** view controller to submit an order.

**LoginViewController.swift:** logic for logins. No authentication involved.

**HelperLocationFormViewController.swift:** view controller that asks helper where they are headed when they accept a task.

**MeetingPointTableViewController.swift:** view controller for requesters to submit potential meeting points they are willing to meet at.

**AllRequestsTableViewController.swift:** view controller for users to see all available tasks in the system.

**TaskConfirmationViewController.swift:** view controller for potential helpers to see the details of the task they are being asked to complete. 

**RequestStatusTableViewController.swift:** view controller for table view that displays user's current requests.

**AcceptedRequestsTableViewController.swift:** view controller for table view that displays user's active tasks.
