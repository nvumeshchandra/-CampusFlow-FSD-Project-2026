package com.campusflow.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Enterprise Password Security Utility using PBKDF2WithHmacSHA256.
 * Enforces per-account unique cryptographic salt and constant-time verification.
 */
public class PasswordUtil {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_BYTES = 16;
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Generates a cryptographically strong 16-byte random salt encoded as hexadecimal.
     */
    public static String generateSalt() {
        byte[] salt = new byte[SALT_BYTES];
        RANDOM.nextBytes(salt);
        return bytesToHex(salt);
    }

    /**
     * Hashes a plain-text password with the given hex-encoded salt using PBKDF2.
     */
    public static String hashPassword(String password, String saltHex) {
        if (password == null || saltHex == null) {
            throw new IllegalArgumentException("Password and salt must not be null");
        }
        try {
            byte[] salt = hexToBytes(saltHex);
            KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            byte[] hash = factory.generateSecret(spec).getEncoded();
            return bytesToHex(hash);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error hashing password with " + ALGORITHM, e);
        }
    }

    /**
     * Verifies whether a given raw password matches the expected hash and salt.
     * Uses MessageDigest.isEqual for constant-time comparison against timing attacks.
     */
    public static boolean verifyPassword(String password, String saltHex, String expectedHash) {
        if (password == null || saltHex == null || expectedHash == null) {
            return false;
        }
        String calculatedHash = hashPassword(password, saltHex);
        return MessageDigest.isEqual(
            calculatedHash.getBytes(java.nio.charset.StandardCharsets.UTF_8),
            expectedHash.getBytes(java.nio.charset.StandardCharsets.UTF_8)
        );
    }

    public static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    public static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                                 + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }

    // CLI helper for generating password hashes if needed during administrative setup
    public static void main(String[] args) {
        String pass = args.length > 0 ? args[0] : "Admin@123";
        String salt = generateSalt();
        String hash = hashPassword(pass, salt);
        System.out.println("Password: " + pass);
        System.out.println("Salt:     " + salt);
        System.out.println("Hash:     " + hash);
    }
}
