package com.campusflow.service;

/**
 * Transparent, deterministic Rule-Based Priority Engine.
 * Evaluates urgency (1-4), impact (1-4), and location weight (1-3) to compute priority.
 */
public class PriorityService {

    public static class PriorityResult {
        private final int score;
        private final String priority;
        private final String description;

        public PriorityResult(int score, String priority, String description) {
            this.score = score;
            this.priority = priority;
            this.description = description;
        }

        public int getScore() { return score; }
        public String getPriority() { return priority; }
        public String getDescription() { return description; }
    }

    /**
     * Calculates deterministic priority score and label based on three campus factors:
     * - Urgency: 1 (Low), 2 (Medium), 3 (High), 4 (Critical)
     * - Impact: 1 (Single user), 2 (Small group/room), 3 (Department/Floor), 4 (Campus-wide)
     * - Location Weight: 1 (General area), 2 (Classroom/Lab), 3 (Critical facility / Exam hall / Server room)
     */
    public static PriorityResult calculate(int urgency, int impact, int locationWeight) {
        // Enforce bounds
        int u = Math.min(Math.max(urgency, 1), 4);
        int i = Math.min(Math.max(impact, 1), 4);
        int l = Math.min(Math.max(locationWeight, 1), 3);

        int score = u + i + l;
        String priority;
        String description;

        if (score <= 4) {
            priority = "LOW";
            description = "Standard operational inquiry or minor cosmetic issue. Routine resolution queue.";
        } else if (score <= 6) {
            priority = "MEDIUM";
            description = "Standard issue affecting individual or small classroom amenities. Standard 48-hour resolution.";
        } else if (score <= 8) {
            priority = "HIGH";
            description = "High urgency or departmental impact affecting active instruction or essential amenities. Expedited 24-hour response.";
        } else {
            priority = "CRITICAL";
            description = "Critical campus facility disruption, safety risk, or campus-wide outage. Immediate emergency dispatch required.";
        }

        return new PriorityResult(score, priority, description);
    }
}
