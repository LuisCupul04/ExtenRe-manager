/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

package com.extenre.manager.flutter.utils

import android.content.Context
import java.io.File

object Aapt {
    fun binary(context: Context): File {
        return File(context.applicationInfo.nativeLibraryDir).resolveAapt()
    }
}

private fun File.resolveAapt() = resolve(list { _, f -> !File(f).isDirectory && f.contains("aapt") }!!.first())