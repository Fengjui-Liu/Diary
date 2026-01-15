package FinalProject.view;

import java.time.LocalDate;
import java.time.YearMonth;

import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.Stage;

public class CalendarView {
    private final Runnable onSave;

    public CalendarView(Runnable onSave) {
        this.onSave = onSave;
    }

    public void show() {
        Stage stage = new Stage();
        stage.setTitle("📅 日曆模式");

        ComboBox<Integer> yearBox = new ComboBox<>();
        ComboBox<Integer> monthBox = new ComboBox<>();
        int curY = LocalDate.now().getYear();
        for (int y = curY - 2; y <= curY + 2; y++) yearBox.getItems().add(y);
        yearBox.setValue(curY);
        for (int m = 1; m <= 12; m++) monthBox.getItems().add(m);
        monthBox.setValue(LocalDate.now().getMonthValue());

        Button load = new Button("載入");
        GridPane grid = new GridPane();
        grid.setHgap(6);
        grid.setVgap(6);
        grid.setPadding(new Insets(12));

        load.setOnAction(e -> buildCalendar(yearBox.getValue(), monthBox.getValue(), grid));

        HBox top = new HBox(10,
            new Label("年："), yearBox,
            new Label("月："), monthBox,
            load
        );
        top.setPadding(new Insets(12));

        VBox root = new VBox(6, top, grid);
        buildCalendar(curY, LocalDate.now().getMonthValue(), grid);

        Scene scene = new Scene(root, 820, 600);
        stage.setScene(scene);
        stage.show();
    }

    private void buildCalendar(int year, int month, GridPane grid) {
        grid.getChildren().clear();
        String[] days = {"一","二","三","四","五","六","日"};
        for (int i = 0; i < 7; i++) {
            Label l = new Label(days[i]);
            l.setStyle("-fx-font-weight:bold;");
            grid.add(l, i, 0);
        }

        YearMonth ym = YearMonth.of(year, month);
        LocalDate first = ym.atDay(1);
        int dow = first.getDayOfWeek().getValue() % 7;
        int total = ym.lengthOfMonth();
        int col = dow, row = 1;

        for (int d = 1; d <= total; d++) {
            Button b = new Button(String.valueOf(d));
            b.setPrefSize(90, 50);
            b.setOnAction(e -> {
                String dd = String.format("%04d-%02d-%02d",
                    year, month, Integer.parseInt(b.getText()));
                new DiaryView(dd, onSave).show();
            });
            grid.add(b, col, row);
            col++;
            if (col > 6) {
                col = 0;
                row++;
            }
        }
    }
}