package de.metzgerapp.metzgerapp

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/** Android Storage Access Framework: no broad storage or Internet permission. */
class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null
    private var pendingImage = false
    private val pickCode = 9401
    private val saveCode = 9402
    private val limit = 64 * 1024 * 1024

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "de.metzgerapp/files")
            .setMethodCallHandler { call, result ->
                if (pending != null) {
                    result.error("BUSY", "Ein Dateidialog ist bereits geöffnet.", null)
                    return@setMethodCallHandler
                }
                try {
                    when (call.method) {
                        "pick" -> {
                            pending = result
                            val mime = call.argument<String>("mime") ?: "*/*"
                            pendingImage = mime.startsWith("image/")
                            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = if (mime == "application/json") "*/*" else mime
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                            startActivityForResult(intent, pickCode)
                        }
                        "save" -> {
                            val bytes = call.argument<ByteArray>("bytes")
                            if (bytes == null || bytes.size > limit) {
                                result.error("SIZE", "Datei fehlt oder ist größer als 64 MB.", null)
                                return@setMethodCallHandler
                            }
                            pending = result
                            pendingBytes = bytes
                            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = call.argument<String>("mime") ?: "application/octet-stream"
                                putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: "metzgerapp.dat")
                                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                            }
                            startActivityForResult(intent, saveCode)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    pending = null
                    pendingBytes = null
                    result.error("FILE_DIALOG", e.message, null)
                }
            }
    }

    private fun compactPhoto(raw: ByteArray): ByteArray {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(raw, 0, raw.size, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) throw IllegalArgumentException("Bildformat wird nicht unterstützt.")
        var sample = 1
        while (maxOf(bounds.outWidth, bounds.outHeight) / sample > 1600) sample *= 2
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        val original = BitmapFactory.decodeByteArray(raw, 0, raw.size, options)
            ?: throw IllegalArgumentException("Bild kann nicht gelesen werden.")
        val factor = minOf(1.0, 1200.0 / maxOf(original.width, original.height))
        val bitmap = if (factor < 1.0) Bitmap.createScaledBitmap(original, maxOf(1,(original.width * factor).toInt()), maxOf(1,(original.height * factor).toInt()), true) else original
        try {
            val out = ByteArrayOutputStream()
            if (!bitmap.compress(Bitmap.CompressFormat.JPEG, 82, out)) throw IllegalArgumentException("Bild kann nicht gespeichert werden.")
            return out.toByteArray()
        } finally {
            if (bitmap !== original) bitmap.recycle()
            original.recycle()
        }
    }

    @Deprecated("Activity result bridge for SAF")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickCode && requestCode != saveCode) return
        val result = pending ?: return
        val bytes = pendingBytes
        val image = pendingImage
        pendingImage = false
        pending = null
        pendingBytes = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(if (requestCode == saveCode) false else null)
            return
        }
        Thread {
            try {
                if (requestCode == pickCode) {
                    val output = ByteArrayOutputStream()
                    contentResolver.openInputStream(uri)?.use { input ->
                        val buffer = ByteArray(8192)
                        while (true) {
                            val read = input.read(buffer)
                            if (read < 0) break
                            if (output.size() + read > limit) throw IllegalArgumentException("Datei größer als 64 MB.")
                            output.write(buffer, 0, read)
                        }
                    } ?: throw IllegalStateException("Datei konnte nicht geöffnet werden.")
                    val readBytes = if (image) compactPhoto(output.toByteArray()) else output.toByteArray()
                    runOnUiThread { result.success(readBytes) }
                } else {
                    contentResolver.openOutputStream(uri, "wt")?.use { stream ->
                        stream.write(bytes ?: throw IllegalStateException("Dateiinhalt fehlt."))
                    } ?: throw IllegalStateException("Datei konnte nicht geschrieben werden.")
                    runOnUiThread { result.success(true) }
                }
            } catch (e: Exception) {
                runOnUiThread { result.error("FILE_IO", e.message, null) }
            }
        }.start()
    }
}
