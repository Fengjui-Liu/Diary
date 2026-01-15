package FinalProject.view;

import FinalProject.dao.DiaryDAO;
import FinalProject.model.Diary;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.image.Image;             // JavaFX Image
import javafx.scene.image.ImageView;
import javafx.scene.layout.*;
import javafx.stage.FileChooser;
import javafx.stage.Stage;

import java.io.*;

public class DiaryView {
    private final String date;
    private final Runnable onSaveCallback;
    private Stage stage;
    private File selectedImageFile;
    private ComboBox<String> moodBox;
    private ComboBox<String> weatherBox;
    private TextArea content;
    private ImageView imagePreview;
    private VBox box;

    public DiaryView(String date) {
        this(date, null);
    }
    public DiaryView(String date, Runnable onSaveCallback) {
        this.date = date;
        this.onSaveCallback = onSaveCallback;
    }

    public void show() {
        stage = new Stage();
        stage.setTitle("📔 日記 - " + date);

        BorderPane root = new BorderPane();

        // Menu
        MenuBar mb = new MenuBar();
        Menu file = new Menu("📁 檔案");
        MenuItem save = new MenuItem("💾 儲存日記");
        save.setOnAction(e -> doSave());
        MenuItem exp = new MenuItem("📤 匯出 PDF");
        exp.setOnAction(e -> doExportPDF());
        MenuItem close = new MenuItem("❌ 關閉");
        close.setOnAction(e -> stage.close());
        file.getItems().addAll(save, exp, close);
        mb.getMenus().addAll(file);
        root.setTop(mb);

        // Content
        box = new VBox(12);
        box.setPadding(new Insets(20));

        Label lbl = new Label("📅 日期： " + date);
        lbl.setStyle("-fx-font-size:18px; -fx-font-weight:bold;");

        moodBox = new ComboBox<>();
        moodBox.getItems().addAll("😊 很棒","🙂 普通","😀 超好","😕 難過","🤯 爆炸了");
        moodBox.setPromptText("選擇心情");

        weatherBox = new ComboBox<>();
        weatherBox.getItems().addAll("☀️ 晴朗","⛅ 多雲","🌧 下雨","⛈ 雷雨","❄️ 下雪");
        weatherBox.setPromptText("選擇天氣");

        content = new TextArea();
        content.setPromptText("輸入今天的心情與事...");
        content.setWrapText(true);
        content.setPrefRowCount(8);

        imagePreview = new ImageView();
        imagePreview.setFitWidth(300);
        imagePreview.setFitHeight(200);
        imagePreview.setPreserveRatio(true);

        Button imgBtn = new Button("🖼 插入圖片");
        imgBtn.setOnAction(e -> {
            File f = new FileChooser().showOpenDialog(stage);
            if (f != null) {
                selectedImageFile = f;
                imagePreview.setImage(new Image(f.toURI().toString()));
            }
        });

        Button saveBtn = new Button("✅ 儲存並套色");
        saveBtn.setOnAction(e -> doSave());

        box.getChildren().addAll(
            lbl,
            new Label("心情："), moodBox,
            new Label("天氣："), weatherBox,
            new Label("內容："), content,
            imgBtn, imagePreview,
            saveBtn
        );

        root.setCenter(new ScrollPane(box));
        Scene sc = new Scene(root, 600, 650);
        stage.setScene(sc);
        stage.show();

        loadFromDB();
        applyBg();
    }

    private void doSave() {
        Diary d = new Diary(
            date,
            moodBox.getValue(),
            weatherBox.getValue(),
            content.getText(),
            selectedImageFile==null?null:selectedImageFile.getAbsolutePath()
        );
        DiaryDAO.saveDiary(d);

        // 存 txt
        File dir = new File("diary");
        if (!dir.exists()) dir.mkdirs();
        try (BufferedWriter w = new BufferedWriter(new FileWriter(new File(dir,"Diary_"+date+".txt")))) {
            w.write(date+"\n");
            w.write(moodBox.getValue()+"\n");
            w.write(weatherBox.getValue()+"\n");
            w.write(content.getText());
        } catch (IOException ex) {
            ex.printStackTrace();
        }

        new Alert(Alert.AlertType.INFORMATION, "✅ 已儲存！").showAndWait();
        applyBg();
        if (onSaveCallback!=null) onSaveCallback.run();
    }

    private void loadFromDB() {
        Diary d = DiaryDAO.loadDiary(date);
        if (d!=null) {
            moodBox.setValue(d.getMood());
            weatherBox.setValue(d.getWeather());
            content.setText(d.getContent());
            if (d.getImagePath()!=null) {
                File f = new File(d.getImagePath());
                if (f.exists()) {
                    selectedImageFile = f;
                    imagePreview.setImage(new Image(f.toURI().toString()));
                }
            }
        }
    }

    private void applyBg() {
        String m=moodBox.getValue(), w=weatherBox.getValue(), c="#FFF";
        if ("😊 很棒".equals(m)&&"☀️ 晴朗".equals(w))      c="#FFFDE7";
        else if ("🙂 普通".equals(m)&&"⛅ 多雲".equals(w))  c="#E8F0FE";
        else if ("😀 超好".equals(m))                        c="#E0F7FA";
        else if ("😕 難過".equals(m))                       c="#F3E5F5";
        else if ("🤯 爆炸了".equals(m))                     c="#F8D7DA";
        box.setStyle(
            "-fx-background-color:"+c+";" +
            "-fx-border-color:#DDD;-fx-border-radius:6;-fx-background-radius:6;"
        );
    }

    private void doExportPDF() {
        FileChooser fc = new FileChooser();
        fc.setInitialFileName("Diary_"+date+".pdf");
        File out = fc.showSaveDialog(stage);
        if (out==null) return;

        final BaseColor bg = switch(moodBox.getValue()+"|"+weatherBox.getValue()) {
            case "😊 很棒|☀️ 晴朗" -> new BaseColor(255,248,225);
            case "🙂 普通|⛅ 多雲" -> new BaseColor(232,240,254);
            case "😀 超好|☀️ 晴朗" -> new BaseColor(255,253,231);
            case "😕 難過|🌧 下雨" -> new BaseColor(236,240,241);
            case "🤯 爆炸了|⛈ 雷雨" -> new BaseColor(255,235,238);
            default -> BaseColor.WHITE;
        };

        try {
            Document doc = new Document(PageSize.A4,40,40,60,60);
            PdfWriter writer = PdfWriter.getInstance(doc,new FileOutputStream(out));
            writer.setPageEvent(new PdfPageEventHelper(){
                @Override
                public void onEndPage(PdfWriter w, Document d) {
                    PdfContentByte cb = w.getDirectContentUnder();
                    Rectangle r = d.getPageSize();
                    cb.saveState();
                    cb.setColorFill(bg);
                    cb.rectangle(0,0,r.getWidth(),r.getHeight());
                    cb.fill();
                    cb.restoreState();
                }
            });
            doc.open();

            // Title
            Font h1 = new Font(Font.FontFamily.HELVETICA,20,Font.BOLD,BaseColor.DARK_GRAY);
            Paragraph t = new Paragraph("📔 我的日記本",h1);
            t.setAlignment(Element.ALIGN_CENTER);
            doc.add(t);
            doc.add(Chunk.NEWLINE);

            // Body
            BaseFont bf = BaseFont.createFont(
                "NotoSansCJKtc-Regular.otf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED
            );
            Font f = new Font(bf,14,Font.NORMAL,BaseColor.BLACK);
            Paragraph p = new Paragraph(
                "📅 日期： "+date+"\n"+
                "😊 心情： "+(moodBox.getValue()==null?"(未選)":moodBox.getValue())+"\n"+
                "🌦 天氣： "+(weatherBox.getValue()==null?"(未選)":weatherBox.getValue())+"\n\n"+
                content.getText(), f
            );
            p.setAlignment(Element.ALIGN_LEFT);
            doc.add(p);

            // Image
            if (selectedImageFile!=null && selectedImageFile.exists()) {
                com.itextpdf.text.Image img =
                    com.itextpdf.text.Image.getInstance(selectedImageFile.getAbsolutePath());
                img.scaleToFit(300,200);
                img.setAlignment(Element.ALIGN_CENTER);
                doc.add(img);
            }

            doc.close();
            new Alert(Alert.AlertType.INFORMATION, "✅ PDF 匯出成功！").showAndWait();
        } catch(Exception ex) {
            ex.printStackTrace();
            new Alert(Alert.AlertType.ERROR, "❌ 匯出失敗："+ex.getMessage()).showAndWait();
        }
    }
}