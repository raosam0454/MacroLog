//
//  CoreDataNourishmentRepository.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import CoreData

/// The Core Data-backed repository. This struct is the ONLY place in the whole
/// app that knows Core Data exists. It translates between the managed objects
/// on disk and the clean domain values everything else works with.
struct CoreDataNourishmentRepository: NourishmentRepository {

    let context: NSManagedObjectContext

    // MARK: - Meals and the day

    func day(on date: Date) throws -> NourishmentDay {
        let start = Calendar.current.startOfDay(for: date)
        if let entity = try fetchDayEntity(on: start) {
            return entity.toDomain()
        }
        return NourishmentDay(date: start)
    }

    func record(_ meal: Meal) throws {
        let start = Calendar.current.startOfDay(for: meal.eatenAt)
        let day = try fetchDayEntity(on: start) ?? makeDayEntity(on: start)

        let mealEntity = MealEntity(context: context)
        mealEntity.apply(meal)
        mealEntity.day = day

        try context.save()
    }

    func removeMeal(id: UUID) throws {
        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        if let match = try context.fetch(request).first {
            context.delete(match)
            try context.save()
        }
    }

    func setTarget(_ target: DailyNourishmentTarget, on date: Date) throws {
        let start = Calendar.current.startOfDay(for: date)
        let day = try fetchDayEntity(on: start) ?? makeDayEntity(on: start)
        day.maximumGlycaemicLoad = target.maximumGlycaemicLoad
        try context.save()
    }

    func recentDays(endingOn date: Date, count: Int) throws -> [NourishmentDay] {
        let start = Calendar.current.startOfDay(for: date)
        let request = NSFetchRequest<NourishmentDayEntity>(entityName: "NourishmentDayEntity")
        request.predicate = NSPredicate(format: "date <= %@", start as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = count
        return try context.fetch(request).map { $0.toDomain() }
    }

    // MARK: - Symptoms

    func record(_ symptom: SymptomObservation) throws {
        let entity = SymptomEntity(context: context)
        entity.apply(symptom)
        try context.save()
    }

    func symptoms(on date: Date) throws -> [SymptomObservation] {
        let request = NSFetchRequest<SymptomEntity>(entityName: "SymptomEntity")
        request.predicate = predicate(forDayContaining: date, dateKey: "observedAt")
        request.sortDescriptors = [NSSortDescriptor(key: "observedAt", ascending: false)]
        return try context.fetch(request).map { $0.toDomain() }
    }

    // MARK: - Cycle

    func record(_ marker: CycleMarker) throws {
        let entity = CycleMarkerEntity(context: context)
        entity.apply(marker)
        try context.save()
    }

    func cycleMarkers(on date: Date) throws -> [CycleMarker] {
        let request = NSFetchRequest<CycleMarkerEntity>(entityName: "CycleMarkerEntity")
        request.predicate = predicate(forDayContaining: date, dateKey: "markedOn")
        return try context.fetch(request).map { $0.toDomain() }
    }

    func recentCycleMarkers(limit: Int) throws -> [CycleMarker] {
        let request = NSFetchRequest<CycleMarkerEntity>(entityName: "CycleMarkerEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "markedOn", ascending: false)]
        request.fetchLimit = limit
        return try context.fetch(request).map { $0.toDomain() }
    }

    // MARK: - Helpers

    /// "The day record whose date is exactly this calendar day." Because every
    /// day is stored at its start-of-day, an exact match finds today and nothing
    /// else.
    private func fetchDayEntity(on start: Date) throws -> NourishmentDayEntity? {
        let request = NSFetchRequest<NourishmentDayEntity>(entityName: "NourishmentDayEntity")
        request.predicate = NSPredicate(format: "date == %@", start as NSDate)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func makeDayEntity(on start: Date) -> NourishmentDayEntity {
        let day = NourishmentDayEntity(context: context)
        day.date = start
        day.maximumGlycaemicLoad = DailyNourishmentTarget.gentleDefault.maximumGlycaemicLoad
        return day
    }

    /// "Everything stamped within this one calendar day": start-of-day inclusive
    /// to the next start-of-day exclusive.
    private func predicate(forDayContaining date: Date, dateKey: String) -> NSPredicate {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        return NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, start as NSDate, dateKey, end as NSDate)
    }
}
