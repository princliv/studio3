# Quick reference

Single-table endpoint index. See flow docs for request/response examples.

| Method | URL | Auth | Body |
|--------|-----|------|------|
| GET | `{{baseUrl}}/` | — | — |
| GET | `{{baseUrl}}/api/auth/username/check` | Optional | Query: `username`, `for_user_id=me` |
| POST | `{{baseUrl}}/api/auth/otp/generate` | — | `{ "email" }` |
| POST | `{{baseUrl}}/api/auth/otp/resend` | — | `{ "email" }` |
| POST | `{{baseUrl}}/api/auth/register` | — | `{ "username", "name", "email", "password", "otp", "phone"? }` |
| POST | `{{baseUrl}}/api/auth/login` | — | `{ "username", "password" }` — `username` is username or email |
| POST | `{{baseUrl}}/api/auth/refresh` | Cookie | — |
| POST | `{{baseUrl}}/api/auth/logout` | Cookie | — |
| POST | `{{baseUrl}}/api/auth/logout-all` | Bearer | — |
| POST | `{{baseUrl}}/api/auth/forget-password` | — | `{ "email" }` |
| POST | `{{baseUrl}}/api/auth/reset-password` | — | `{ "token", "newPassword" }` |
| GET | `{{baseUrl}}/api/user/me` | Bearer | — |
| PATCH | `{{baseUrl}}/api/user/me` | Bearer | Profile fields incl. `latitude`/`longitude`, `pronouns`, `bannerTargetType`/`Id`, `bannerAutoRule`, `messagePermission`, `profileVisibility` |
| PATCH | `{{baseUrl}}/api/user/me/username` | Bearer | `{ "username" }` |
| PATCH | `{{baseUrl}}/api/user/me/password` | Bearer | `{ "currentPassword", "newPassword" }` |
| POST | `{{baseUrl}}/api/user/me/email/request-change` | Bearer | `{ "newEmail" }` |
| POST | `{{baseUrl}}/api/user/me/email/confirm-change` | Bearer | `{ "newEmail", "otp" }` |
| PATCH | `{{baseUrl}}/api/user/me/notification-preferences` | Bearer | `{ "push"?, "dailyDigest"? }` |
| GET | `{{baseUrl}}/api/user/:username` | Optional Bearer | — (locked header if private + not following) |
| GET | `{{baseUrl}}/api/users/nearby` | Optional Bearer | Query: `lat`, `lng`, `radiusKm?`, `limit?` |
| PATCH | `{{baseUrl}}/api/user/me/role` | Bearer | `{ "role" }` |
| POST | `{{baseUrl}}/api/user/me/onboarding/*` | Bearer | See [user-profile flow](./flows/user-profile.md) |
| POST | `{{baseUrl}}/api/user/me/seller/*` | Bearer | See [user-profile flow](./flows/user-profile.md) |
| GET | `{{baseUrl}}/api/user/me/seller/analytics` | Bearer | — |
| GET | `{{baseUrl}}/api/user/me/saved/pieces` | Bearer | — |
| GET | `{{baseUrl}}/api/user/me/saved/posts` | Bearer | Saved scenes |
| GET/POST/PATCH/DELETE | `{{baseUrl}}/api/user/me/addresses/*` | Bearer | See [user-profile flow](./flows/user-profile.md#addresses-protected) |
| POST/DELETE | `{{baseUrl}}/api/user/me/devices` | Bearer | `{ "platform", "pushToken" }` |
| POST | `{{baseUrl}}/api/media/presign` | Bearer | `{ "purpose", "contentType" }` |
| POST/PATCH/GET | `{{baseUrl}}/api/pieces/*` | Varies | See [pieces-scenes flow](./flows/pieces-scenes.md) |
| GET | `{{baseUrl}}/api/pieces/:id/comments` | — | Query: `cursor?`, `limit?` |
| GET | `{{baseUrl}}/api/pieces/:id/shipping-quote` | Optional Bearer | See [orders flow](./flows/orders.md#shipping-quote) |
| POST | `{{baseUrl}}/api/pieces/:id/collect` | Bearer | `{ "addressId", "shippingMethod" }` |
| POST/PATCH/GET | `{{baseUrl}}/api/posts/*` | Varies | Scenes — see [pieces-scenes flow](./flows/pieces-scenes.md) |
| GET | `{{baseUrl}}/api/posts/:id/comments` | — | Query: `cursor?`, `limit?` |
| GET | `{{baseUrl}}/api/users/:username/pieces` | — | — |
| GET | `{{baseUrl}}/api/users/:username/posts` | — | Profile Scenes tab |
| GET | `{{baseUrl}}/api/users/:username/series` | — | Public profile (pieceCount > 1) |
| GET | `{{baseUrl}}/api/user/me/series` | Bearer | Owner management (all series) |
| POST/PATCH/GET/DELETE | `{{baseUrl}}/api/series/*` | Varies | See [series flow](./flows/series.md) |
| POST/DELETE | `{{baseUrl}}/api/users/:username/follow` | Bearer | Follows, or requests if target is private |
| GET | `{{baseUrl}}/api/users/follow-requests` | Bearer | Pending requests to the caller |
| POST | `{{baseUrl}}/api/users/follow-requests/:username/accept` \| `/decline` | Bearer | See [social flow](./flows/social.md#follow-requests-private-accounts) |
| GET | `{{baseUrl}}/api/users/blocked` | Bearer | — |
| POST/DELETE | `{{baseUrl}}/api/users/:username/block` | Bearer | See [social flow](./flows/social.md#blocking) |
| POST/DELETE | `{{baseUrl}}/api/pieces/:id/like` \| `/api/posts/:id/like` | Bearer | — |
| POST/DELETE | `{{baseUrl}}/api/pieces/:id/save` \| `/api/posts/:id/save` | Bearer | — |
| GET | `{{baseUrl}}/api/feed/following` | Bearer | Query: `cursor?`, `limit?` |
| GET | `{{baseUrl}}/api/feed/explore` | Optional Bearer | Query: `medium?`, `cursor?`, `limit?` |
| GET | `{{baseUrl}}/api/feed/for-you` | Bearer | Query: `cursor?`, `limit?` |
| GET/PATCH/POST | `{{baseUrl}}/api/notifications/*` | Bearer | See [notifications flow](./flows/notifications.md) |
| GET/POST/PATCH | `{{baseUrl}}/api/inquiries/*` | Bearer | See [inquiries flow](./flows/inquiries.md) |
| GET | `{{baseUrl}}/api/inquiries/requests` | Bearer | Pending message requests (seller-side) |
| POST | `{{baseUrl}}/api/inquiries/:id/accept` \| `/decline` | Bearer | Seller only — see [inquiries flow](./flows/inquiries.md#message-requests-private-accounts--restricted-messaging) |
| GET/PATCH/POST | `{{baseUrl}}/api/orders/*` | Bearer | See [orders flow](./flows/orders.md) |
| GET | `{{baseUrl}}/api/user/me/orders` \| `/sales` | Bearer | Buyer / seller history |

**Auth column:** See [setup.md](./setup.md) for Bearer / Optional Bearer / Cookie definitions.

## Flow index

| Flow | Doc |
|------|-----|
| Setup & conventions | [setup.md](./setup.md) |
| Auth | [flows/auth.md](./flows/auth.md) |
| User & profile | [flows/user-profile.md](./flows/user-profile.md) |
| Media | [flows/media.md](./flows/media.md) |
| Pieces & scenes | [flows/pieces-scenes.md](./flows/pieces-scenes.md) |
| Social | [flows/social.md](./flows/social.md) |
| Feeds | [flows/feeds.md](./flows/feeds.md) |
| Series | [flows/series.md](./flows/series.md) |
| Notifications | [flows/notifications.md](./flows/notifications.md) |
| Inquiries | [flows/inquiries.md](./flows/inquiries.md) |
| Orders | [flows/orders.md](./flows/orders.md) |
