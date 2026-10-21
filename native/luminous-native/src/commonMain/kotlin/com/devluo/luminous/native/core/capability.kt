package com.devluo.luminous.native.core

enum class UnavailableReason {
    noStepSensor,
    permissionDenied,
    healthDataUnavailable,
    notSupported,
    unknown,
}

sealed class Capability {
    data object Available : Capability()

    data class Unavailable(
        val reason: UnavailableReason,
        val message: String? = null,
    ) : Capability()

    companion object {
        fun unavailable(
            reason: UnavailableReason,
            message: String? = null,
        ): Capability = Unavailable(reason, message)
    }
}

fun UnavailableReason.toFailureCode(): FailureCode = when (this) {
    UnavailableReason.noStepSensor -> FailureCode.notSupported
    UnavailableReason.permissionDenied -> FailureCode.permissionDenied
    UnavailableReason.healthDataUnavailable -> FailureCode.unavailable
    UnavailableReason.notSupported -> FailureCode.notSupported
    UnavailableReason.unknown -> FailureCode.unknown
}
