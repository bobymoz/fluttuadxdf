package com.example.test_project

import android.app.Presentation
import android.app.PictureInPictureParams
import android.content.Context
import android.graphics.Color
import android.media.MediaRouter
import android.media.MediaRouter.RouteInfo
import android.os.Build
import android.os.Bundle
import android.util.Rational
import android.view.Display
import android.view.SurfaceView
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // ── Canais Flutter ─────────────────────────────────────────────────────
    private val PIP_CHANNEL   = "cdcine/pip"
    private val CAST_CHANNEL  = "cdcine/cast"
    private val EVENT_CHANNEL = "cdcine/cast_events"

    // ── MediaRouter ────────────────────────────────────────────────────────
    private lateinit var mediaRouter: MediaRouter
    private var currentPresentation: CdcinePresentation? = null
    private var eventSink: EventChannel.EventSink? = null

    // ── Callback do MediaRouter ────────────────────────────────────────────
    private val routerCallback = object : MediaRouter.SimpleCallback() {
        override fun onRouteSelected(router: MediaRouter, type: Int, info: RouteInfo) {
            connectToRoute(info)
        }
        override fun onRouteUnselected(router: MediaRouter, type: Int, info: RouteInfo) {
            currentPresentation?.dismiss()
            currentPresentation = null
            sendEvent("disconnected", null)
        }
        override fun onRouteAdded(router: MediaRouter, info: RouteInfo) {
            sendEvent("route_added", info.name.toString())
        }
        override fun onRouteRemoved(router: MediaRouter, info: RouteInfo) {
            sendEvent("route_removed", info.name.toString())
        }
        override fun onRoutePresentationDisplayChanged(router: MediaRouter, info: RouteInfo) {
            if (info == router.getSelectedRoute(MediaRouter.ROUTE_TYPE_LIVE_VIDEO)) connectToRoute(info)
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Lifecycle
    // ═══════════════════════════════════════════════════════════════════════

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mediaRouter = getSystemService(Context.MEDIA_ROUTER_SERVICE) as MediaRouter
    }

    override fun onResume() {
        super.onResume()
        mediaRouter.addCallback(
            MediaRouter.ROUTE_TYPE_LIVE_VIDEO,
            routerCallback,
            MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN
        )
    }

    override fun onPause() {
        mediaRouter.removeCallback(routerCallback)
        super.onPause()
    }

    override fun onDestroy() {
        currentPresentation?.dismiss()
        super.onDestroy()
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Registar canais Flutter
    // ═══════════════════════════════════════════════════════════════════════

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── 1. Canal PiP (já existia — mantido igual) ──────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PIP_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "enterPiP") {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val params = PictureInPictureParams.Builder()
                            .setAspectRatio(Rational(16, 9))
                            .build()
                        enterPictureInPictureMode(params)
                        result.success(null)
                    } else {
                        result.error("NOT_SUPPORTED", "PiP not supported", null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        // ── 2. Canal Cast (novo) ───────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAST_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // Listar TVs/ecrãs disponíveis na rede Wi-Fi
                    "getRoutes" -> result.success(getAvailableRoutes())

                    // Ligar a uma rota pelo índice
                    "selectRoute" -> {
                        val index  = call.argument<Int>("index") ?: 0
                        val routes = getAvailableRouteInfos()
                        if (index < routes.size) {
                            mediaRouter.selectRoute(
                                MediaRouter.ROUTE_TYPE_LIVE_VIDEO,
                                routes[index]
                            )
                            result.success(true)
                        } else {
                            result.error("INVALID_INDEX", "Rota não encontrada", null)
                        }
                    }

                    // Desligar e voltar ao ecrã do telemóvel
                    "disconnect" -> {
                        mediaRouter.selectRoute(
                            MediaRouter.ROUTE_TYPE_LIVE_VIDEO,
                            mediaRouter.defaultRoute
                        )
                        currentPresentation?.dismiss()
                        currentPresentation = null
                        result.success(true)
                    }

                    // Verificar se está ligado
                    "isConnected" -> result.success(
                        currentPresentation != null && currentPresentation!!.isShowing
                    )

                    else -> result.notImplemented()
                }
            }

        // ── 3. EventChannel — envia eventos de cast para o Flutter ─────────
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════════════════

    private fun getAvailableRouteInfos(): List<RouteInfo> {
        val list = mutableListOf<RouteInfo>()
        for (i in 0 until mediaRouter.routeCount) {
            val route = mediaRouter.getRouteAt(i)
            if (route.supportedTypes and MediaRouter.ROUTE_TYPE_LIVE_VIDEO != 0
                && route != mediaRouter.defaultRoute) {
                list.add(route)
            }
        }
        return list
    }

    private fun getAvailableRoutes(): List<Map<String, String>> {
        return getAvailableRouteInfos().map { route ->
            mapOf(
                "name"        to route.name.toString(),
                "description" to (route.description?.toString() ?: ""),
                "isSelected"  to (route == mediaRouter.getSelectedRoute(MediaRouter.ROUTE_TYPE_LIVE_VIDEO)).toString()
            )
        }
    }

    private fun connectToRoute(info: RouteInfo) {
        val display = info.presentationDisplay ?: return
        currentPresentation?.dismiss()
        currentPresentation = null
        try {
            val p = CdcinePresentation(this, display)
            p.setOnDismissListener {
                if (currentPresentation == p) {
                    currentPresentation = null
                    sendEvent("disconnected", null)
                }
            }
            p.show()
            currentPresentation = p
            sendEvent("connected", info.name.toString())
        } catch (e: WindowManager.InvalidDisplayException) {
            sendEvent("error", "Ecrã inválido: ${e.message}")
        }
    }

    private fun sendEvent(type: String, data: String?) {
        runOnUiThread {
            eventSink?.success(mapOf("type" to type, "data" to (data ?: "")))
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Janela exibida na TV via Miracast / Wi-Fi Direct
// ═══════════════════════════════════════════════════════════════════════════
class CdcinePresentation(context: Context, display: Display) : Presentation(context, display) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val view = SurfaceView(context)
        view.setBackgroundColor(Color.BLACK)
        setContentView(view)
        window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
