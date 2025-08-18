# Kdad Library 📚

## Table of Contents
- [Overview](#overview)
- [Product Spec](#product-spec)
- [App Design Sketch](#app-design-sketch)
- [Schema](#schema)
- [Demo](#demo)
- [License](#license)

---

## Overview

**Kdad Library** is a beautifully crafted iOS app that lets users browse, search, and view detailed information about popular books using the **Google Books API**.  

✨ Features:
- Rich and modern UI design
- Dynamic detail screen with backdrop and metadata
- Favoriting system with heart icon feedback
- Powerful search functionality for exploring titles

📹 **Demo:**  
[Watch on Loom](https://www.loom.com/share/12440b6f376b4f789c2271c2ad66e3d1?sid=bfce1ec7-61fe-4079-85a3-f778b556aa42)

---

### App Evaluation
- **Category:** Books / Reference  
- **Platform:** iOS  
- **Story:** Empowers users to discover and learn about trending books with an elegant interface.  
- **Market:** Readers, students, book lovers, educators.  
- **Habit:** Encourages daily usage by making book discovery simple and interactive.  
- **Scope:**  
  - MVP: Browsing, viewing details, favoriting books, and searching  
  - Future: Book previews, persistent favorites, syncing with user libraries  

---

## Product Spec

### 1. User Stories

**Must-Have**
- Users can view a list of popular books  
- Users can tap a book to see its details  
- Users can favorite a book (heart icon)  
- Users can search books with a search bar  

**Nice-to-Have**
- Persist favorited books across launches  
- Show preview links to read samples in browser  
- Swipe to unfavorite a book  
- Browse by category or genre  

---

### 2. Screen Archetypes

**📖 Book List Screen**
- Scrollable list of popular books  
- Each cell includes title, description, and thumbnail  
- Header: *Kdad Library*  
- Search bar at the top  

**📘 Book Detail Screen**
- Backdrop image + cover  
- Metadata: title, author, release date  
- Favorite / unfavorite toggle  
- Description  
- *Open Book* button → preview in browser  

---

### 3. Navigation

- **Book List Screen** → Tap a book → **Book Detail Screen**  
- **Book Detail Screen** → Back → **Book List Screen**  

---

## App Design Sketch

Below is the wireframe of the app’s navigation and key screens:

![App Wireframe](https://i.ibb.co/SXyhjYh3/Cam-Scanner-08-12-2025-13-15-1.jpg)

*(Bonus: add Figma/XD mockups if available)*

---

## Schema

### Models

**Book**
| Property       | Type     | Description                     |
|----------------|----------|---------------------------------|
| id             | String   | Unique ID of the book           |
| title          | String   | Book title                      |
| authors        | Array    | List of authors                 |
| description    | String   | Book overview                   |
| publishedDate  | String   | Release date                    |
| imageLinks     | Object   | Thumbnail & backdrop images     |
| previewLink    | String   | URL to preview the book         |
| averageRating  | Float    | Optional rating                 |

---

### Networking

| Screen            | Request Type | Endpoint                                                                 | Description                     |
|-------------------|--------------|-------------------------------------------------------------------------|---------------------------------|
| Book List Screen  | GET          | `https://www.googleapis.com/books/v1/volumes?q=bestsellers`             | Fetch list of popular books     |

---

## Demo

👉 [View Demo on Loom](https://www.loom.com/share/12440b6f376b4f789c2271c2ad66e3d1?sid=bfce1ec7-61fe-4079-85a3-f778b556aa42)

---

## License

This project is licensed under the **MIT License**.  

