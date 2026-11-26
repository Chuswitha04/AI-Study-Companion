
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3

app = FastAPI(title="AI-Study-Companion API")

# Allow requests from the Flutter application
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE = "study_companion.db"


# Database connection
def get_connection():
    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    return connection


# Create notes table
def create_table():
    connection = get_connection()

    connection.execute("""
        CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subject TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL
        )
    """)

    connection.commit()
    connection.close()


create_table()


# Request data model
class Note(BaseModel):
    title: str
    subject: str
    content: str
    createdAt: str


# Welcome endpoint
@app.get("/")
def home():
    return {
        "message": "Welcome to AI-Study-Companion Backend API"
    }


# GET: Retrieve all notes
@app.get("/notes")
def get_notes():
    connection = get_connection()

    notes = connection.execute(
        "SELECT * FROM notes ORDER BY id DESC"
    ).fetchall()

    connection.close()

    return [dict(note) for note in notes]


# POST: Create a new note
@app.post("/notes", status_code=201)
def create_note(note: Note):
    connection = get_connection()

    cursor = connection.execute(
        """
        INSERT INTO notes (title, subject, content, createdAt)
        VALUES (?, ?, ?, ?)
        """,
        (note.title, note.subject, note.content, note.createdAt)
    )

    connection.commit()
    note_id = cursor.lastrowid
    connection.close()

    return {
        "message": "Note created successfully",
        "id": note_id
    }


# PUT: Update an existing note
@app.put("/notes/{note_id}")
def update_note(note_id: int, note: Note):
    connection = get_connection()

    cursor = connection.execute(
        """
        UPDATE notes
        SET title = ?, subject = ?, content = ?, createdAt = ?
        WHERE id = ?
        """,
        (
            note.title,
            note.subject,
            note.content,
            note.createdAt,
            note_id
        )
    )

    connection.commit()
    updated = cursor.rowcount
    connection.close()

    if updated == 0:
        raise HTTPException(
            status_code=404,
            detail="Note not found"
        )

    return {"message": "Note updated successfully"}


# DELETE: Delete a note
@app.delete("/notes/{note_id}")
def delete_note(note_id: int):
    connection = get_connection()

    cursor = connection.execute(
        "DELETE FROM notes WHERE id = ?",
        (note_id,)
    )

    connection.commit()
    deleted = cursor.rowcount
    connection.close()

    if deleted == 0:
        raise HTTPException(
            status_code=404,
            detail="Note not found"
        )

    return {"message": "Note deleted successfully"}
