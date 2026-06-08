from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import psycopg2
import os
import hashlib

app = FastAPI(title="CampusConnect API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "postgres"),
        database=os.getenv("DB_NAME", "campusconnect"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres")
    )

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            college VARCHAR(255),
            branch VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id SERIAL PRIMARY KEY,
            sender_id INT REFERENCES users(id),
            receiver_id INT REFERENCES users(id),
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

class UserRegister(BaseModel):
    name: str
    email: str
    password: str
    college: str
    branch: str

class UserLogin(BaseModel):
    email: str
    password: str

class Message(BaseModel):
    sender_id: int
    receiver_id: int
    content: str

@app.on_event("startup")
def startup():
    init_db()

@app.get("/health")
def health():
    return {"status": "ok", "service": "campus-connect-backend"}

@app.post("/api/register")
def register(user: UserRegister):
    conn = get_db()
    cur = conn.cursor()
    hashed = hashlib.sha256(user.password.encode()).hexdigest()
    try:
        cur.execute(
            """INSERT INTO users (name, email, password, college, branch)
               VALUES (%s, %s, %s, %s, %s) RETURNING id""",
            (user.name, user.email, hashed, user.college, user.branch)
        )
        user_id = cur.fetchone()[0]
        conn.commit()
        return {"id": user_id, "name": user.name, "email": user.email,
                "college": user.college, "branch": user.branch}
    except psycopg2.errors.UniqueViolation:
        raise HTTPException(status_code=400, detail="Email already exists")
    finally:
        cur.close()
        conn.close()

@app.post("/api/login")
def login(user: UserLogin):
    conn = get_db()
    cur = conn.cursor()
    hashed = hashlib.sha256(user.password.encode()).hexdigest()
    cur.execute(
        "SELECT id, name, email, college, branch FROM users WHERE email=%s AND password=%s",
        (user.email, hashed)
    )
    row = cur.fetchone()
    cur.close()
    conn.close()
    if not row:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"id": row[0], "name": row[1], "email": row[2],
            "college": row[3], "branch": row[4]}

@app.get("/api/users")
def get_users():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, name, email, college, branch FROM users ORDER BY created_at DESC")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [{"id": r[0], "name": r[1], "email": r[2],
             "college": r[3], "branch": r[4]} for r in rows]

@app.post("/api/messages")
def send_message(msg: Message):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO messages (sender_id, receiver_id, content) VALUES (%s, %s, %s) RETURNING id",
        (msg.sender_id, msg.receiver_id, msg.content)
    )
    msg_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return {"id": msg_id, "message": "Sent successfully"}

@app.get("/api/messages/{user_id}/{other_id}")
def get_messages(user_id: int, other_id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT m.id, m.sender_id, u.name, m.content, m.created_at
        FROM messages m
        JOIN users u ON u.id = m.sender_id
        WHERE (m.sender_id=%s AND m.receiver_id=%s)
           OR (m.sender_id=%s AND m.receiver_id=%s)
        ORDER BY m.created_at ASC
    """, (user_id, other_id, other_id, user_id))
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [{"id": r[0], "sender_id": r[1], "sender_name": r[2],
             "content": r[3], "created_at": str(r[4])} for r in rows]