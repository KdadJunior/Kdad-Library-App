# Kdad Library 📚

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Product Spec](#product-spec)
- [App Design Sketch](#app-design-sketch)
- [Schema](#schema)
- [Demo](#demo)
- [License](#license)

---

## Overview

**Kdad Library** is a beautifully crafted **iOS application built with UIKit programmatically**. It lets users browse, search, and view detailed information about popular books using the **Google Books API**.  

It features a **polished UI design**, interactive detail pages with metadata and backdrop images, a **favoriting system**, and theme customization with a **Theme Manager**.

📹 **Demo:**  
[Watch on Loom](https://www.loom.com/share/12440b6f376b4f789c2271c2ad66e3d1?sid=bfce1ec7-61fe-4079-85a3-f778b556aa42)

---

## Features

- 📚 **Book List & Search**
  - View trending and popular books
  - Dynamic search functionality with live results
  - Scrollable list with book cover, title, and description

- 🖼️ **Book Detail View**
  - Backdrop image and cover art
  - Metadata (title, author, release date, rating)
  - Description text
  - *Open Book* button → preview in browser

- ❤️ **Favoriting**
  - Toggle heart icon to favorite/unfavorite books
  - Persistent favorites across navigation
  - (Future: persistence across launches)

- 🎨 **Theme Manager**
  - Built-in **dark mode / light mode** toggle
  - Custom **deep vanilla light theme** with user preference saving
  - Parallax and motion effects with “Reduce Motion” toggle

- 🛠️ **UIKit Programmatic UI**
  - No Storyboards — fully programmatic UIKit
  - Auto Layout constraints
  - Clean MVC architecture
  - Navigation Controller with custom back button support

- 🚀 **Performance & Polish**
  - Smooth scrolling and optimized image loading with **Nuke**
  - Professional app structure for App Store readiness
  - Future support for categories, genres, and library sync

---

## Product Spec

### 1. User Stories

**Must-Have**
- Users can view a list of popular books  
- Users can search for books with a search bar  
- Users can tap a book to see details  
- Users can favorite/unfavorite books with a heart icon  

**Nice-to-Have**
- Persist favorited books across launches  
- Show preview links to read samples in browser  
- Swipe to unfavorite a book  
- Browse by category or genre  

---

### 2. Screen Archetypes

**📖 Book List Screen**
- Scrollable list of popular books  
- Header: *Kdad Library*  
- Search bar at the top  

**📘 Book Detail Screen**
- Backdrop + cover image  
- Title, author, release date, and rating  
- Description  
- Favorite toggle (heart icon)  
- *Open Book* → preview link  

---

### 3. Navigation

- **Book List Screen** → Tap book → **Book Detail Screen**  
- **Book Detail Screen** → Back → **Book List Screen**  

---

## App Design Sketch

Hand-drawn wireframe of app navigation and key screens:

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

## Demo

👉 [View Demo on Loom](https://www.loom.com/share/12440b6f376b4f789c2271c2ad66e3d1?sid=bfce1ec7-61fe-4079-85a3-f778b556aa42)

---

## License

This project is licensed under the **MIT License**.  

