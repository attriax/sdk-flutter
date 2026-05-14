package com.attriax.attriax_example

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.verify.domain.DomainVerificationManager
import android.content.pm.verify.domain.DomainVerificationUserState
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	companion object {
		private const val channelName = "attriax_example/platform"
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler(::handleMethodCall)
	}

	private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"getAppLinkStatus" -> {
				val host = call.argument<String>("host") ?: ""
				result.success(getAppLinkStatus(host))
			}

			"openAppLinkSettings" -> {
				result.success(openAppLinkSettings())
			}

			"triggerNativeCrash" -> {
				result.success(true)
				window.decorView.post {
					throw RuntimeException("Attriax example native crash test")
				}
			}

			else -> result.notImplemented()
		}
	}

	private fun getAppLinkStatus(host: String): Map<String, Any?> {
		if (host.isBlank()) {
			return mapOf(
				"host" to host,
				"state" to "error",
				"details" to "No host was provided.",
				"linkHandlingAllowed" to false,
				"canOpenSettings" to false,
			)
		}

		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
			return mapOf(
				"host" to host,
				"state" to "unavailable",
				"details" to "Android 12 or newer is required to query domain verification state from the app.",
				"linkHandlingAllowed" to false,
				"canOpenSettings" to true,
			)
		}

		return try {
			val manager = getSystemService(DomainVerificationManager::class.java)
			if (manager == null) {
				return mapOf(
					"host" to host,
					"state" to "unavailable",
					"details" to "DomainVerificationManager is unavailable on this device.",
					"linkHandlingAllowed" to false,
					"canOpenSettings" to true,
				)
			}

			val userState = manager.getDomainVerificationUserState(packageName)
			if (userState == null) {
				return mapOf(
					"host" to host,
					"state" to "none",
					"details" to "The app does not report any HTTP(S) hosts to Android for verification.",
					"linkHandlingAllowed" to false,
					"canOpenSettings" to true,
				)
			}

			val state = userState.hostToStateMap[host] ?: DomainVerificationUserState.DOMAIN_STATE_NONE

			mapOf(
				"host" to host,
				"state" to mapDomainState(state),
				"details" to describeDomainState(state, userState.isLinkHandlingAllowed),
				"linkHandlingAllowed" to userState.isLinkHandlingAllowed,
				"canOpenSettings" to true,
			)
		} catch (_: PackageManager.NameNotFoundException) {
			mapOf(
				"host" to host,
				"state" to "error",
				"details" to "The current package name could not be resolved for domain verification.",
				"linkHandlingAllowed" to false,
				"canOpenSettings" to true,
			)
		} catch (error: Throwable) {
			mapOf(
				"host" to host,
				"state" to "error",
				"details" to (error.message ?: error::class.java.simpleName),
				"linkHandlingAllowed" to false,
				"canOpenSettings" to true,
			)
		}
	}

	private fun openAppLinkSettings(): Boolean {
		return try {
			val intent = Intent(Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS).apply {
				data = Uri.parse("package:$packageName")
				addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
			}
			startActivity(intent)
			true
		} catch (_: Throwable) {
			val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
				data = Uri.parse("package:$packageName")
				addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
			}
			startActivity(fallbackIntent)
			true
		}
	}

	private fun mapDomainState(state: Int): String {
		return when (state) {
			DomainVerificationUserState.DOMAIN_STATE_VERIFIED -> "verified"
			DomainVerificationUserState.DOMAIN_STATE_SELECTED -> "selected"
			DomainVerificationUserState.DOMAIN_STATE_NONE -> "none"
			else -> "unknown"
		}
	}

	private fun describeDomainState(state: Int, linkHandlingAllowed: Boolean): String {
		val toggleText = if (linkHandlingAllowed) {
			"Android currently allows this app to open verified links."
		} else {
			"Android currently blocks this app from opening verified links until the user enables it in settings."
		}

		return when (state) {
			DomainVerificationUserState.DOMAIN_STATE_VERIFIED -> "$toggleText The host is verified for this app."
			DomainVerificationUserState.DOMAIN_STATE_SELECTED -> "$toggleText The user selected this host manually, but Android did not verify it automatically."
			DomainVerificationUserState.DOMAIN_STATE_NONE -> "$toggleText The host is not verified for this app yet."
			else -> "$toggleText Android returned an unknown verification state code: $state."
		}
	}
}
