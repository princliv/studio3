# Studiothree Discover API

Postman-ready API documentation for the **Studiothree Discover** backend. Use these docs to build and test requests in Postman and to integrate from mobile (iOS/Android) or web clients.

**Terminology:** UI **Scenes** map to the API `posts` resource. See [Content Model & Posting Workflow](../../Content_Model_and_Posting_Workflow.md).

## Flows

| Flow | File | Description |
|------|------|-------------|
| Setup | [setup.md](./setup.md) | Postman environment, tokens, cookies, response format |
| Auth | [flows/auth.md](./flows/auth.md) | OTP, register, login, refresh, logout, password reset |
| User & profile | [flows/user-profile.md](./flows/user-profile.md) | Me, public profile, onboarding, seller mode, saved content |
| Media | [flows/media.md](./flows/media.md) | Presigned uploads |
| Pieces & scenes | [flows/pieces-scenes.md](./flows/pieces-scenes.md) | Create, edit, detail, profile tabs |
| Social | [flows/social.md](./flows/social.md) | Follow, like, save, comments |
| Feeds | [flows/feeds.md](./flows/feeds.md) | Following, explore, for-you |
| Series | [flows/series.md](./flows/series.md) | Piece grouping for profile Series tab |
| Notifications | [flows/notifications.md](./flows/notifications.md) | Activity feed + push delivery |
| Inquiries | [flows/inquiries.md](./flows/inquiries.md) | Piece-scoped buyer/seller chat |
| Orders | [flows/orders.md](./flows/orders.md) | Shipping quotes, checkout, order management |

## Quick reference

See [quick-reference.md](./quick-reference.md) for a single-table endpoint index.

## Suggested testing order

1. **GET** `{{baseUrl}}/` → Health check ([setup.md](./setup.md))
2. **POST** login or register → Set `accessToken` ([auth.md](./flows/auth.md))
3. Complete onboarding ([user-profile.md](./flows/user-profile.md))
4. Presign media → Create piece or scene ([media.md](./flows/media.md), [pieces-scenes.md](./flows/pieces-scenes.md))
5. Browse feeds, like/save/comment ([feeds.md](./flows/feeds.md), [social.md](./flows/social.md))
6. Save an address, get a shipping quote, checkout ([user-profile.md](./flows/user-profile.md#addresses-protected), [orders.md](./flows/orders.md))
7. Ask about a piece, check notifications ([inquiries.md](./flows/inquiries.md), [notifications.md](./flows/notifications.md))
