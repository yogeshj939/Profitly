# Profitly
A backend service for Profitly — a platform for managing and tracking profits

### Database Migrations
- All schema changes live in `src/main/resources/db/migration`.
- Migrations run automatically on startup via Flyway.
- To reset DB:
  docker-compose down -v
  docker-compose up