# Learning Journal App

A journaling app for capturing daily learnings with Apple Pencil support on iPad/iPhone. Entries are auto-categorized and stored in Neo4j for future knowledge graph exploration.

## Tech Stack

- **iOS App**: SwiftUI + PencilKit (native handwriting recognition via Scribble)
- **Web PWA**: React + Vite + TypeScript (installable, offline-capable)
- **Backend**: FastAPI (Python)
- **Database**: Neo4j AuraDB Free

## Project Structure

```
├── backend/           # FastAPI backend
│   ├── app/
│   │   ├── main.py          # App entry point
│   │   ├── config.py        # Configuration
│   │   ├── database.py      # Neo4j connection
│   │   ├── models/          # Pydantic models
│   │   ├── routers/         # API route handlers
│   │   └── services/        # Business logic
│   ├── requirements.txt
│   └── Dockerfile
├── ios/               # SwiftUI iOS app
│   └── LearningJournal/
│       └── LearningJournal/
│           ├── Models/      # Data models
│           ├── Views/       # SwiftUI views
│           └── Services/    # API client
├── web/               # React PWA web app
│   ├── src/
│   │   ├── api/           # API client
│   │   ├── components/    # Reusable UI components
│   │   ├── i18n/          # Translations (ES/EN)
│   │   ├── pages/         # Page components
│   │   └── types/         # TypeScript interfaces
│   ├── public/icons/      # PWA icons
│   └── vite.config.ts     # Vite + PWA config
└── README.md
```

## Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Add `API_KEY` and `ALLOWED_ORIGINS` to the backend `.env` for authentication and CORS:

Create a `.env` file in `backend/`:

```
NEO4J_URI=neo4j+s://your-instance.databases.neo4j.io
NEO4J_USER=neo4j
NEO4J_PASSWORD=your-password
API_KEY=your-secret-api-key-here
ALLOWED_ORIGINS=["http://localhost:5173"]
```

Run the server:

```bash
uvicorn app.main:app --reload
```

Seed the initial tags:

```bash
python -m app.seed
```

## API Endpoints

| Method | Endpoint              | Description                    |
|--------|-----------------------|--------------------------------|
| POST   | `/entries`            | Create a new journal entry     |
| GET    | `/entries`            | List all entries (newest first)|
| GET    | `/entries/{id}`       | Get a single entry             |
| PATCH  | `/entries/{id}/tags`  | Update tags for an entry       |
| GET    | `/tags`               | List all available tags        |

## Web PWA

```bash
cd web
npm install
```

Create a `.env` file in `web/`:

```
VITE_API_URL=http://localhost:8000
VITE_API_KEY=your-secret-api-key-here
```

Run the dev server:

```bash
npm run dev
```

Build for production:

```bash
npm run build
npm run preview
```

| Variable | Description |
|---|---|
| `VITE_API_URL` | Backend API URL (default: `http://localhost:8000`) |
| `VITE_API_KEY` | API key matching the backend `API_KEY` setting |

The web app supports Spanish (default) and English with a language toggle. It is installable as a PWA with offline caching for entries and tags.

## iOS App

Open `ios/LearningJournal/LearningJournal.xcodeproj` in Xcode and run on a simulator or device.

Configure the API base URL in `Services/APIService.swift`.

## Auto-Tagging

Entries are automatically tagged based on keyword matching:

- **#adoption** — adoption, internal product, rollout, onboarding
- **#ai-process** — claude, AI, prompt, LLM, automation
- **#design-decisions** — design, UX, UI, prototype, wireframe
- **#0-to-1** — MVP, build, launch, new product, from scratch
- **#data-insights** — dashboard, analytics, metrics, data, insights
- **#tools** — tool, library, framework, setup
- **#automation** — workflow, automate, script
- **#full-stack** — frontend, backend, full-stack, API
