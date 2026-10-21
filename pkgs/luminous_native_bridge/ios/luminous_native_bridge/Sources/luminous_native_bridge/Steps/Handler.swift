import Foundation
import LuminousNative

final class StepHandler: NSObject, StepHostApi {
  private let source = LuminousStepSource()

  func capability() async throws -> StepCapability {
    let status = source.status()
    return StepCapability(
      available: status.available,
      reason: status.reason,
      message: status.message
    )
  }

  func read(request: StepReadRequest) async throws -> [NativeStep] {
    let outcome = try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<LuminousStepReadOutcome, Error>) in
      source.readOutcome(
        request: StepRequest(startMs: request.startMs, endMs: request.endMs)
      ) { outcome, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }
        guard let outcome else {
          continuation.resume(
            throwing: PigeonError(
              code: "empty_response",
              message: "Native step source returned no payload.",
              details: nil
            )
          )
          return
        }
        continuation.resume(returning: outcome)
      }
    }

    if let errorCode = outcome.errorCode {
      throw PigeonError(
        code: errorCode,
        message: outcome.errorMessage,
        details: nil
      )
    }

    return outcome.samples.map {
      NativeStep(
        count: $0.count,
        startMs: $0.startMs,
        endMs: $0.endMs,
        source: $0.source
      )
    }
  }
}
