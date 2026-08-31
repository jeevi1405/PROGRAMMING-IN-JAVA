package com.campus.parking.config;

import java.io.*;
import java.util.Properties;

/**
 * Configuration holder for Database credentials and application settings.
 * Persists settings to 'db_config.properties'.
 */
public class DatabaseConfig {
    private static final String CONFIG_FILE = "db_config.properties";

    private String host = "localhost";
    private int port = 3306;
    private String database = "campus_parking_db";
    private String username = "root";
    private String password = "";
    private boolean useMockFallback = false;

    private static DatabaseConfig instance;

    private DatabaseConfig() {
        loadConfig();
    }

    public static synchronized DatabaseConfig getInstance() {
        if (instance == null) {
            instance = new DatabaseConfig();
        }
        return instance;
    }

    public void loadConfig() {
        File file = new File(CONFIG_FILE);
        if (file.exists()) {
            Properties props = new Properties();
            try (FileInputStream in = new FileInputStream(file)) {
                props.load(in);
                this.host = props.getProperty("db.host", "localhost");
                this.port = Integer.parseInt(props.getProperty("db.port", "3306"));
                this.database = props.getProperty("db.name", "campus_parking_db");
                this.username = props.getProperty("db.user", "root");
                this.password = props.getProperty("db.password", "");
                this.useMockFallback = Boolean.parseBoolean(props.getProperty("db.useMockFallback", "false"));
            } catch (Exception e) {
                System.err.println("Warning: Could not read db_config.properties, using defaults. " + e.getMessage());
            }
        }
    }

    public void saveConfig() {
        Properties props = new Properties();
        props.setProperty("db.host", host);
        props.setProperty("db.port", String.valueOf(port));
        props.setProperty("db.name", database);
        props.setProperty("db.user", username);
        props.setProperty("db.password", password);
        props.setProperty("db.useMockFallback", String.valueOf(useMockFallback));

        try (FileOutputStream out = new FileOutputStream(CONFIG_FILE)) {
            props.store(out, "Smart Campus Parking Database Configuration");
        } catch (Exception e) {
            System.err.println("Warning: Could not save db_config.properties: " + e.getMessage());
        }
    }

    public String getJdbcUrl() {
        return "jdbc:mysql://" + host + ":" + port + "/" + database + "?allowMultiQueries=true&createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    }

    public String getBaseJdbcUrl() {
        return "jdbc:mysql://" + host + ":" + port + "/?allowMultiQueries=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    }

    public String getHost() { return host; }
    public void setHost(String host) { this.host = host; }

    public int getPort() { return port; }
    public void setPort(int port) { this.port = port; }

    public String getDatabase() { return database; }
    public void setDatabase(String database) { this.database = database; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public boolean isUseMockFallback() { return useMockFallback; }
    public void setUseMockFallback(boolean useMockFallback) { this.useMockFallback = useMockFallback; }
}
