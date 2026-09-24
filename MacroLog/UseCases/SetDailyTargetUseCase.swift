//
//  SetDailyTargetUseCase.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import Foundation

/// Sets the daily low-GI ceiling the user is aiming to stay under.
///
/// The target is personal: a dietitian may give them a number, or they may set a personal goal.
/// This use case keeps that number inside a sensible range, so a
/// slip of the finger cannot leave her with a target of zero (nothing to eat)
/// or a target so high it stops meaning anything.
struct SetDailyTargetUseCase {

    let repository: NourishmentRepository

    /// Below this, a daily target leaves almost no room to eat.
    static let gentlestSafeTarget: Double = 20

    /// Above this, a daily target is so loose it no longer guides eating.
    static let highestSensibleTarget: Double = 500

    func execute(_ target: DailyNourishmentTarget, on date: Date) throws {
        guard target.maximumGlycaemicLoad >= SetDailyTargetUseCase.gentlestSafeTarget else {
            throw SetTargetError.targetTooLow(minimum: SetDailyTargetUseCase.gentlestSafeTarget)
        }
        guard target.maximumGlycaemicLoad <= SetDailyTargetUseCase.highestSensibleTarget else {
            throw SetTargetError.targetTooHigh(maximum: SetDailyTargetUseCase.highestSensibleTarget)
        }
        try repository.setTarget(target, on: date)
    }
}

/// when setting a daily target, the language the user can act
/// on rather than a validation code is important
enum SetTargetError: LocalizedError, Equatable {
    case targetTooLow(minimum: Double)
    case targetTooHigh(maximum: Double)

    var errorDescription: String? {
        switch self {
        case .targetTooLow(let minimum):
            return "A daily target under \(Int(minimum)) would leave you almost nothing to eat."
        case .targetTooHigh(let maximum):
            return "A daily target over \(Int(maximum)) is high enough that it wouldn't really guide your day."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .targetTooLow:
            return "Set a slightly higher number, or use the suggested starting target."
        case .targetTooHigh:
            return "Try a number closer to the plan your clinician suggested."
        }
    }
}
