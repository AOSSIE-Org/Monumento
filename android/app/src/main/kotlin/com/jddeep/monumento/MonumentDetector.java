 package com.jddeep.monumento;

 import android.Manifest;
 import android.annotation.SuppressLint;
 import android.content.Intent;
 import android.content.pm.PackageManager;
 import android.graphics.Bitmap;
 import android.os.AsyncTask;
 import android.os.Bundle;
 import android.provider.MediaStore;
 import android.util.Log;
 import android.view.DragEvent;
 import android.view.View;
 import android.widget.ImageView;
 import android.widget.ProgressBar;
 import android.widget.TextView;

 import androidx.annotation.NonNull;
 import androidx.appcompat.app.AppCompatActivity;
 import androidx.core.app.ActivityCompat;
 import androidx.core.content.ContextCompat;

 import com.google.android.material.button.MaterialButton;
 import com.google.android.material.floatingactionbutton.FloatingActionButton;
 import com.google.api.client.extensions.android.http.AndroidHttp;
 import com.google.api.client.googleapis.json.GoogleJsonResponseException;
 import com.google.api.client.http.HttpTransport;
 import com.google.api.client.json.JsonFactory;
 import com.google.api.client.json.gson.GsonFactory;
 import com.google.api.services.vision.v1.Vision;
 import com.google.api.services.vision.v1.VisionRequestInitializer;
 import com.google.api.services.vision.v1.model.AnnotateImageRequest;
 import com.google.api.services.vision.v1.model.AnnotateImageResponse;
 import com.google.api.services.vision.v1.model.BatchAnnotateImagesRequest;
 import com.google.api.services.vision.v1.model.BatchAnnotateImagesResponse;
 import com.google.api.services.vision.v1.model.EntityAnnotation;
 import com.google.api.services.vision.v1.model.Feature;
 import com.google.api.services.vision.v1.model.Image;
 import com.sothree.slidinguppanel.SlidingUpPanelLayout;

 import org.jetbrains.annotations.NotNull;

 import java.io.ByteArrayOutputStream;
 import java.io.IOException;
 import java.io.Serializable;
 import java.util.ArrayList;
 import java.util.List;
 import java.util.Map;

 public class MonumentDetector extends AppCompatActivity {

     private static final String TAG = "MonumentDetector";
     private static final int RECORD_REQUEST_CODE = 101;
     private static final int CAMERA_REQUEST_CODE = 102;

     private static final String CLOUD_VISION_API_KEY = BuildConfig.CLOUD_VISION_API_KEY;

     FloatingActionButton takePicture;
     ProgressBar imageUploadProgress;
     ImageView imageView;
     TextView visionAPIData;
     MaterialButton arFragBtn;
     TextView arInfoTv;

     private Feature feature;
     private static final String api = "LANDMARK_DETECTION";
     private static String monument = "";

     @Override
     protected void onCreate(Bundle savedInstanceState) {
         super.onCreate(savedInstanceState);
         setContentView(R.layout.activity_monument_detector);

         List<Map<String, String>> monumentListMap = (List<Map<String, String>>) getIntent()
                 .getSerializableExtra("monumentsListMap");

         SlidingUpPanelLayout spl = new SlidingUpPanelLayout(this);
         spl.setOnDragListener(new View.OnDragListener() {
             @Override
             public boolean onDrag(View v, DragEvent event) {
                 if (event.getY() > 300.0f) v.setVisibility(View.INVISIBLE);
                 else v.setVisibility(View.INVISIBLE);
                 return true;
             }
         });

         Log.e("MonumentDetectorList: ", monumentListMap != null ? monumentListMap.toString() : "null");

         takePicture = findViewById(R.id.takePicture);
         imageUploadProgress = findViewById(R.id.imageProgress);
         imageView = findViewById(R.id.imageView);
         visionAPIData = findViewById(R.id.visionAPIData);
         arFragBtn = findViewById(R.id.nav_ar_frag_btn);
         arInfoTv = findViewById(R.id.augment_text);
         arFragBtn.setOnClickListener(v -> {
              Intent intent = new Intent(MonumentDetector.this, SceneformFragment.class);
             Log.d(TAG, "onCreate: monument"+monument);
             Log.d(TAG, "onCreate: monumentmap"+monumentListMap);
             intent.putExtra("monument", monument);
             intent.putExtra("monumentListMap", (Serializable) monumentListMap);
             startActivity(intent);
         });

         feature = new Feature();
         feature.setType(api);
         feature.setMaxResults(10);

         takePicture.setOnClickListener(new View.OnClickListener() {
             @Override
             public void onClick(View view) {
                 takePictureFromCamera();
             }
         });
     }

     @Override
     protected void onResume() {
         super.onResume();
         if (checkPermission() == PackageManager.PERMISSION_GRANTED) {
             Log.d(TAG, "Camera Permission Granted");
         } else {
             Log.d(TAG, "Camera Permission Not Granted, requesting again");
             makeRequest();
         }
     }

     private int checkPermission() {
         return ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
     }

     private void makeRequest() {
         ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, RECORD_REQUEST_CODE);
     }

     public void takePictureFromCamera() {
         Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
         startActivityForResult(intent, CAMERA_REQUEST_CODE);
     }

     @Override
     protected void onActivityResult(int requestCode, int resultCode,
                                     Intent data) {
         super.onActivityResult(requestCode, resultCode, data);
         if (requestCode == CAMERA_REQUEST_CODE && resultCode == RESULT_OK) {
             Bitmap bitmap = (Bitmap) data.getExtras().get("data");
             imageView.setImageBitmap(bitmap);
             callCloudVision(bitmap, feature);
         }
     }

     @Override
     public void onRequestPermissionsResult(int requestCode, @NotNull String[] permissions, @NotNull int[] grantResults) {
         super.onRequestPermissionsResult(requestCode, permissions, grantResults);
         if (requestCode == RECORD_REQUEST_CODE) {
             if (grantResults.length == 0 || grantResults[0] == PackageManager.PERMISSION_DENIED) {
                 finish();
             }
         }
     }

     @SuppressLint("StaticFieldLeak")
     private void callCloudVision(final Bitmap bitmap, final Feature feature) {
         imageUploadProgress.setVisibility(View.VISIBLE);
         final List<Feature> featureList = new ArrayList<>();
         featureList.add(feature);

         final List<AnnotateImageRequest> annotateImageRequests = new ArrayList<>();

         AnnotateImageRequest annotateImageReq = new AnnotateImageRequest();
         annotateImageReq.setFeatures(featureList);
         annotateImageReq.setImage(getImageEncodeImage(bitmap));
         annotateImageRequests.add(annotateImageReq);


         new AsyncTask<Object, Void, String>() {
             @Override
             protected String doInBackground(Object... params) {
                 try {

                     HttpTransport httpTransport = AndroidHttp.newCompatibleTransport();
                     JsonFactory jsonFactory = GsonFactory.getDefaultInstance();

                     VisionRequestInitializer requestInitializer = new VisionRequestInitializer(CLOUD_VISION_API_KEY);

                     Vision.Builder builder = new Vision.Builder(httpTransport, jsonFactory, null);
                     builder.setVisionRequestInitializer(requestInitializer);

                     Vision vision = builder.build();

                     BatchAnnotateImagesRequest batchAnnotateImagesRequest = new BatchAnnotateImagesRequest();
                     batchAnnotateImagesRequest.setRequests(annotateImageRequests);

                     Vision.Images.Annotate annotateRequest = vision.images().annotate(batchAnnotateImagesRequest);
                     annotateRequest.setDisableGZipContent(true);
                     BatchAnnotateImagesResponse response = annotateRequest.execute();
                     return convertResponseToString(response);
                 } catch (GoogleJsonResponseException e) {
                     Log.e(TAG, "failed to make API request because " + e.getContent());
                 } catch (IOException e) {
                     Log.e(TAG, "failed to make API request because of other IOException " + e.getMessage());
                 }
                 return "Cloud Vision API request failed. Check logs for details.";
             }

             protected void onPostExecute(String result) {
                 visionAPIData.setText(result);
                 imageUploadProgress.setVisibility(View.INVISIBLE);
                 arFragBtn.setVisibility(View.VISIBLE);
                 arInfoTv.setVisibility(View.VISIBLE);
             }
         }.execute();
     }

     @NonNull
     private Image getImageEncodeImage(Bitmap bitmap) {
         Image base64EncodedImage = new Image();
         // Convert the bitmap to a JPEG
         // Just in case it's a format that Android understands but Cloud Vision
         ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
         bitmap.compress(Bitmap.CompressFormat.JPEG, 90, byteArrayOutputStream);
         byte[] imageBytes = byteArrayOutputStream.toByteArray();

         // Base64 encode the JPEG
         base64EncodedImage.encodeContent(imageBytes);
         return base64EncodedImage;
     }

     private String convertResponseToString(BatchAnnotateImagesResponse response) {

         if (response == null || response.getResponses() == null) return "";

         Log.e("Responses: ", response.getResponses().toString());
         AnnotateImageResponse imageResponses = response.getResponses().get(0);

         List<EntityAnnotation> entityAnnotations;

         String message = "";
         entityAnnotations = imageResponses.getLandmarkAnnotations();
         message = formatAnnotation(entityAnnotations);
         return message;
     }

     private String formatAnnotation(List<EntityAnnotation> entityAnnotation) {
         String message = "";

         if (entityAnnotation != null) {
             message = entityAnnotation.get(0).getDescription();
             Log.e("messageMon: ", message);
         } else {
             message = "Nothing Found";
         }
         monument = message.trim();
         return message;
     }
 }
