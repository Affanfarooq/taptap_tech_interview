# Product Management Dashboard

A responsive Product Management Dashboard built with Flutter, designed for Mobile, Tablet, and Desktop screens.

## Live Demo
Hosting URL: https://ubms-app.web.app

## How to Run the Project

### Prerequisites
- Flutter SDK (v3.10.3 or higher)
- Chrome or any modern web browser
- Firebase CLI (for deployment only)

### Setup and Execution
1. Clone the repository:
   git clone https://github.com/Affanfarooq/taptap_tech_interview
   cd taptap_tech_interview

2. Install dependencies:
   flutter pub get

3. Run the application:
   flutter run -d chrome

4. Build for production:
   flutter build web --release

## Folder Structure and Reasoning

The project follows Clean Architecture principles to ensure code is organized and easy to maintain.

lib/
├── core/                   # Shared utilities, themes, and global widgets
│   ├── constants/          # API endpoints and constants
│   ├── router/             # Routing configuration
│   ├── theme/              # Light/Dark mode themes
│   ├── utils/              # Responsive logic and logging
│   └── widgets/            # Reusable UI components
├── features/               # Modular feature structure
│   └── product/            # Main product management feature
│       ├── data/           # Models and Repositories
│       ├── domain/         # UseCases and Business Logic
│       └── presentation/   # UI logic (Bloc/Cubit, Pages, Widgets)
└── main.dart               # Entry point of the app

### Reasoning:
- Separation of Concerns: Business logic is kept separate from UI and API implementation.
- Scalability: New features can be added without modifying existing ones.
- Maintainability: Clear boundaries between layers make debugging easier.

## Libraries Used

- flutter_bloc: State management for the application.
- go_router: Declarative routing and deep linking.
- http: Handling API requests.
- google_fonts: Custom typography.
- logger: Console logging for better debugging.
- equatable: Efficient object comparisons for state updates.
- json_annotation: Automated JSON mapping.

## Features Implemented

### Core Features
- Authentication: Mock login (admin / 1234) with protected routes.
- Product List: Paginated list with search and multi-layer filtering (Category and Stock status).
- CRUD Actions: Add, Edit, and Delete products with immediate UI feedback.
- Detailed View: Dynamic product details page.

### Responsive Design
- Desktop: Features a persistent sidebar and an optimized data table with horizontal scroll support.
- Mobile/Tablet: Uses a collapsible drawer and a responsive grid layout (2-column on mobile).
- Theme Support: Full integration of Light and Dark modes.

### Performance and UX
- Infinite Scroll: Implemented for mobile and tablet grids.
- Pagination: Traditional pagination for desktop views.
- Smart State Management: Optimized data fetching to avoid redundant API hits.
- Input Handling: Responsive search and filter bar that adjusts based on screen width.
- Layout Safety: Prevention of UI overflows on narrow screens.
