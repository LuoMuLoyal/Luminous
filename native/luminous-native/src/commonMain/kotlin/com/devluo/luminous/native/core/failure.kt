package com.devluo.luminous.native.core

enum class FailureCode {
    permissionDenied,
    notSupported,
    unavailable,
    invalidRequest,
    queryFailed,
    unknown,
}

data class Failure(
    val code: FailureCode,
    val message: String? = null,
)
