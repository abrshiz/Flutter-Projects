package com.abrshiz.myapplication;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
public class MainActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        EditText etFirst = findViewById(R.id.etFirst);
        EditText etMiddle = findViewById(R.id.etMiddle);
        EditText etLast = findViewById(R.id.etLast);
        Button btnCombine = findViewById(R.id.btnCombine);
        TextView tvResult = findViewById(R.id.tvResult);
        btnCombine.setOnClickListener(v -> {
            String f = etFirst.getText().toString().trim();
            String m = etMiddle.getText().toString().trim();
            String l = etLast.getText().toString().trim();
            String full = f + (m.isEmpty() ? "" : " " + m) + (l.isEmpty() ? "" : " " + l);
            tvResult.setText(full.isEmpty() ? "Please enter at least one name" : "Full Name: " + full.trim());
        });
    }
}