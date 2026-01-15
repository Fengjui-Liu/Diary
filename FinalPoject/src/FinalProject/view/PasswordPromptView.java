package FinalProject.view;

import FinalProject.util.PasswordManager;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class PasswordPromptView {
    public void show() {
        Stage stage = new Stage();
        stage.setTitle("🔒 輸入密碼");

        VBox root = new VBox(10);
        root.setPadding(new Insets(30));
        root.setAlignment(Pos.CENTER);

        PasswordField passwordField = new PasswordField();
        passwordField.setPromptText("請輸入密碼...");
        Button submit = new Button("進入日記本");

        if (!PasswordManager.hasPassword()) {
            stage.setTitle("🔑 設定密碼");
            submit.setText("設定密碼");
            submit.setOnAction(e -> {
                try {
                    PasswordManager.setPassword(passwordField.getText());
                    new Alert(Alert.AlertType.INFORMATION, "✅ 密碼設定完成！").showAndWait();
                    stage.close();
                    new HomeView().show();
                } catch (Exception ex) {
                    new Alert(Alert.AlertType.ERROR, "❌ 無法設定密碼：" + ex.getMessage()).showAndWait();
                }
            });
        } else {
            submit.setOnAction(e -> {
                if (PasswordManager.validate(passwordField.getText())) {
                    stage.close();
                    new HomeView().show();
                } else {
                    new Alert(Alert.AlertType.ERROR, "❌ 密碼錯誤").showAndWait();
                }
            });
        }

        root.getChildren().addAll(new Label("🔐 請輸入密碼"), passwordField, submit);
        stage.setScene(new Scene(root, 350, 200));
        stage.show();
    }
}
