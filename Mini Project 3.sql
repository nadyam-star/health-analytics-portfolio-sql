DROP TABLE IF EXISTS workouts;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS users;

/* -------------------------
   Create tables
-------------------------- */

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL
);

CREATE TABLE activities (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  activity_date TEXT NOT NULL,
  activity_type TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  calories_burned INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE workouts (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  workout_date TEXT NOT NULL,
  workout_type TEXT NOT NULL,
  intensity INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

/* -------------------------
   Insert sample data
-------------------------- */

INSERT INTO users (id, name, age, gender) VALUES
  (1, 'Nadya', 23, 'F'),
  (2, 'Jordan', 29, 'M'),
  (3, 'Sam', 35, 'Nonbinary'),
  (4, 'Avery', 41, 'F'),
  (5, 'Chris', 27, 'M');

INSERT INTO activities (
  id,
  user_id,
  activity_date,
  activity_type,
  duration_minutes,
  calories_burned
) VALUES
  (1, 1, '2026-02-01', 'Walking', 30, 140),
  (2, 1, '2026-02-03', 'Cycling', 45, 380),
  (3, 2, '2026-02-02', 'Running', 25, 300),
  (4, 2, '2026-02-05', 'Walking', 40, 190),
  (5, 3, '2026-02-01', 'Yoga', 60, 210),
  (6, 3, '2026-02-04', 'Walking', 20, 90),
  (7, 4, '2026-02-03', 'Swimming', 30, 260),
  (8, 4, '2026-02-06', 'Cycling', 35, 290),
  (9, 5, '2026-02-02', 'Walking', 50, 220),
  (10, 5, '2026-02-07', 'Running', 30, 360);

INSERT INTO workouts (
  id,
  user_id,
  workout_date,
  workout_type,
  intensity
) VALUES
  (1, 1, '2026-02-01', 'Strength', 7),
  (2, 1, '2026-02-04', 'HIIT', 8),
  (3, 2, '2026-02-02', 'Strength', 6),
  (4, 2, '2026-02-06', 'Cardio', 7),
  (5, 3, '2026-02-03', 'Yoga', 4),
  (6, 3, '2026-02-07', 'Cardio', 6),
  (7, 4, '2026-02-03', 'Cardio', 7),
  (8, 4, '2026-02-05', 'Strength', 8),
  (9, 5, '2026-02-02', 'HIIT', 9);

/* -------------------------
   Q1) User Demographics
-------------------------- */

SELECT
  gender,
  COUNT(*) AS users_in_gender,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users), 1) AS gender_percent,
  (SELECT COUNT(*) FROM users) AS total_users,
  ROUND((SELECT AVG(age) FROM users), 1) AS average_age
FROM users
GROUP BY gender
ORDER BY users_in_gender DESC, gender ASC;

/* -------------------------
   Q2) Activity Summary
-------------------------- */

SELECT
  u.id,
  u.name,
  COUNT(a.id) AS total_activities,
  COALESCE(SUM(a.calories_burned), 0) AS total_calories_burned
FROM users u
LEFT JOIN activities a
  ON a.user_id = u.id
GROUP BY u.id, u.name
ORDER BY total_calories_burned DESC;

/* -------------------------
   Q3) Popular Activities
-------------------------- */

SELECT
  activity_type,
  COUNT(*) AS times_performed
FROM activities
GROUP BY activity_type
ORDER BY times_performed DESC, activity_type ASC;

/* -------------------------
   Q4) Workout Summary
-------------------------- */

SELECT
  u.id,
  u.name,
  COUNT(w.id) AS total_workouts,
  ROUND(AVG(w.intensity), 1) AS avg_workout_intensity
FROM users u
LEFT JOIN workouts w
  ON w.user_id = u.id
GROUP BY u.id, u.name
ORDER BY total_workouts DESC, avg_workout_intensity DESC;

/* -------------------------
   Q5) Top Performers
-------------------------- */

SELECT
  u.name,
  totals.total_calories_burned
FROM users u
JOIN (
  SELECT
    user_id,
    SUM(calories_burned) AS total_calories_burned
  FROM activities
  GROUP BY user_id
) totals
  ON totals.user_id = u.id
ORDER BY totals.total_calories_burned DESC
LIMIT 3;

/* -------------------------
   Optional performance check for Q5
-------------------------- */

EXPLAIN QUERY PLAN
SELECT
  u.name,
  totals.total_calories_burned
FROM users u
JOIN (
  SELECT
    user_id,
    SUM(calories_burned) AS total_calories_burned
  FROM activities
  GROUP BY user_id
) totals
  ON totals.user_id = u.id
ORDER BY totals.total_calories_burned DESC
LIMIT 3;

/* -------------------------
   Q6) Optimization (Indexes)
-------------------------- */

CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_workouts_user_id ON workouts(user_id);

/*
I created indexes on activities(user_id) and workouts(user_id) to improve query
performance. Several queries, including Queries 2, 4, and 5, join tables using
user_id and group by this column. These indexes allow SQLite to locate matching
rows more efficiently instead of scanning the entire table, which becomes more
important as the dataset grows larger.
*/
