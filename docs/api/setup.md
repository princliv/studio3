# API setup & conventions

## Postman environment

Create a Postman **Environment** (e.g. "Backend Local") with:

| Variable      | Initial / Current value   | Description                    |
|---------------|----------------------------|--------------------------------|
| `baseUrl`     | `http://localhost:9000`    | API base URL (no trailing `/`) |
| `accessToken` | *(leave empty)*            | Set automatically after login/register |

Use `{{baseUrl}}` and `{{accessToken}}` in requests.

## Saving the access token

After **Login** or **Register**, the response body contains `data.accessToken`. To reuse it for protected routes:

1. Open the **Login** (or **Register**) request in Postman.
2. Go to the **Tests** tab.
3. Add:

```javascript
var json = pm.response.json();
if (json.data && json.data.accessToken) {
  pm.environment.set("accessToken", json.data.accessToken);
}
```

4. Run Login/Register; `accessToken` will be set in your environment.

## Cookies (refresh / logout)

The server sets an httpOnly cookie `refreshToken` on **Login**, **Register**, and **Refresh**. Postman sends stored cookies automatically for the same domain.

- **Refresh:** **POST** `/api/auth/refresh` with no body and no auth header. The `refreshToken` cookie is sent automatically.
- **Logout / Logout-all:** Cookie is sent automatically if it was set earlier.

## Suggested auth testing flow

1. **GET** `{{baseUrl}}/` → Health check.
2. **POST** `{{baseUrl}}/api/auth/login` (or register) → Get token; use the Tests script above.
3. **POST** `{{baseUrl}}/api/auth/refresh` → New access token.
4. **POST** `{{baseUrl}}/api/auth/logout` or **POST** `{{baseUrl}}/api/auth/logout-all`.

## Response format

**Success:**

```json
{
  "success": true,
  "message": "<message>",
  "data": { ... }
}
```

**Error:**

```json
{
  "success": false,
  "message": "<error message>"
}
```

Common status codes: `200`/`201` success, `400` bad request, `401` unauthorized, `409` conflict, `429` too many requests, `500` server error.

## Protected routes

Send header:

```http
Authorization: Bearer {{accessToken}}
```

**Auth column legend** (used in quick reference):

- **Bearer** — `Authorization: Bearer {{accessToken}}` required
- **Optional Bearer** — works without a token; viewer-specific fields (`isLiked`/`isSaved`/`isFollowing`) when one is sent
- **Cookie** — send cookies (Postman does this automatically after login/register/refresh)

## Health check

**GET** `{{baseUrl}}/`

| | |
|--|--|
| **Method** | `GET` |
| **URL** | `{{baseUrl}}/` |
| **Headers** | *(none)* |
| **Body** | *(none)* |

**Example response (200):**

```json
{
  "message": "Studiothree Discover API running"
}
```
