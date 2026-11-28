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

## Day 11 – Frontend and Backend Integration

### Project
AI-Study-Companion

### Objective
Integrate the Flutter frontend with the Python FastAPI
backend to perform study-note operations.

### Technologies Used
- Flutter
- Dart
- Python
- FastAPI
- SQLite
- HTTP package

### Integration Process
The Flutter application communicates with the FastAPI
backend using HTTP requests.

The backend processes requests and stores study notes
in its SQLite database.

The Flutter application fetches the stored notes and
displays them on the Notes screen.

### Integrated Features
- Fetch notes through GET API.
- Add notes through POST API.
- Delete notes through DELETE API.
- Search notes.
- Filter notes by subject.
- Loading indicator.
- Error handling.
- Refresh notes.

### Backend Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /notes | Retrieve notes |
| POST | /notes | Add a note |
| PUT | /notes/{note_id} | Update a note |
| DELETE | /notes/{note_id} | Delete a note |

### Testing
The API endpoints were tested using FastAPI Swagger UI.

The frontend integration was tested using an Android emulator.

### Day 11 Outcome
The Flutter frontend and backend are connected through
HTTP API communication, enabling note creation,
retrieval and deletion through the backend.

## Day 12 – Testing and Debugging

### Testing Performed
- Manual Testing
- Functional Testing
- Unit Testing
- Integration Testing
- System Testing
- Regression Testing

### Modules Tested
- Notes Management
- Input Validation
- Search and Subject Filtering
- API Integration
- Database Operations
- Error Handling

### Testing Tools
- Flutter Test
- Flutter Analyze
- FastAPI Swagger UI
- Android Emulator

### Testing Results
Refer to the Day 12 testing report for individual
test cases and their actual execution results.

### Bug Fixes
Document the bugs identified, their causes and
the fixes implemented during testing.
