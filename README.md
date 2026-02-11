# Library Management System

A SwiftUI-based iOS application for managing library books, members, and loan tracking with Core Data persistence.

## Features

- 📚 **Book Management**: Add, view, and organize books by categories
- 👥 **Member Management**: Track library members and their information
- 📖 **Loan Tracking**: Borrow and return books with due date management
- ⚠️ **Overdue Detection**: Automatic detection and marking of overdue loans
- 🔍 **Search & Filter**: Search books and filter by categories
- 📊 **Loan History**: View active, returned, and overdue loans

## Screenshots

### Books View
*Browse and search through the library's book collection*

![Books View](https://github.com/UND34TAK3R/LibraryManager/blob/main/Campus%20Library%20Borrowing%20Tracker/Screenshots/books-view.png)

### Members View
*Manage library members*

![Members View](screenshots/members-view.png)

### Borrow View
*Add new loans to members*

![Borrow View](screenshots/borrow-view.png)

### Loans View
*Track active, returned, and overdue loans*

![Loans View](screenshots/loans-view.png)

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Setup

### 1. Core Data Model

The project uses Core Data with the following entities:

**Book**
- `id`: UUID
- `title`: String
- `author`: String
- `isbn`: String? (optional)
- `addedAt`: Date
- `isAvailable`: Boolean
- `category`: Relationship to Category

**Member**
- `id`: UUID
- `name`: String
- `email`: String
- `joinedAt`: Date

**Loan**
- `id`: UUID
- `borrowedAt`: Date
- `dueAt`: Date
- `returnedAt`: Date? (optional)
- `status`: String (optional)
- `books`: Relationship to Book
- `members`: Relationship to Member

**Category**
- `id`: UUID
- `name`: String
- `books`: Relationship to Book (one-to-many)

### 2. Build and Run

1. Select a simulator or physical device
2. Press `Cmd + R` to build and run the application

## Key Components

### LibraryHolder (ObservableObject)

The main view model that manages:
- Books, members, loans, and categories arrays
- Search and filter functionality
- CRUD operations for all entities
- Overdue loan detection

### Core Views

**BooksView**
- Grid layout displaying all books
- Search functionality
- Category filtering
- Add new books

**MembersView**
- List of library members
- Add new members
- Navigate to member's loan history

**AddLoanMemberView**
- Book selection for borrowing
- Category filtering
- Search books
- Disable unavailable books

**LoansView**
- Active loans section
- Returned loans section
- Overdue loans section (highlighted in red)
- Automatic overdue detection on view appear

**MemberLoansView**
- Member-specific loan history
- Active loans with return functionality
- Past loan records

## Usage

### Adding a Book

1. Navigate to Books tab
2. Tap the `+` button
3. Fill in book details (title, author, ISBN, category)
4. Save

### Adding a Member

1. Navigate to Members tab
2. Tap the `+` button
3. Fill in member details (name, email)
4. Save

### Borrowing a Book

1. Navigate to Members tab
2. Select a member
3. Tap the `+` button in their loans view
4. Browse or search for a book
5. Tap "Borrow" on the desired book
6. Book is now loaned to the member

### Returning a Book

1. Navigate to Member's Loans view
2. Find the active loan
3. Tap the "Return" button
4. Loan is marked as returned and book becomes available

### Viewing Overdue Loans

1. Navigate to Loans tab
2. Overdue loans are automatically detected and shown in the "Overdue Loans" section
3. Overdue loans are highlighted in red

## Features in Detail

### Search & Filter
- Real-time search across book titles, authors
- Filter books by category
- Responsive UI updates

### Loan Management
- Due dates calculated automatically
- Automatic overdue detection
- Loan history tracking
- Prevent borrowing unavailable books

### Data Persistence
- All data stored using Core Data
- Automatic save on changes
- Relationships maintained between entities

## Customization

### Changing Loan Duration

In `LibraryHolder.swift`, modify the `borrowBook` function:

```swift
loan.dueAt = Calendar.current.date(byAdding: .day, value: 14, to: Date()) // Change 14 to desired days
```
