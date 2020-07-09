package com.jddeep.monumento;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.widget.Toast;

import com.google.ar.core.Anchor;
import com.google.ar.core.HitResult;
import com.google.ar.core.Plane;
import com.google.ar.sceneform.AnchorNode;
import com.google.ar.sceneform.rendering.ModelRenderable;
import com.google.ar.sceneform.rendering.Renderable;
import com.google.ar.sceneform.ux.ArFragment;
import com.google.ar.sceneform.ux.TransformableNode;

public class ARFragment extends AppCompatActivity {

    private static final String TAG = MainActivity.class.getSimpleName();
    private static final double MIN_OPENGL_VERSION = 3.0;


    ArFragment arFragment;
    ModelRenderable lampPostRenderable;

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!checkIsSupportedDeviceOrFinish(this)) {
            return;
        }
        setContentView(R.layout.activity_a_r_fragment);
        arFragment = (ArFragment) getSupportFragmentManager().findFragmentById(R.id.ux_fragment);

//        ModelRenderable.builder()
//                .setSource(this, Uri.parse("taj.sfb"))
//                .build()
//                .thenAccept(renderable -> lampPostRenderable = renderable)
//                .exceptionally(throwable -> {
//                    Toast toast =
//                            Toast.makeText(this, "Unable to load andy renderable", Toast.LENGTH_LONG);
//                    toast.setGravity(Gravity.CENTER, 0, 0);
//                    toast.show();
//                    return null;
//                });

        arFragment.setOnTapArPlaneListener(
                (HitResult hitresult, Plane plane, MotionEvent motionevent) -> {
//                    if (lampPostRenderable == null){
//                        return;
//                    }

                    Anchor anchor = hitresult.createAnchor();
                    placeObject(arFragment, anchor, Uri.parse("src/main/res/raw/taj.sfb"));
//                    AnchorNode anchorNode = new AnchorNode(anchor);
//                    anchorNode.setParent(arFragment.getArSceneView().getScene());
//
//                    TransformableNode lamp = new TransformableNode(arFragment.getTransformationSystem());
//                    lamp.setParent(anchorNode);
//                    lamp.setRenderable(lampPostRenderable);
//                    lamp.select();
                }
        );
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    private void placeObject(ArFragment arFragment, Anchor anchor, Uri uri) {
        ModelRenderable.builder()
                .setSource(arFragment.getContext(), uri)
                .build()
                .thenAccept(modelRenderable -> addNodeToScene(arFragment, anchor, modelRenderable))
                .exceptionally(throwable -> {
                            Toast.makeText(arFragment.getContext(), "Error:" + throwable.getMessage(), Toast.LENGTH_LONG).show();
                            return null;
                        }

                );
    }

    private void addNodeToScene(ArFragment arFragment, Anchor anchor, Renderable renderable) {
        AnchorNode anchorNode = new AnchorNode(anchor);
        TransformableNode node = new TransformableNode(arFragment.getTransformationSystem());
        node.setRenderable(renderable);
        node.setParent(anchorNode);
        arFragment.getArSceneView().getScene().addChild(anchorNode);
        node.select();
    }

    public static boolean checkIsSupportedDeviceOrFinish(final Activity activity) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            Log.e("ArFragment: ", "Sceneform requires Android N or later");
            Toast.makeText(activity, "Sceneform requires Android N or later", Toast.LENGTH_LONG).show();
            activity.finish();
            return false;
        }
        String openGlVersionString =
                ((ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE))
                        .getDeviceConfigurationInfo()
                        .getGlEsVersion();
        if (Double.parseDouble(openGlVersionString) < MIN_OPENGL_VERSION) {
            Log.e("ARFragment: ", "Sceneform requires OpenGL ES 3.0 later");
            Toast.makeText(activity, "Sceneform requires OpenGL ES 3.0 or later", Toast.LENGTH_LONG)
                    .show();
            activity.finish();
            return false;
        }
        return true;
    }
}
