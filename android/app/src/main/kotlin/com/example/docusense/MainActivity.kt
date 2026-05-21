package com.example.docusense

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity : FlutterActivity() {
	private val channelName = "docusense/storage"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"saveToDownloads" -> {
						val bytes = call.argument<ByteArray>("bytes")
						val fileName = call.argument<String>("fileName") ?: "document"
						val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"

						if (bytes == null || bytes.isEmpty()) {
							result.error("INVALID_BYTES", "No file bytes received", null)
							return@setMethodCallHandler
						}

						try {
							val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
								val values = ContentValues().apply {
									put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
									put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
									put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/Docusense")
									put(MediaStore.MediaColumns.IS_PENDING, 1)
								}

								contentResolver.insert(
									MediaStore.Downloads.EXTERNAL_CONTENT_URI,
									values,
								) ?: throw IllegalStateException("Unable to create download entry")
							} else {
								@Suppress("DEPRECATION")
								val downloadsDir = android.os.Environment
									.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DOWNLOADS)
								val folder = java.io.File(downloadsDir, "Docusense")
								if (!folder.exists()) folder.mkdirs()
								val file = java.io.File(folder, fileName)
								file.outputStream().use { output ->
									output.write(bytes)
								}
								result.success(file.absolutePath)
								return@setMethodCallHandler
							}

							val outputStream: OutputStream? = contentResolver.openOutputStream(uri)
							if (outputStream == null) {
								throw IllegalStateException("Unable to open output stream")
							}

							outputStream.use { output ->
								output.write(bytes)
							}

							if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
								val publishedValues = ContentValues().apply {
									put(MediaStore.MediaColumns.IS_PENDING, 0)
								}
								contentResolver.update(uri, publishedValues, null, null)
							}

							result.success(uri.toString())
						} catch (e: Exception) {
							result.error("SAVE_FAILED", e.message, null)
						}
					}

					else -> result.notImplemented()
				}
			}
	}
}
