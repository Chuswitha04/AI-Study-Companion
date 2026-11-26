# AI-Study-Companion

## Project Description
AI-Study-Companion is a mobile application designed to help students organize study materials, manage notes, generate flashcards, create quizzes and improve their learning habits.

## Technology Stack
- Flutter
- Dart
- SQLite
- VS Code
- Android Emulator

## Database Integration
The application uses SQLite for local data storage.

### Notes Table
| Field | Data Type |
|---|---|
| id | INTEGER PRIMARY KEY |
| title | TEXT |
| subject | TEXT |
| content | TEXT |
| created_at | TEXT |

## Implemented Database Operations
1. Create – Save new study notes.
2. Read – Retrieve and display saved notes.
3. Update – Modify existing notes.
4. Delete – Remove unwanted notes.

## Current Development Status
The Notes Management module is integrated with local SQLite storage.

## Future Enhancements
- Flashcard generation
- Quiz generation
- AI-based note summarization
- Photo-to-text scanning
- Study streak tracking


## Day 10 - Backend Development and API Integration

### Backend Technology
- Python
- FastAPI
- SQLite

### Project Functionality
The AI-Study-Companion backend manages study notes
through REST API endpoints.

### Implemented API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /notes | Retrieve all notes |
| POST | /notes | Create a new note |
| PUT | /notes/{note_id} | Update a note |
| DELETE | /notes/{note_id} | Delete a note |

### Database
SQLite is used to store study notes.

### API Testing
API endpoints are tested using FastAPI Swagger UI.

### How to Run the Backend

1. Navigate to the backend folder.
2. Install requirements:
   python -m pip install -r requirements.txt
3. Start the server:
   python -m uvicorn main:app --reload
4. Open http://127.0.0.1:8000/docs
