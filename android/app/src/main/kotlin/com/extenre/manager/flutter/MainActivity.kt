/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

package com.extenre.manager.flutter

import android.app.PendingIntent
import android.app.SearchManager
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.extenre.library.ApkUtils
import com.extenre.library.ApkUtils.applyTo
import com.extenre.manager.flutter.utils.Aapt
import com.extenre.manager.flutter.utils.packageInstaller.InstallerReceiver
import com.extenre.manager.flutter.utils.packageInstaller.UninstallerReceiver
import com.extenre.patcher.Patcher
import com.extenre.patcher.PatcherConfig
import com.extenre.patcher.patch.Patch
import com.extenre.patcher.patch.PatchResult
import com.extenre.patcher.patch.loadPatchesFromDex
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.flow.FlowCollector
import kotlinx.coroutines.runBlocking
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.util.logging.LogRecord
import java.util.logging.Logger

class MainActivity : FlutterActivity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var installerChannel: MethodChannel
    private var cancel: Boolean = false
    private var stopResult: MethodChannel.Result? = null
    private val apkParserChannel = "com.extenre.manager/apk_parser"
    private lateinit var patches: Set<Patch<*>>

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val patcherChannel = "com.extenre.manager.flutter/patcher"
        val installerChannel = "com.extenre.manager.flutter/installer"
        val openBrowserChannel = "com.extenre.manager.flutter/browser"

        // Canal para abrir el navegador
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            openBrowserChannel
        ).setMethodCallHandler { call, result ->
            if (call.method == "openBrowser") {
                val searchQuery = call.argument<String>("query")
                openBrowser(searchQuery)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Canal principal del patcher
        val mainChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, patcherChannel)
        this.installerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, installerChannel)

        mainChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "runPatcher" -> {
                    val inFilePath = call.argument<String>("inFilePath")
                    val outFilePath = call.argument<String>("outFilePath")
                    val selectedPatches = call.argument<List<String>>("selectedPatches")
                    val options = call.argument<Map<String, Map<String, Any>>>("options")
                    val tmpDirPath = call.argument<String>("tmpDirPath")
                    val keyStoreFilePath = call.argument<String>("keyStoreFilePath")
                    val keystorePassword = call.argument<String>("keystorePassword")
                    val ripArchitectureList = call.argument<List<String>>("ripArchitectureList")

                    if (inFilePath != null &&
                        outFilePath != null &&
                        selectedPatches != null &&
                        options != null &&
                        tmpDirPath != null &&
                        keyStoreFilePath != null &&
                        keystorePassword != null &&
                        ripArchitectureList != null
                    ) {
                        cancel = false
                        runPatcher(
                            result,
                            inFilePath,
                            outFilePath,
                            selectedPatches,
                            options,
                            tmpDirPath,
                            keyStoreFilePath,
                            keystorePassword,
                            ripArchitectureList
                        )
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid arguments", "One or more arguments are missing")
                    }
                }
                "stopPatcher" -> {
                    cancel = true
                    stopResult = result
                }
                "getPatches" -> {
                    val patchBundleFilePath = call.argument<String>("patchBundleFilePath")!!
                    try {
                        val patchBundleFile = File(patchBundleFilePath)
                        patchBundleFile.setWritable(false)
                        patches = loadPatchesFromDex(
                            setOf(patchBundleFile),
                            optimizedDexDirectory = codeCacheDir
                        )
                    } catch (t: Throwable) {
                        return@setMethodCallHandler result.error(
                            "PATCH_BUNDLE_ERROR",
                            "Failed to load patch bundle",
                            t.stackTraceToString()
                        )
                    }

                    JSONArray().apply {
                        patches.forEach {
                            JSONObject().apply {
                                put("name", it.name)
                                put("description", it.description)
                                put("excluded", !it.use)
                                put("compatiblePackages", JSONArray().apply {
                                    it.compatiblePackages?.forEach { (name, versions) ->
                                        val compatiblePackageJson = JSONObject().apply {
                                            put("name", name)
                                            put("versions", JSONArray().apply {
                                                versions?.forEach { version -> put(version) }
                                            })
                                        }
                                        put(compatiblePackageJson)
                                    }
                                })
                                put("options", JSONArray().apply {
                                    it.options.values.forEach { option ->
                                        JSONObject().apply {
                                            put("key", option.key)
                                            put("title", option.title)
                                            put("description", option.description)
                                            put("required", option.required)

                                            fun JSONObject.putValue(value: Any?, key: String = "value") =
                                                if (value is Array<*>) {
                                                    put(key, JSONArray().apply { value.forEach { put(it) } })
                                                } else {
                                                    put(key, value)
                                                }

                                            putValue(option.default)
                                            option.values?.let { values ->
                                                put("values", JSONObject().apply {
                                                    values.forEach { (key, value) -> putValue(value, key) }
                                                })
                                            } ?: put("values", null)
                                            put("type", option.type)
                                        }.let(::put)
                                    }
                                })
                            }.let(::put)
                        }
                    }.toString().let(result::success)
                }
                "installApk" -> {
                    val apkPath = call.argument<String>("apkPath")!!
                    PackageInstallerManager.result = result
                    installApk(apkPath)
                }
                "uninstallApp" -> {
                    val packageName = call.argument<String>("packageName")!!
                    uninstallApp(packageName)
                    PackageInstallerManager.result = result
                }
                else -> result.notImplemented()
            }
        }

        // ✅ Canal para parsear APKs (agregado correctamente)
        setupApkParserChannel(flutterEngine)
    }

    // ==================== CANAL PARA PARSEAR APKS ====================
    private fun setupApkParserChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, apkParserChannel).setMethodCallHandler { call, result ->
            if (call.method == "parseApk") {
                val apkPath = call.argument<String>("apkPath")
                if (apkPath != null) {
                    try {
                        val aaptBinary = Aapt.binary(applicationContext)
                        val process = ProcessBuilder(aaptBinary.absolutePath, "dump", "badging", apkPath)
                            .redirectErrorStream(true)
                            .start()
                        val output = process.inputStream.bufferedReader().readText()
                        val exitCode = process.waitFor()

                        if (exitCode == 0) {
                            result.success(parseAaptOutput(output))
                        } else {
                            result.error("AAPT_ERROR", "AAPT exited with code $exitCode", output)
                        }
                    } catch (e: Exception) {
                        result.error("EXECUTION_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "apkPath is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun parseAaptOutput(output: String): Map<String, String> {
        val result = mutableMapOf<String, String>()
        val lines = output.lineSequence()
        for (line in lines) {
            when {
                line.startsWith("package: name='") -> {
                    val packageName = line.substringAfter("name='").substringBefore("'")
                    result["packageName"] = packageName
                    val versionName = line.substringAfter("versionName='").substringBefore("'")
                    result["versionName"] = versionName
                }
                line.startsWith("application-label:") -> {
                    val appName = line.substringAfter(":'").substringBefore("'")
                    result["appName"] = appName
                }
            }
        }
        return result
    }
    // ================================================================

    private fun openBrowser(query: String?) {
        val intent = Intent(Intent.ACTION_WEB_SEARCH).apply {
            putExtra(SearchManager.QUERY, query)
        }
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        }
    }

    private fun runPatcher(
        result: MethodChannel.Result,
        inFilePath: String,
        outFilePath: String,
        selectedPatches: List<String>,
        options: Map<String, Map<String, Any>>,
        tmpDirPath: String,
        keyStoreFilePath: String,
        keystorePassword: String,
        ripArchitectureList: List<String>
    ) {
        val inFile = File(inFilePath)
        inFile.setWritable(true)
        inFile.setReadable(true)
        val outFile = File(outFilePath)
        val keyStoreFile = File(keyStoreFilePath)
        val tmpDir = File(tmpDirPath)

        Thread {
            fun updateProgress(progress: Double, header: String, log: String) {
                handler.post {
                    installerChannel.invokeMethod(
                        "update",
                        mapOf("progress" to progress, "header" to header, "log" to log)
                    )
                }
            }

            fun postStop() = handler.post { stopResult!!.success(null) }

            fun cancel(block: () -> Unit = {}): Boolean {
                if (cancel) {
                    block()
                    postStop()
                }
                return cancel
            }

            Logger.getLogger("").apply {
                handlers.forEach { handler ->
                    handler.close()
                    removeHandler(handler)
                }
                object : java.util.logging.Handler() {
                    override fun publish(record: LogRecord) {
                        if (cancel) return
                        if (record.loggerName?.startsWith("com.extenre") == true || record.loggerName == "") {
                            updateProgress(-1.0, "", record.message)
                        }
                    }
                    override fun flush() = Unit
                    override fun close() = flush()
                }.let(::addHandler)
            }

            try {
                updateProgress(0.0, "Reading APK...", "Reading APK")
                val patcher = Patcher(
                    PatcherConfig(
                        inFile,
                        tmpDir,
                        Aapt.binary(applicationContext).absolutePath,
                        tmpDir.path,
                    )
                )
                if (cancel(patcher::close)) return@Thread
                updateProgress(0.02, "Loading patches...", "Loading patches")

                val patches = patches.filter { patch ->
                    val isCompatible = patch.compatiblePackages?.any { (name, _) ->
                        name == patcher.context.packageMetadata.packageName
                    } ?: false
                    val compatibleOrUniversal = isCompatible || patch.compatiblePackages.isNullOrEmpty()
                    compatibleOrUniversal && selectedPatches.any { it == patch.name }
                }.onEach { patch ->
                    options[patch.name]?.forEach { (key, value) ->
                        patch.options[key] = value
                    }
                }.toSet()

                if (cancel(patcher::close)) return@Thread
                updateProgress(0.05, "Executing...", "")

                val patcherResult = patcher.use {
                    it += patches
                    runBlocking {
                        val totalPatchesCount = patches.size
                        val progressStep = 0.55 / totalPatchesCount
                        var progress = 0.05
                        patcher().collect(FlowCollector { patchResult: PatchResult ->
                            if (cancel(patcher::close)) return@FlowCollector
                            val msg = patchResult.exception?.let {
                                val writer = StringWriter()
                                it.printStackTrace(PrintWriter(writer))
                                "${patchResult.patch.name} failed: $writer"
                            } ?: "${patchResult.patch.name} succeeded"
                            updateProgress(progress, "", msg)
                            progress += progressStep
                        })
                    }
                    if (cancel(patcher::close)) return@Thread
                    updateProgress(0.75, "Building...", "")
                    patcher.get()
                }

                if (cancel(patcher::close)) return@Thread
                patcherResult.applyTo(inFile, ripArchitectureList.toTypedArray())
                if (cancel(patcher::close)) return@Thread

                ApkUtils.signApk(
                    inFile,
                    outFile,
                    "ExtenRe",
                    ApkUtils.KeyStoreDetails(keyStoreFile, keystorePassword, "alias", keystorePassword)
                )
                updateProgress(.85, "Patched", "Patched APK")
            } catch (ex: Throwable) {
                if (!cancel) {
                    updateProgress(-100.0, "Failed", "An error occurred:\n${ex.stackTraceToString()}")
                }
            } finally {
                inFile.delete()
                tmpDir.deleteRecursively()
            }
            handler.post { result.success(null) }
        }.start()
    }

    private fun installApk(apkPath: String) {
        val packageInstaller: PackageInstaller = applicationContext.packageManager.packageInstaller
        val sessionParams = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        val sessionId: Int = packageInstaller.createSession(sessionParams)
        val session: PackageInstaller.Session = packageInstaller.openSession(sessionId)
        session.use { activeSession ->
            val sessionOutputStream = activeSession.openWrite(applicationContext.packageName, 0, -1)
            sessionOutputStream.use { outputStream ->
                val apkFile = File(apkPath)
                apkFile.inputStream().use { inputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
        }
        val receiverIntent = Intent(applicationContext, InstallerReceiver::class.java).apply {
            action = "APP_INSTALL_ACTION"
        }
        val receiverPendingIntent = PendingIntent.getBroadcast(
            context, sessionId, receiverIntent, PackageInstallerManager.flags
        )
        session.commit(receiverPendingIntent.intentSender)
        session.close()
    }

    private fun uninstallApp(packageName: String) {
        val packageInstaller: PackageInstaller = applicationContext.packageManager.packageInstaller
        val receiverIntent = Intent(applicationContext, UninstallerReceiver::class.java).apply {
            action = "APP_UNINSTALL_ACTION"
        }
        val receiverPendingIntent = PendingIntent.getBroadcast(context, 0, receiverIntent, PackageInstallerManager.flags)
        packageInstaller.uninstall(packageName, receiverPendingIntent.intentSender)
    }

    object PackageInstallerManager {
        var result: MethodChannel.Result? = null
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }
}
