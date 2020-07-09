package com.jddeep.monumento

import android.annotation.SuppressLint
import android.graphics.Point
import android.net.Uri
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.annotation.RequiresApi
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

    private val monumentModelMap : HashMap<String, String> = hashMapOf(
        "Taj Mahal" to "https://poly.googleusercontent.com/downloads/c/fp/1594202789615202/ajc6GfQ7_d_/fZXEbDa8gRt/taj.gltf"
    )


    @RequiresApi(Build.VERSION_CODES.N)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.sceneform_fragment)

        arFragment = sceneform_frag as ArFragment

        // Adds a listener to the ARSceneView
        // Called before processing each frame
        arFragment.arSceneView.scene.addOnUpdateListener { frameTime ->
            arFragment.onUpdate(frameTime)
            onUpdate()
        }

        // Using POLY for the AR models
        // https://github.com/jddeep/monument-models/raw/master/models/taj.gltf
        floatingActionButton.setOnClickListener { monumentModelMap["Taj Mahal"]?.let { model ->
            addObject(
                model
            )
            showFab(false)
            isFabActive = false
        } }
        showFab(false)
    }

    @SuppressLint("RestrictedApi")
    private fun showFab(enabled: Boolean) {
        if (enabled) {
            floatingActionButton.isEnabled = true
            floatingActionButton.visibility = View.VISIBLE
        } else {
            floatingActionButton.isEnabled = false
            floatingActionButton.visibility = View.GONE
        }
    }

    // Updates the tracking state
    private fun onUpdate() {
        updateTracking()
        // Check if the devices gaze is hitting a plane detected by ARCore
        if (isTracking) {
            val hitTestChanged = updateHitTest()
            if (hitTestChanged) {
                if(isFabActive)
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
            .setSource(fragment.context, RenderableSource.builder().setSource(
                fragment.context,
                Uri.parse(model),
                RenderableSource.SourceType.GLTF2)
                .build())
            .setRegistryId(model)
            .build()
            .thenAccept {
                addNodeToScene(fragment, anchor, it)
            }
            .exceptionally {
                Toast.makeText(this@SceneformFragment, "Error"+it.message, Toast.LENGTH_SHORT).show()
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
    }
}
