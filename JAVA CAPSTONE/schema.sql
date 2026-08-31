-- ============================================================================
-- SIMATS Engineering (Saveetha Institute of Medical And Technical Sciences)
-- Course: Java Programming (CSA0925)
-- Project: Skill Progress Analytics with Personalized Learning Path Recommendation Engine
-- Database Schema: MySQL / JDBC Relational Architecture
-- Team: S. Dharanish (192472152), P. Jeevan Kumar (192472082), Akileshwaran A (192511354)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `simats_skill_analytics`;
USE `simats_skill_analytics`;

-- 1. Students Table (Module 1: User Management)
CREATE TABLE IF NOT EXISTS `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `department` VARCHAR(50) DEFAULT 'CSE',
    `reg_no` VARCHAR(50) NOT NULL UNIQUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Courses Table (Module 1: Course Management)
CREATE TABLE IF NOT EXISTS `courses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(20) NOT NULL UNIQUE,
    `title` VARCHAR(100) NOT NULL,
    `category` VARCHAR(50) NOT NULL,
    `total_modules` INT DEFAULT 10,
    `credits` INT DEFAULT 3,
    `description` TEXT
);

-- 3. Student Course Progress Table (Module 2: Progress Analytics)
CREATE TABLE IF NOT EXISTS `student_progress` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `course_id` INT NOT NULL,
    `score` DECIMAL(5,2) DEFAULT 0.00,
    `completion_progress` DECIMAL(5,2) DEFAULT 0.00,
    `status` ENUM('Strong', 'Average', 'Weak', 'Enrolled') DEFAULT 'Enrolled',
    `last_activity` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_student_course` (`student_id`, `course_id`)
);

-- 4. Skill Analytics Table (Module 2: Skill Classification)
CREATE TABLE IF NOT EXISTS `skill_analytics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `subject_name` VARCHAR(100) NOT NULL,
    `score` DECIMAL(5,2) NOT NULL,
    `performance` ENUM('Strong', 'Average', 'Weak') NOT NULL,
    `mastery_level` VARCHAR(50) NOT NULL,
    `weak_topics` TEXT,
    `strengths` TEXT,
    `evaluated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE
);

-- 5. Personalized Recommendations Table (Module 3: Recommendation Engine)
CREATE TABLE IF NOT EXISTS `recommendations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `target_subject` VARCHAR(100) NOT NULL,
    `topic_name` VARCHAR(100) NOT NULL,
    `priority` VARCHAR(20) NOT NULL,
    `recommendation_type` VARCHAR(50) NOT NULL,
    `learning_path_title` VARCHAR(150) NOT NULL,
    `action_plan` TEXT NOT NULL,
    `estimated_hours` INT DEFAULT 5,
    `resource_links` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE
);

-- 6. Quizzes & Questions Table (Module 2: Assessment Engine)
CREATE TABLE IF NOT EXISTS `quiz_questions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NOT NULL,
    `subject` VARCHAR(100) NOT NULL,
    `topic` VARCHAR(100) NOT NULL,
    `question_text` TEXT NOT NULL,
    `options_json` TEXT NOT NULL,
    `correct_option_index` INT NOT NULL,
    `explanation` TEXT,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
);

-- Seed Data Insertion (Matching Slide 7)
INSERT INTO `students` (`id`, `name`, `email`, `password`, `department`, `reg_no`) VALUES
(1, 'P. Jeevan Kumar', 'jeevan@example.com', 'password123', 'CSE', '192472082'),
(2, 'S. Dharanish', 'dharanish@example.com', 'password123', 'CSE', '192472152'),
(3, 'Akileshwaran A', 'akilesh@example.com', 'password123', 'CSE', '192511354');

INSERT INTO `courses` (`id`, `code`, `title`, `category`, `total_modules`, `credits`, `description`) VALUES
(1, 'CSA0925', 'Java Programming', 'Core Programming', 10, 4, 'OOP, JDBC, Collections, Streams, Concurrency'),
(2, 'CSA0926', 'Python', 'Programming', 8, 3, 'Python Core, Data Analytics, Pandas, Scripting'),
(3, 'CSA0927', 'Data Structures', 'Core CS', 12, 4, 'Trees, Graphs, Sorting, Dynamic Programming'),
(4, 'CSA0928', 'DBMS', 'Database Systems', 10, 3, 'Relational SQL, Normalization, Transactions'),
(5, 'CSA0929', 'Cloud Computing', 'Systems', 8, 3, 'Virtualization, AWS/GCP, Distributed Systems'),
(6, 'CSA0930', 'Data Warehousing', 'Data Science', 8, 3, 'ETL Pipelines, OLAP, Star & Snowflake Schemas');

INSERT INTO `student_progress` (`student_id`, `course_id`, `score`, `completion_progress`, `status`) VALUES
(1, 1, 82.00, 85.00, 'Strong'),
(1, 2, 68.00, 70.00, 'Average'),
(1, 3, 45.00, 50.00, 'Weak'),
(1, 4, 78.00, 75.00, 'Strong'),
(1, 5, 62.00, 60.00, 'Average'),
(1, 6, 80.00, 80.00, 'Strong');
