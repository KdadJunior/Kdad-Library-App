**Kdad Library 📚**

**Table of Contents**

Overview
Product Spec
Wireframes
Schema

**Overview**

*Description*
Kdad Library is a beautifully crafted iOS app that lets users browse, search, and view detailed information about popular books using the Google Books API. It features rich UI, a dynamic detail screen with a backdrop, metadata, and favoriting system, and a powerful search functionality to explore titles.

## https://www.loom.com/share/12440b6f376b4f789c2271c2ad66e3d1?sid=bfce1ec7-61fe-4079-85a3-f778b556aa42

*App Evaluation*
Category: Books / Reference
Mobile: iOS
Story: Empowers users to discover and read more about trending books with an elegant user interface.
Market: Readers, students, book lovers, and educators.
Habit: Encourages daily usage by making book discovery simple and interactive.
Scope: MVP includes browsing, viewing details, favoriting books, and searching. Future versions may support book previews or library syncing.

**Product Spec**

1. User Stories
Must-Have
Users can view a list of popular books.
Users can tap a book to see its details.
Users can favorite a book and see that reflected via a heart icon.
Users can search books using a search bar.

Optional Nice-to-Have
Persist favorited books across app launches.
Show preview link to read a sample in browser.
Swipe to unfavorite a book.
Add categories or genres.

2. Screen Archetypes
Book List Screen
Display popular books in a scrollable list.
Each cell shows the book's title, description, and thumbnail.
Includes a search bar and header ("Kdad Library").

Book Detail Screen
Shows backdrop image, cover, metadata (title, author, release date).
Allows favoriting/unfavoriting.
Displays description.
“Open Book” button links to preview.

3. Navigation
Flow Navigation
Book List Screen
↳ Tap on a book → Book Detail Screen

Book Detail Screen
↳ Tap back → Book List Screen

##  App Design Sketch

Below is the hand-drawn wireframe of the app’s navigation and key screens:

![App Wireframe](https://i.ibb.co/SXyhjYh3/Cam-Scanner-08-12-2025-13-15-1.jpg)

BONUS: Digital Mockups & Interactive Prototype
 Add Figma/XD mockups if available.

**Schema**

This section will be completed in Unit 9.

Models
Book

Property	Type	Description

id	String	Unique ID of the book

title	String	Book title

authors	Array	List of authors

description	String	Book overview

publishedDate	String	Release date

imageLinks	Object	Thumbnail and backdrop images

previewLink	String	URL to preview the book

averageRating	Float	Optional rating

Networking
Screen	Request Type	Endpoint	Description
Book List Screen	GET	https://www.googleapis.com/books/v1/volumes?q=bestsellers	Fetch list of popular books
