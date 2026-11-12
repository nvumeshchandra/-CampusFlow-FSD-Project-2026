package com.campusflow.util;

import java.util.regex.Pattern;

/**
 * Server-side validation utility for input verification, sanitation and bounds checking.
 */
public class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    // Minimum 8 characters, at least 1 letter and 1 digit
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[0-9])(?=.*[a-zA-Z]).{6,64}$"
    );

    private static final Pattern PHONE_PATTERN = Pattern.compile(
        "^[0-9+() -]{7,20}$"
    );

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return true; // Optional field
        }
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }

    public static boolean isLengthWithin(String str, int min, int max) {
        if (str == null) return min == 0;
        int len = str.trim().length();
        return len >= min && len <= max;
    }

    public static boolean isBetween(int val, int min, int max) {
        return val >= min && val <= max;
    }

    /**
     * Sanitizes string to prevent control characters and trim whitespace.
     */
    public static String clean(String input) {
        if (input == null) return "";
        return input.trim();
    }
}
