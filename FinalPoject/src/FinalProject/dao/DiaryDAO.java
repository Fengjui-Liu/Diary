package FinalProject.dao;

import FinalProject.model.Diary;
import FinalProject.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DiaryDAO {

    public static void saveDiary(Diary diary) {
        String sql = """
            INSERT INTO diary (diary_date, mood, weather, content, image_path)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                mood = VALUES(mood),
                weather = VALUES(weather),
                content = VALUES(content),
                image_path = VALUES(image_path)
            """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, diary.getDate());
            stmt.setString(2, diary.getMood());
            stmt.setString(3, diary.getWeather());
            stmt.setString(4, diary.getContent());
            stmt.setString(5, diary.getImagePath());
            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static Diary loadDiary(String date) {
        String sql = "SELECT * FROM diary WHERE diary_date = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, date);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new Diary(
                    date,
                    rs.getString("mood"),
                    rs.getString("weather"),
                    rs.getString("content"),
                    rs.getString("image_path")
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<Diary> getAllDiaries() {
        List<Diary> list = new ArrayList<>();
        String sql = "SELECT * FROM diary ORDER BY diary_date DESC";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                list.add(new Diary(
                    rs.getString("diary_date"),
                    rs.getString("mood"),
                    rs.getString("weather"),
                    rs.getString("content"),
                    rs.getString("image_path")
                ));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}