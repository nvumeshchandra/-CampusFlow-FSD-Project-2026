package com.campusflow.util;

import java.time.Year;

/**
 * Utility for generating standardized, human-readable CampusFlow tracking codes.
 * Format: CF-{YEAR}-{SEQUENCE_NUMBER_ZERO_PADDED}
 * Example: CF-2026-00042
 */
public class TrackingCodeUtil {

    private static final String PREFIX = "CF";

    /**
     * Generates a tracking code based on current year and sequence ID.
     */
    public static String generate(long sequenceId) {
        int year = Year.now().getValue();
        return String.format("%s-%d-%05d", PREFIX, year, sequenceId);
    }
}
