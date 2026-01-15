package FinalProject.view;

import FinalProject.dao.DiaryDAO;
import FinalProject.model.Diary;

import java.time.LocalDate;
import java.util.List;

import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.Stage;

public class HomeView {
    private VBox diaryCardPanel;

    public void show() {
        Stage stage = new Stage();
        stage.setTitle("📔 我的日記本");

        BorderPane root = new BorderPane();
        diaryCardPanel = new VBox(8);
        diaryCardPanel.setPadding(new Insets(12));
        root.setCenter(new ScrollPane(diaryCardPanel));

        // 上方選單
        MenuBar mb = new MenuBar();
        Menu fileMenu = new Menu("📁 檔案");
        MenuItem exit = new MenuItem("❌ 離開");
        exit.setOnAction(e -> stage.close());
        fileMenu.getItems().add(exit);

        Menu diaryMenu = new Menu("📖 日記");
        MenuItem addToday = new MenuItem("🆕 寫今天日記");
        addToday.setOnAction(e -> {
            String today = LocalDate.now().toString();
            new DiaryView(today, this::refresh).show();
        });
        MenuItem calendar = new MenuItem("📅 日曆模式");
        calendar.setOnAction(e -> new CalendarView(this::refresh).show());

        diaryMenu.getItems().addAll(addToday, calendar);
        mb.getMenus().addAll(fileMenu, diaryMenu);
        root.setTop(mb);

        refresh();

        Scene scene = new Scene(root, 800, 600);
        stage.setScene(scene);
        stage.show();
    }

    private void refresh() {
        diaryCardPanel.getChildren().clear();
        List<Diary> list = DiaryDAO.getAllDiaries();
        for (Diary d : list) {
            VBox card = new VBox(6);
            card.setPadding(new Insets(8));
            card.setStyle(
                "-fx-background-color:#FFFFFF;" +
                "-fx-border-color:#DDD;" +
                "-fx-border-radius:4;" +
                "-fx-background-radius:4;"
            );

            Label lbl = new Label("📅 " + d.getDate());
            lbl.setStyle("-fx-font-size:14px; -fx-font-weight:bold;");

            Button openBtn = new Button("開啟日記");
            openBtn.setOnAction(e -> new DiaryView(d.getDate(), this::refresh).show());

            card.getChildren().addAll(lbl, openBtn);
            diaryCardPanel.getChildren().add(card);
        }
    }
}