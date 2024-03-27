package com.jddeep.monumento

import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.graphics.Point
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import com.google.ar.core.Anchor
import com.google.ar.core.HitResult
import com.google.ar.core.Plane
import com.google.ar.core.TrackingState
import com.google.ar.sceneform.AnchorNode
import com.google.ar.sceneform.assets.RenderableSource
import com.google.ar.sceneform.rendering.ModelRenderable
import com.google.ar.sceneform.ux.ArFragment
import com.google.ar.sceneform.ux.TransformableNode
import kotlinx.android.synthetic.main.sceneform_fragment.*

class SceneformFragment : AppCompatActivity() {

    private lateinit var arFragment: ArFragment

    private var isTracking: Boolean = false
    private var isHitting: Boolean = false
    private var isFabActive: Boolean = true
    private var noModel: Boolean = false
    private var monument: String = ""
    private lateinit var monumentListMap: List<Map<String, String>>
    private val MIN_OPENGL_VERSION = 3.0

    private val monumentModelMap: HashMap<String, String> = hashMapOf(
        "Taj Mahal" to "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Ftaj_mahal%2Fscene.glb?alt=media&token=c6d87d03-c75a-4d53-b09b-f31db72ae7e4",
        "Mount Rushmore National Memorial" to "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fmount_rushmore%2Fscene%20(2).glb?alt=media&token=522ada26-b7ae-4ef0-b682-dc595d6bf732",
        "Eiffel Tower" to "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Feiffel_tower%2Fscene%20(2).glb?alt=media&token=0ed1974f-e14c-4863-8151-0dfc1df2c173",
        "Statue of Liberty" to "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fstatue_of_liberty%2Fscene%20(2).glb?alt=media&token=6c599026-d0c8-41d8-a5fa-7a34bda96fd1",
        "Colosseum" to "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fcolosseum%2Fscene%20(2).glb?alt=media&token=c5d331fe-f81e-4b66-b156-d23d6f4c0619",
        "Leaning Tower of Pisa" to "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fpisa_tower%2Fscene%20(2).glb?alt=media&token=963d4438-3d65-448a-8a54-986d54a429e8"
    )
//    private val monumentModelMap: HashMap<String, String> = hashMapOf(
//        "Taj Mahal" to "https://poly.googleusercontent.com/downloads/c/fp/1594202789615202/ajc6GfQ7_d_/fZXEbDa8gRt/taj.gltf",
//        "Eiffel Tower" to "https://poly.googleusercontent.com/downloads/c/fp/1594652332676840/cPeRoB-RS0Q/4Z73gO10xW3/scene.gltf",
//        "Statue of Liberty" to "https://poly.googleusercontent.com/downloads/c/fp/1594203800428477/ef9Yd09Doxh/6iB-aRbRXqD/model.gltf",
//        "Colosseum" to "https://poly.googleusercontent.com/downloads/c/fp/1594117136139223/cVtCnH0tnHJ/fdSQ8NwCQDK/model.gltf",
//        "Leaning Tower of Pisa" to "https://poly.googleusercontent.com/downloads/c/fp/1592733756165702/9hcSqLXC58h/afqTiZoEw8O/f42649ee9cd14a7db955bdcee2d21ac3.gltf"
//    )



    @SuppressLint("RestrictedApi")
    @RequiresApi(Build.VERSION_CODES.N)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.sceneform_fragment)
        if (!checkIsSupportedDeviceOrFinish(this)) return

        arFragment = sceneform_frag as ArFragment

        val bundle = intent.extras
        monument = bundle?.get("monument").toString()
        Log.e("SceneformMonument: ", monument)
        monumentListMap = bundle?.getSerializable("monumentListMap") as List<Map<String, String>>
        Log.e("SFmonumentListMap: ", monumentListMap[0].toString())

        slidePanelLayout.setDragView(wikiTv)

        wikiWv.settings.loadsImagesAutomatically = true
        wikiWv.isNestedScrollingEnabled = true
        wikiWv.isVerticalScrollBarEnabled = true
        wikiWv.isHorizontalScrollBarEnabled = true
        wikiWv.settings.builtInZoomControls = true
        wikiWv.loadUrl(getWikiUrl(monument.trim()))
        // Adds a listener to the ARSceneView
        // Called before processing each frame
        arFragment.arSceneView.scene.addOnUpdateListener { frameTime ->
            arFragment.onUpdate(frameTime)
            onUpdate()
        }

        val modelKey = getModelKey(monument)
        if (modelKey.isEmpty()) {
            noModel = true
            arFragment.arSceneView.visibility = View.GONE
            floatingActionButton.visibility = View.GONE
            model_loading_pb.visibility = View.GONE
            noModelLl.visibility = View.VISIBLE
            noModelTv.text = "No 3D-Model for '${monument.trim()}'"
        }

        // Using POLY for the AR models
        floatingActionButton.setOnClickListener {
            Log.e("ModelKey: ", modelKey)
            monumentModelMap[modelKey]?.let { model ->
                addObject(
                    model
                )
                isFabActive = false
                showFab(isFabActive)
            }
        }
        if (!noModel)
            showFab(false)

//        nav_wiki_btn.setOnClickListener {
//            Log.e("SceneFrag: ", "Wiki btn pressed")
//            slidePanelLayout.panelHeight = 1500
//        }
    }

    private fun getWikiUrl(monument: String?): String {
        var wikiUrl: String = "https://en.m.wikipedia.org/wiki/Main_Page"
        if (monument.isNullOrEmpty() || monument == "Nothing Found") return wikiUrl
        for (monumentMap in monumentListMap) {
            if (monumentMap["name"] == monument && monumentMap["wikipediaLink"] != null) {
                wikiUrl = monumentMap["wikipediaLink"] as String
                break
            }
        }
        return wikiUrl
    }


    private fun getModelKey(monument: String?): String {
        val default = ""
        if (monument.isNullOrEmpty()) return default

        return when (monument.trim()) {
            "Taj Mahal" -> "Taj Mahal"
            "Eiffel Tower" -> "Eiffel Tower"
            "Statue of Liberty" -> "Statue of Liberty"
            "Colosseum" -> "Colosseum"
            "Leaning Tower of Pisa" -> "Leaning Tower of Pisa"
            "Mount Rushmore National Memorial" -> "Mount Rushmore National Memorial"
            else -> default
        }
    }

    @SuppressLint("RestrictedApi")
    private fun showFab(enabled: Boolean) {
        if (enabled) {
            floatingActionButton.isEnabled = true
            floatingActionButton.visibility = View.VISIBLE
        } else {
            floatingActionButton.isEnabled = false
            floatingActionButton.visibility = View.GONE
            if (!isFabActive) {
                model_loading_pb.visibility = View.VISIBLE
            }
        }
    }

    // Updates the tracking state
    private fun onUpdate() {
        updateTracking()
        // Check if the devices gaze is hitting a plane detected by ARCore
        if (isTracking) {
            val hitTestChanged = updateHitTest()
            if (hitTestChanged) {
                if (isFabActive)
                    showFab(isHitting)
            }
        }

    }

    // Performs frame.HitTest and returns if a hit is detected
    private fun updateHitTest(): Boolean {
        val frame = arFragment.arSceneView.arFrame
        val point = getScreenCenter()
        val hits: List<HitResult>
        val wasHitting = isHitting
        isHitting = false
        if (frame != null) {
            hits = frame.hitTest(point.x.toFloat(), point.y.toFloat())
            for (hit in hits) {
                val trackable = hit.trackable
                if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                    isHitting = true
                    break
                }
            }
        }
        return wasHitting != isHitting
    }

    // Makes use of ARCore's camera state and returns true if the tracking state has changed
    private fun updateTracking(): Boolean {
        val frame = arFragment.arSceneView.arFrame
        val wasTracking = isTracking
        isTracking = frame?.camera?.trackingState == TrackingState.TRACKING
        return isTracking != wasTracking
    }

    // Simply returns the center of the screen
    private fun getScreenCenter(): Point {
        val view = findViewById<View>(android.R.id.content)
        return Point(view.width / 2, view.height / 2)
    }

    /**
     * @param model The Uri of our 3D sfb file
     *
     * This method takes in our 3D model and performs a hit test to determine where to place it
     */
    @RequiresApi(Build.VERSION_CODES.N)
    private fun addObject(model: String) {
        val frame = arFragment.arSceneView.arFrame
        val point = getScreenCenter()
        if (frame != null) {
            val hits = frame.hitTest(point.x.toFloat(), point.y.toFloat())
            for (hit in hits) {
                val trackable = hit.trackable
                if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                    placeObject(arFragment, hit.createAnchor(), model)
                    break
                }
            }
        }
    }

    /**
     * @param fragment our fragment
     * @param anchor ARCore anchor from the hit test
     * @param model our 3D model of choice
     *
     * Uses the ARCore anchor from the hitTest result and builds the Sceneform nodes.
     * It starts the asynchronous loading of the 3D model using the ModelRenderable builder.
     */
    @RequiresApi(Build.VERSION_CODES.N)
    private fun placeObject(fragment: ArFragment, anchor: Anchor, model: String) {
        ModelRenderable.builder()
            .setSource(
                fragment.context, RenderableSource.builder().setSource(
                    fragment.context,
                    Uri.parse(model),
                    RenderableSource.SourceType.GLB
                )
                    .build()
            )
            .setRegistryId(model)
            .build()
            .thenAccept {
                addNodeToScene(fragment, anchor, it)
            }
            .exceptionally {
                Toast.makeText(this@SceneformFragment, "Error" + it.message, Toast.LENGTH_SHORT)
                    .show()
                return@exceptionally null
            }
    }

    /**
     * @param fragment our fragment
     * @param anchor ARCore anchor
     * @param renderable our model created as a Sceneform Renderable
     *
     * This method builds two nodes and attaches them to our scene
     * The Anchor nodes is positioned based on the pose of an ARCore Anchor. They stay positioned in the sample place relative to the real world.
     * The Transformable node is our Model
     * Once the nodes are connected we select the TransformableNode so it is available for interactions
     */
    private fun addNodeToScene(fragment: ArFragment, anchor: Anchor, renderable: ModelRenderable) {
        val anchorNode = AnchorNode(anchor)
        // TransformableNode means the user to move, scale and rotate the model
        val transformableNode = TransformableNode(fragment.transformationSystem)
        transformableNode.renderable = renderable
        transformableNode.setParent(anchorNode)
        fragment.arSceneView.scene.addChild(anchorNode)
        transformableNode.select()
        if (!isFabActive) {
            model_loading_pb.visibility = View.GONE
//            nav_wiki_btn.visibility = View.VISIBLE
        }
    }

    private fun checkIsSupportedDeviceOrFinish(activity: Activity): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            Toast.makeText(
                applicationContext,
                "AR Not Supported on old Android version!",
                Toast.LENGTH_SHORT
            )
                .show()

            activity.finish()
            return false;
        }

        val openGlVersion = (activity.getSystemService(ACTIVITY_SERVICE) as ActivityManager)
            .deviceConfigurationInfo.glEsVersion
        if (openGlVersion.toDouble() < MIN_OPENGL_VERSION) {
            Toast.makeText(
                applicationContext,
                "AR Not Supported on old OpenGL version!",
                Toast.LENGTH_SHORT
            )
                .show()

            activity.finish()
            return false
        }
        return true
    }
}
