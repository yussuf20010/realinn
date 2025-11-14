## RealN API Documentation

### Base URL
- All routes in `routes/api.php` are prefixed with `/api`.
  - Example: `https://your-domain.com/api/hotels`

### Authentication and Headers
- Protection modes:
  - API key middleware for public data: hotels, service providers, site settings
  - Session auth (`auth:web`) for user account endpoints (requires cookies)
  - Token guard (`auth:api`) only on `GET /api/user` (no token-issue endpoint implemented)

- API key
  - Header name: `X-API-KEY`
  - Env name: `API_KEY`
  - Set in `.env`: `API_KEY=your-strong-random-key`
  - Send with every request to API-key-protected endpoints

- Recommended headers
  - `Accept: application/json`
  - `Content-Type: application/json` (for requests with a JSON body)

### Endpoints

#### Site Settings
- GET `/api/site-settings` (API key required)
  - Headers: `X-API-KEY`
  - Query: none
  - 200 Response: `{ status: true, settings: { ... } }`
  - 404 Response: `{ status: false, message: "Settings not found" }`
  - Example:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" -H "Accept: application/json" \
      https://your-domain.com/api/site-settings
    ```

#### Hotels (API key required)
- Group prefix: `/api/hotels`

- GET `/api/hotels/states`
  - Query: optional `id` (country_id)
  - 200: `{ states: [...], cities: [...] }`

- GET `/api/hotels/cities`
  - Query: optional `id` (state_id)
  - 200: `[ { ...city }, ... ]`

- GET `/api/hotels`
  - Filters (optional): `title`, `location`, `category` (slug), `ratings`, `country`, `state`, `city`, `sort` in {`old`,`new`}, `page`
  - 200 keys: `seoInfo`, `currencyInfo`, `categories`, `vendors`, `countries`, `states`, `cities`, `bookingHours`, `featured_contents`, `hotels`, `total`, `perPage`, `currentPage`
  - Example:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" -H "Accept: application/json" \
      "https://your-domain.com/api/hotels?title=inn&location=NYC&ratings=4&page=1"
    ```

- GET `/api/hotels/search`
  - Filters (optional): `title`, `location_val`, `category`, `ratings`, `stars`, `checkInDates` (YYYY-MM-DD), `checkInTimes` (HH:mm), `hour` (int), `country`, `state`, `city`, `sort` in {`new`,`old`,`starhigh`,`starlow`,`reviewshigh`,`reviewslow`}, `page`
  - 200 keys: `currencyInfo`, `featured_contents`, `hotels`, `total`, `perPage`, `currentPage`

- GET `/api/hotels/{slug}/{id}`
  - Path: `slug` string, `id` numeric
  - 200 keys: `hotel`, `vendor`, `userName`, `hotelImages`, `hotelCounters`, `reviews`, `numOfReview`, `rooms`, `totalRooms`
  - 404: `{ error: "Hotel not found" }`

#### Service Providers (API key required)
- Group prefix: `/api/service-providers`

- GET `/api/service-providers/states`
  - Query: optional `id` (country_id)
  - 200: `{ states: [...], cities: [...] }`

- GET `/api/service-providers/cities`
  - Query: optional `id` (state_id)
  - 200: `[ { ...city }, ... ]`

- GET `/api/service-providers`
  - Filters (optional): `title`, `location`, `category`, `ratings`, `country`, `city`, `min_price`, `max_price`, `skills` (csv or array), `sort` in {`new`,`old`,`rating_high`,`rating_low`,`price_high`,`price_low`,`orders_high`,`orders_low`}, `page`
  - 200 keys: `categories`, `countries`, `cities`, `skills`, `featured_providers`, `providers`, `total`, `perPage`, `currentPage`

- GET `/api/service-providers/search`
  - Filters (optional): as above plus `response_rate`, `delivery_rate`, `verified_only`, `available_only`
  - 200 keys: `featured_providers`, `providers`, `total`, `perPage`, `currentPage`

- GET `/api/service-providers/{id}`
  - 200 keys: `provider` (with relations), `related_providers`, `statistics`
  - 404: `{ error: "Service provider not found" }`

- GET `/api/service-providers/{id}/services`
  - 200 keys: `provider`, `services`, `total_services`

- GET `/api/service-providers/{id}/reviews`
  - 200 keys: `provider`, `reviews` (paginated)

- GET `/api/service-providers/{id}/portfolio`
  - 200 keys: `provider`, `portfolio` (paginated)

- POST `/api/service-providers/{id}/check-availability`
  - JSON body: `date` (YYYY-MM-DD, required), `service_id` (optional)
  - 200: `{ available: boolean, available_slots: ["09:00", ...], is_holiday: boolean }`

#### User (session-based unless noted)
- Group prefix: `/api/user`

Public endpoints:
- GET `/api/user/login` -> `{ seoInfo, googleRecaptchaStatus, facebookLoginStatus, googleLoginStatus, digitalProductStatus }`
- POST `/api/user/login` -> body `{ username, password }` -> `{ message, user, redirect }` (sets session cookie)
- GET `/api/user/forget-password`
- POST `/api/user/forget-password` -> body `{ email }`
- POST `/api/user/reset-password` -> body `{ new_password, new_password_confirmation }`
- GET `/api/user/signup`
- POST `/api/user/signup` -> body `{ username, email, password, password_confirmation }`
- Social: `/api/user/login/facebook`, `/api/user/login/facebook/callback`, `/api/user/login/google`, `/api/user/login/google/callback`

Authenticated via session cookie (`auth:web`):
- GET `/api/user/dashboard`
- GET `/api/user/profile`
- POST `/api/user/profile`
- POST `/api/user/password`
- GET `/api/user/room-wishlist`
- GET `/api/user/hotel-wishlist`
- POST `/api/user/add-wishlist/hotel/{id}`
- DELETE `/api/user/remove-wishlist/hotel/{id}`
- POST `/api/user/add-wishlist/room/{id}`
- DELETE `/api/user/remove-wishlist/room/{id}`
- GET `/api/user/bookings`
- GET `/api/user/bookings/{id}`
- POST `/api/user/logout`

Token guard (`auth:api`):
- GET `/api/user` with header `Authorization: Bearer {api_token}` -> returns authenticated user
- Note: No token issuance endpoint is present. Consider adding one or adopting Sanctum/Passport for mobile.

### Request & Response Examples

Hotels list:
```bash
curl -H "X-API-KEY: YOUR_API_KEY" -H "Accept: application/json" \
  "https://your-domain.com/api/hotels?title=inn&ratings=4&page=1"
```

Service provider availability:
```bash
curl -X POST -H "X-API-KEY: YOUR_API_KEY" -H "Content-Type: application/json" \
  -d '{ "date": "2025-11-05", "service_id": 42 }' \
  https://your-domain.com/api/service-providers/17/check-availability
```

User login (session-based):
```bash
curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
  -c cookies.txt -d '{ "username": "demo", "password": "secret" }' \
  https://your-domain.com/api/user/login
```

Auth:API example (requires `api_token` on the user):
```bash
curl -H "Authorization: Bearer USER_API_TOKEN" \
  https://your-domain.com/api/user
```

### Notes for Mobile Integration
- Provide the mobile team with:
  - Base URL: `https://your-domain.com/api`
  - Header names and values:
    - `X-API-KEY: {value of .env API_KEY}` for data endpoints
    - `Authorization: Bearer {api_token}` only if you add token auth for mobile
  - Standard headers: `Accept: application/json`, `Content-Type: application/json`
- Session-based endpoints require handling cookies if used directly from mobile.

## Mobile (Normal User) API Quick Reference

- Use base: `https://your-domain.com/api`
- Send headers where shown:
  - `X-API-KEY: YOUR_API_KEY` (required for hotels, service-providers, site-settings)
  - `Accept: application/json`
  - `Content-Type: application/json` for JSON bodies

### Public Data (browse without login)

- GET `/site-settings`
  - Request:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" -H "Accept: application/json" \
      https://your-domain.com/api/site-settings
    ```
  - Response (200):
    ```json
    { "status": true, "settings": { "logo": "https://.../assets/img/logo.png" } }
    ```

- GET `/hotels`
  - Example: `?title=inn&location=NYC&ratings=4&page=1`
  - Request:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" \
      "https://your-domain.com/api/hotels?title=inn&location=NYC&ratings=4&page=1"
    ```
  - Response (200):
    ```json
    { "featured_contents": [ { "id": 10, "title": "..." } ], "hotels": [ { "id": 12, "title": "..." } ], "total": 45 }
    ```

- GET `/hotels/{slug}/{id}`
  - Request:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" \
      https://your-domain.com/api/hotels/sample-hotel-xyz/123
    ```
  - Response (200):
    ```json
    { "hotel": { "id": 123, "title": "..." }, "rooms": [ { "id": 5, "title": "..." } ] }
    ```

- GET `/hotels/search`
  - Example: `?title=plaza&location_val=Jakarta&stars=5&page=1`

- GET `/hotels/states?id={country_id}`
- GET `/hotels/cities?id={state_id}`

- GET `/service-providers`
  - Example: `?title=photographer&city=Dubai&ratings=4&page=1`
  - Request:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" \
      "https://your-domain.com/api/service-providers?title=photographer&city=Dubai&ratings=4&page=1"
    ```
  - Response (200):
    ```json
    { "featured_providers": [ { "id": 7, "display_name": "..." } ], "providers": [ { "id": 9 } ], "total": 120 }
    ```

- GET `/service-providers/{id}`
  - Request:
    ```bash
    curl -H "X-API-KEY: YOUR_API_KEY" https://your-domain.com/api/service-providers/17
    ```
  - Response (200):
    ```json
    { "provider": { "id": 17, "display_name": "..." }, "statistics": { "average_rating": 4.8 } }
    ```

- GET `/service-providers/{id}/services`
- GET `/service-providers/{id}/reviews`
- GET `/service-providers/{id}/portfolio`

- POST `/service-providers/{id}/check-availability`
  - Request:
    ```bash
    curl -X POST -H "X-API-KEY: YOUR_API_KEY" -H "Content-Type: application/json" \
      -d '{ "date": "2025-11-05", "service_id": 42 }' \
      https://your-domain.com/api/service-providers/17/check-availability
    ```
  - Response (200):
    ```json
    { "available": true, "available_slots": ["09:00", "10:00"], "is_holiday": false }
    ```

### User (normal user)

- POST `/user/signup`
  - Request:
    ```bash
    curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
      -d '{ "username": "john", "email": "john@example.com", "password": "pass", "password_confirmation": "pass" }' \
      https://your-domain.com/api/user/signup
    ```
  - Response (201):
    ```json
    { "message": "A verification mail has been sent to your email address", "user": { "id": 1, "username": "john" } }
    ```

- POST `/user/login` (session cookie based)
  - Request:
    ```bash
    curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
      -c cookies.txt -d '{ "username": "john", "password": "pass" }' \
      https://your-domain.com/api/user/login
    ```
  - Response (200):
    ```json
    { "message": "Login successful", "user": { "id": 1 }, "redirect": "/api/user/dashboard" }
    ```

- Password
  - POST `/user/forget-password` body `{ "email": "john@example.com" }`
  - POST `/user/reset-password` body `{ "new_password": "pass", "new_password_confirmation": "pass" }`

Note: Endpoints under `/api/user` in the authenticated group require the session cookie from `/api/user/login`.


 