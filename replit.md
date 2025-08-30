# Overview

Drishti is a comprehensive fitness and sports assessment platform that helps athletes track their performance, complete fitness tests, and compete on leaderboards. The application provides BMI tracking, sport-specific skill assessments, badge systems, and personalized fitness recommendations. Built with a React frontend and Node.js/Express backend, it uses Replit's authentication system and maintains user profiles with detailed fitness metrics.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Full-Stack Application Structure
The project follows a monorepo structure with separate client and server directories, plus shared schemas. The architecture supports both development and production environments with proper build processes.

**Frontend Architecture:**
- React with TypeScript for type safety
- Vite as the build tool and development server
- Wouter for lightweight client-side routing
- TanStack Query for server state management and caching
- React Hook Form with Zod validation for form handling
- Tailwind CSS with shadcn/ui component library for styling
- Custom design system with CSS variables for theming

**Backend Architecture:**
- Express.js server with TypeScript
- RESTful API design with structured route handlers
- Middleware for logging, error handling, and authentication
- Drizzle ORM for database operations with type-safe queries
- Repository pattern through storage abstraction layer

**Database Design:**
- PostgreSQL database with Neon serverless hosting
- Session-based authentication storage
- User profiles with fitness metrics (BMI, fitness level, points)
- Test results tracking for both general fitness and sport-specific assessments
- Badge and achievement system
- Leaderboard and ranking functionality

**Authentication System:**
- Replit's OpenID Connect (OIDC) authentication
- Passport.js integration for session management
- PostgreSQL session storage with connect-pg-simple
- User profile management with automatic session updates

**State Management:**
- TanStack Query for server state caching and synchronization
- React Hook Form for form state management
- Context providers for global UI state (toasts, mobile detection)

**Component Architecture:**
- Modular component structure with ui components in separate directory
- Layout components for consistent page structure
- Custom hooks for authentication, mobile detection, and toast notifications
- Type-safe prop interfaces throughout

## API Design Patterns
The backend implements a clean separation between route handlers, business logic, and data access. Routes handle HTTP concerns, storage layer abstracts database operations, and shared schemas ensure type consistency between frontend and backend.

**Route Organization:**
- Authentication routes for user management
- Profile management with BMI calculations
- Fitness and sport test recording
- Badge assignment and retrieval
- Leaderboard queries with ranking algorithms

**Data Validation:**
- Zod schemas shared between client and server
- Runtime validation on API endpoints
- Type-safe database operations with Drizzle

# External Dependencies

## Authentication & User Management
- **Replit Authentication**: OpenID Connect integration for user login and session management
- **Passport.js**: Authentication middleware with OpenID Connect strategy

## Database & Storage
- **Neon Database**: Serverless PostgreSQL hosting for production
- **Drizzle ORM**: Type-safe database operations and query building
- **connect-pg-simple**: PostgreSQL session store for user sessions

## Frontend Libraries
- **shadcn/ui**: Component library built on Radix UI primitives
- **Radix UI**: Headless UI components for accessibility
- **TanStack Query**: Server state management and caching
- **React Hook Form**: Form state management with validation
- **Zod**: Runtime type validation and schema definition

## Development Tools
- **Vite**: Fast development server and build tool
- **TypeScript**: Static type checking
- **Tailwind CSS**: Utility-first CSS framework
- **ESBuild**: Fast JavaScript bundler for production builds

## Utility Libraries
- **date-fns**: Date manipulation and formatting
- **class-variance-authority**: Utility for managing component variants
- **clsx**: Conditional className utility
- **memoizee**: Function memoization for performance optimization