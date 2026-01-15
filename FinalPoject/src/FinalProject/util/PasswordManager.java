package FinalProject.util;

import java.io.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class PasswordManager {
    private static final String FILE = "config/password.txt";

    public static void ensurePasswordExists() {
        File f = new File(FILE);
        if (!f.exists()) {
            new File("config").mkdirs();
        }
    }

    public static boolean hasPassword() {
        return new File(FILE).exists();
    }

    public static void setPassword(String plainText) throws IOException {
        String hash = hashPassword(plainText);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE))) {
            writer.write(hash);
        }
    }

    public static boolean validate(String input) {
        try {
            String hash = hashPassword(input);
            BufferedReader reader = new BufferedReader(new FileReader(FILE));
            String saved = reader.readLine();
            reader.close();
            return hash.equals(saved);
        } catch (Exception e) {
            return false;
        }
    }

    private static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            return null;
        }
    }
}