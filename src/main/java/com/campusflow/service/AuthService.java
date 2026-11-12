package com.campusflow.service;

import com.campusflow.dao.UserDAO;
import com.campusflow.model.UserBean;
import com.campusflow.util.PasswordUtil;
import com.campusflow.util.ValidationUtil;

/**
 * Service managing user authentication, registration, credential verification, and profile security.
 */
public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public static class AuthResult {
        private final boolean success;
        private final String message;
        private final UserBean user;

        public AuthResult(boolean success, String message, UserBean user) {
            this.success = success;
            this.message = message;
            this.user = user;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public UserBean getUser() { return user; }
    }

    /**
     * Authenticates user with email and raw password.
     */
    public AuthResult login(String email, String password) {
        if (!ValidationUtil.isNotEmpty(email) || !ValidationUtil.isNotEmpty(password)) {
            return new AuthResult(false, "Email and password are required.", null);
        }

        UserBean user = userDAO.findByEmail(email.trim());
        if (user == null) {
            // Generic message prevents username harvesting
            return new AuthResult(false, "Invalid email or password.", null);
        }

        if (!user.isActive()) {
            return new AuthResult(false, "Your account has been deactivated. Please contact campus administration.", null);
        }

        boolean match = PasswordUtil.verifyPassword(password, user.getPasswordSalt(), user.getPasswordHash());
        if (!match) {
            return new AuthResult(false, "Invalid email or password.", null);
        }

        return new AuthResult(true, "Authentication successful.", user);
    }

    /**
     * Registers a new student account.
     */
    public AuthResult registerStudent(String name, String email, String password, String phone) {
        if (!ValidationUtil.isNotEmpty(name) || name.trim().length() < 2) {
            return new AuthResult(false, "Full name must be at least 2 characters.", null);
        }
        if (!ValidationUtil.isValidEmail(email)) {
            return new AuthResult(false, "Please provide a valid email address.", null);
        }
        if (!ValidationUtil.isValidPassword(password)) {
            return new AuthResult(false, "Password must be at least 6 characters and contain both letters and numbers.", null);
        }
        if (phone != null && !phone.trim().isEmpty() && !ValidationUtil.isValidPhone(phone)) {
            return new AuthResult(false, "Please enter a valid phone number.", null);
        }

        // Duplicate email check
        UserBean existing = userDAO.findByEmail(email.trim());
        if (existing != null) {
            return new AuthResult(false, "An account with this email address already exists.", null);
        }

        String salt = PasswordUtil.generateSalt();
        String hash = PasswordUtil.hashPassword(password, salt);

        UserBean newUser = new UserBean();
        newUser.setName(name.trim());
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setPasswordHash(hash);
        newUser.setPasswordSalt(salt);
        newUser.setRole("STUDENT");
        newUser.setDepartmentId(null);
        newUser.setPhone(phone != null ? phone.trim() : null);
        newUser.setAccountStatus("ACTIVE");

        boolean created = userDAO.create(newUser);
        if (!created) {
            return new AuthResult(false, "Registration failed due to a database error. Please try again.", null);
        }

        UserBean persisted = userDAO.findByEmail(email.trim().toLowerCase());
        return new AuthResult(true, "Registration successful! You may now log in.", persisted);
    }

    /**
     * Changes password with current password verification.
     */
    public AuthResult changePassword(Long userId, String currentPassword, String newPassword) {
        if (userId == null || !ValidationUtil.isNotEmpty(currentPassword) || !ValidationUtil.isNotEmpty(newPassword)) {
            return new AuthResult(false, "All password fields are required.", null);
        }
        if (!ValidationUtil.isValidPassword(newPassword)) {
            return new AuthResult(false, "New password must be at least 6 characters and contain letters and numbers.", null);
        }

        UserBean user = userDAO.findById(userId);
        if (user == null) {
            return new AuthResult(false, "User account not found.", null);
        }

        boolean currentMatch = PasswordUtil.verifyPassword(currentPassword, user.getPasswordSalt(), user.getPasswordHash());
        if (!currentMatch) {
            return new AuthResult(false, "Current password does not match.", null);
        }

        String newSalt = PasswordUtil.generateSalt();
        String newHash = PasswordUtil.hashPassword(newPassword, newSalt);

        boolean updated = userDAO.updatePassword(userId, newHash, newSalt);
        if (!updated) {
            return new AuthResult(false, "Failed to update password. Please try again.", null);
        }

        return new AuthResult(true, "Password updated successfully.", user);
    }
}
