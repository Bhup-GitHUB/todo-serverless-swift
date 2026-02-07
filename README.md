# Todo-Serverless (SwiftUI + HonoJS)

A clean Todo iOS app built with SwiftUI and connected to a serverless backend written in HonoJS and deployed on Cloudflare Workers.

## Demo

<video src="./Screen%20Recording%202026-02-08%20at%204.24.01%E2%80%AFAM.mov" controls width="360"></video>

If video does not render in your viewer, open this file directly:
[Screen Recording](./Screen%20Recording%202026-02-08%20at%204.24.01%E2%80%AFAM.mov)

## Architecture

### Frontend (SwiftUI)
- iOS app built with SwiftUI.
- MVVM-style state flow (`TodoListViewModel`).
- Screens:
  - Home (list, quick add, filters)
  - Edit/Add Todo
  - Todo Detail
  - Completed tab

### Backend (HonoJS + Cloudflare Workers)
- Backend is built using HonoJS.
- Deployed on Cloudflare Workers.
- Base URL used by app:
  - `https://my-next-app.4bhupeshkumar.workers.dev`

## API Endpoints

- `GET /api/todos` -> returns `{ "todos": Todo[] }`
- `POST /api/add-todo` -> body `{ "title": string }`
- `PUT /api/update-todo` -> body `{ "id": string, "title"?: string, "completed"?: boolean }`
- `DELETE /api/delete-todo` -> body `{ "id": string }`

## Run iOS App

1. Open `Todo-Serverless.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Build and run.

## Notes

- Backend contract follows your documented Hono API.
- App is wired to production worker URL above.
