# otg-delivery-mobile

This project is the mobile client that users interact with to make food orders and receive notifications to pick up food. As of now, it consists of some data models that can ask our server for information on pending requests and view controllers that handle user interactions.

## View Controllers

**OrderViewController.swift:** View controller for the main page of the application, where users can view nearby open requests and make new requests. Handles notifications and location tracking as well.

**LocationSelectionViewController.swift:** View Controller to select a request's pickup location.

**ItemSelectionViewController.swift:** View Controller to select a request's item.

**PotentialLocationViewController.swift:** Interface for requesters to place their present and future locations and timeframes for a request.

**RequestConfirmationViewController.swift:** View Controller for requesters to confirm order placement.

**AcceptConfirmationViewController.swift:** View Controller for helpers to accept requests and place meeting points.

**AcceptedViewController.swift:** Screen shown to helpers and requesters as an order is in progress.

**FeedbackViewController.swift:** Screen for in-app feedback for the SQ19 study.

**LoginViewController.swift:** Logic for user logins. No authentication involved.

## Data Models

**CoffeeRequest.swift:** Data model that represents a request.

**Feedback.swift:** Data model that represents a user's feedback.

**Item.swift:** Data model that represents a menu item, that can be requested.

**LocationUpdate.swift:** Data model that represents a user's location and direction.

**MeetingPoint.swift:** Data model that represents a meeting point, whether a potential point with a radius before a request is accepted or one belonging to a request after acceptance.

**User.swift:** Data model that represents a user.
