package FinalProject;

import FinalProject.view.HomeView;
import javafx.application.Application;
import javafx.stage.Stage;

public class Main extends Application {
    @Override
    public void start(Stage primaryStage) {
        new HomeView().show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}