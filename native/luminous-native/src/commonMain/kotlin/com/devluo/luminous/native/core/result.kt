package com.devluo.luminous.native.core

sealed class NativeResult<out T> {
    data class Success<T>(val value: T) : NativeResult<T>()
    data class Error(val failure: Failure) : NativeResult<Nothing>()
}
