package com.campusflow.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Enterprise Database Connection Provider for Oracle Database.
 * Connects to Oracle 10g/11g/12c/19c/21c via Oracle JDBC Thin Driver.
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static final String DEFAULT_DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String DEFAULT_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DEFAULT_USER = "campusflow";
    private static final String DEFAULT_PASS = "campusflow123";

    private static String dbUrl;
    private static String dbUser;
    private static String dbPass;

    static {
        try {
            Class.forName(DEFAULT_DRIVER);
            LOGGER.info("Oracle JDBC Driver loaded successfully: " + DEFAULT_DRIVER);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Failed to load Oracle JDBC Driver", e);
            throw new ExceptionInInitializerError("Oracle JDBC Driver not found on classpath: " + e.getMessage());
        }

        dbUrl = System.getProperty("campusflow.db.url", System.getenv().getOrDefault("CAMPUSFLOW_DB_URL", DEFAULT_URL));
        dbUser = System.getProperty("campusflow.db.user", System.getenv().getOrDefault("CAMPUSFLOW_DB_USER", DEFAULT_USER));
        dbPass = System.getProperty("campusflow.db.password", System.getenv().getOrDefault("CAMPUSFLOW_DB_PASSWORD", DEFAULT_PASS));
    }

    /**
     * Obtains a new JDBC Connection to Oracle Database.
     * Callers must close this connection or use try-with-resources.
     */
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(dbUrl, dbUser, dbPass);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to establish Oracle Database connection to " + dbUrl, e);
            throw e;
        }
    }

    /**
     * Diagnostics check for database connectivity.
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Oracle database test connection failed", e);
            return false;
        }
    }

    // CLI test
    public static void main(String[] args) {
        System.out.println("Testing Oracle DB Connection...");
        boolean ok = testConnection();
        System.out.println("Connection Result: " + (ok ? "SUCCESS" : "FAILED"));
    }
}
