package com.simats.analytics.test;

import com.simats.analytics.dao.DatabaseManager;
import com.simats.analytics.model.*;
import com.simats.analytics.service.*;

import java.util.*;

/**
 * Slide 12: Unit Testing & Integration Testing Suite.
 * Validates Login, Registration, Progress Calculation, Skill Analysis,
 * Recommendations, and End-to-End Data Flow.
 */
public class AppTestSuite {

    public static class TestResult {
        public String testName;
        public String category; // "Unit Test" or "Integration Test"
        public boolean passed;
        public String details;

        public TestResult(String testName, String category, boolean passed, String details) {
            this.testName = testName;
            this.category = category;
            this.passed = passed;
            this.details = details;
        }

        public String toJson() {
            return String.format(
                    "{\"testName\":\"%s\",\"category\":\"%s\",\"passed\":%b,\"details\":\"%s\"}",
                    testName.replace("\"", "\\\""), category.replace("\"", "\\\""), passed,
                    details.replace("\"", "\\\""));
        }
    }

    public static List<TestResult> runAllTests() {
        List<TestResult> results = new ArrayList<>();
        AuthService authService = new AuthService();
        AnalyticsEngine analyticsEngine = new AnalyticsEngine();
        RecommendationEngine recEngine = new RecommendationEngine();
        ReportService reportService = new ReportService();
        DatabaseManager db = DatabaseManager.getInstance();

        // 1. Unit Test: Registration Functionality
        try {
            String testEmail = "testuser_" + System.currentTimeMillis() + "@simats.edu";
            Student registered = authService.register("Test Student", testEmail, "pass1234", "CSE", "192470001");
            if (registered != null && registered.getId() > 0 && registered.getEmail().equalsIgnoreCase(testEmail)) {
                results.add(new TestResult("Student Registration", "Unit Test", true,
                        "Successfully registered new student with auto-enrollment into courses."));
            } else {
                results.add(new TestResult("Student Registration", "Unit Test", false,
                        "Registration returned null or failed validation."));
            }
        } catch (Exception e) {
            results.add(new TestResult("Student Registration", "Unit Test", false, "Exception: " + e.getMessage()));
        }

        // 2. Unit Test: Login Authentication
        try {
            Student loggedIn = authService.login("jeevan@example.com", "password123");
            if (loggedIn != null && loggedIn.getRegNo().equals("192472082")) {
                results.add(new TestResult("Login Authentication", "Unit Test", true,
                        "Successfully verified credentials for Jeevan Kumar (192472082)."));
            } else {
                results.add(new TestResult("Login Authentication", "Unit Test", false,
                        "Login credentials validation failed."));
            }

            Student invalidLogin = authService.login("jeevan@example.com", "wrongpass");
            if (invalidLogin == null) {
                results.add(new TestResult("Invalid Credential Rejection", "Unit Test", true,
                        "Correctly rejected invalid password attempt."));
            } else {
                results.add(new TestResult("Invalid Credential Rejection", "Unit Test", false,
                        "Incorrectly accepted wrong password."));
            }
        } catch (Exception e) {
            results.add(new TestResult("Login Authentication", "Unit Test", false, "Exception: " + e.getMessage()));
        }

        // 3. Unit Test: Progress Calculation & KPI Aggregation
        try {
            Map<String, Object> summary = analyticsEngine.calculateDashboardSummary(1);
            Double avgScore = (Double) summary.get("averageScore");
            Integer weakCount = (Integer) summary.get("weakSubjectsCount");

            // From slide 7: Average score 69%, 1 weak subject (Data Structures = 45%)
            if (avgScore != null && avgScore >= 68.0 && avgScore <= 70.0 && weakCount != null && weakCount == 1) {
                results.add(new TestResult("Progress & Metric Calculation", "Unit Test", true,
                        "Average score calculated as " + avgScore + "% with exactly " + weakCount
                                + " weak subject identified."));
            } else {
                results.add(new TestResult("Progress & Metric Calculation", "Unit Test", false,
                        "Expected ~69% avg and 1 weak subject, but got avg=" + avgScore + ", weak=" + weakCount));
            }
        } catch (Exception e) {
            results.add(new TestResult("Progress & Metric Calculation", "Unit Test", false,
                    "Exception: " + e.getMessage()));
        }

        // 4. Unit Test: Recommendation Engine & Weak Area Diagnosis
        try {
            List<Recommendation> recs = recEngine.generateRecommendations(1);
            boolean foundDsRec = false;
            for (Recommendation r : recs) {
                if (r.getTargetSubject().equalsIgnoreCase("Data Structures") && r.getPriority().contains("High")) {
                    foundDsRec = true;
                    break;
                }
            }
            if (foundDsRec) {
                results.add(new TestResult("Recommendation Engine", "Unit Test", true,
                        "Generated high-priority personalized remediation pathway for weak area (Data Structures)."));
            } else {
                results.add(new TestResult("Recommendation Engine", "Unit Test", false,
                        "High priority recommendation for Data Structures was not generated."));
            }
        } catch (Exception e) {
            results.add(new TestResult("Recommendation Engine", "Unit Test", false, "Exception: " + e.getMessage()));
        }

        // 5. Integration Test: Database/DAO & Entity Communication
        try {
            List<Course> courses = db.getAllCourses();
            List<Student> students = db.getAllStudents();
            if (courses.size() >= 6 && students.size() >= 3) {
                results.add(new TestResult("DAO & Relational Store Connectivity", "Integration Test", true,
                        "Database initialized with " + courses.size() + " courses and " + students.size()
                                + " registered students."));
            } else {
                results.add(new TestResult("DAO & Relational Store Connectivity", "Integration Test", false,
                        "Data store incomplete. Courses: " + courses.size() + ", Students: " + students.size()));
            }
        } catch (Exception e) {
            results.add(new TestResult("DAO & Relational Store Connectivity", "Integration Test", false,
                    "Exception: " + e.getMessage()));
        }

        // 6. Integration Test: Full End-to-End Module Data Flow (Slide 3 & 8 Flow)
        try {
            // Flow: Student -> Login -> Course Tracking -> Progress Analysis -> Skill
            // Analytics -> Recommendation Engine -> Report
            Student s = authService.login("jeevan@example.com", "password123");
            List<Progress> pList = db.getStudentProgress(s.getId());
            List<SkillAnalytics> skills = analyticsEngine.analyzeStudentSkills(s.getId());
            List<Recommendation> recommendations = recEngine.generateRecommendations(s.getId());
            Report report = reportService.generateStudentReport(s.getId());

            if (s != null && !pList.isEmpty() && !skills.isEmpty() && !recommendations.isEmpty() && report != null) {
                results.add(new TestResult("End-to-End Module Data Flow", "Integration Test", true,
                        "Completed full pipeline: Login -> Progress -> Skill Analytics -> Recommendations -> Generated Report ("
                                + report.getReportId() + ")."));
            } else {
                results.add(new TestResult("End-to-End Module Data Flow", "Integration Test", false,
                        "Pipeline broken at one of the analytical stages."));
            }
        } catch (Exception e) {
            results.add(new TestResult("End-to-End Module Data Flow", "Integration Test", false,
                    "Exception: " + e.getMessage()));
        }

        return results;
    }

    public static void main(String[] args) {
        System.out.println("=================================================");
        System.out.println(" SIMATS Skill Progress Analytics - Test Suite   ");
        System.out.println("=================================================");
        List<TestResult> tests = runAllTests();
        int passed = 0;
        for (TestResult t : tests) {
            String status = t.passed ? "[PASS]" : "[FAIL]";
            System.out.printf("%-7s | %-16s | %-32s | %s\n", status, t.category, t.testName, t.details);
            if (t.passed)
                passed++;
        }
        System.out.println("-------------------------------------------------");
        System.out.println(
                "Total Tests: " + tests.size() + " | Passed: " + passed + " | Failed: " + (tests.size() - passed));
        System.out.println("=================================================");
    }
}
