DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
id INTEGER PRIMARY KEY,
body VARCHAR(255) NOT NULL,
question_id INTEGER NOT NULL,
parent_reply_id INTEGER,
author_id INTEGER NOT NULL,
FOREIGN KEY (question_id) REFERENCES questions(id),
FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(first_name, last_name)
VALUES
  ('bobby', 'tables'),
  ('dave', 'davidson');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('question 1', 'body 1', 1),
  ('question 2', 'body 2', 2);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (1, 2),
  (2, 1),
  (2, 2);

INSERT INTO
  replies(question_id, body, parent_reply_id, author_id)
VALUES
  (1, 'body', NULL, 2),
  (2, 'body', NULL, 1),
  (2, 'body', 2, 2);

INSERT INTO
  question_likes(user_id, question_id)
VALUES
(1, 2),
(2, 1),
(2, 2);
