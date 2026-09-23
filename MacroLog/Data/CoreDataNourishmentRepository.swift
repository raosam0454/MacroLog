//
//  CoreDataNourishmentRepository.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import CoreData

/// The Core Data-backed repository. This struct is the only place in the whole
/// app that knows Core Data exists. It translates between the managed objects
/// on disk and the clean domain values everything else works with.
struct CoreDataNourishmentRepository: NourishmentRepository {

    let context: NSManagedObjectContext

    func day(on date: Date) throws -> NourishmentDay {
        let start = Calendar.current.startOfDay(for: date)
        if let entity = try fetchDayEntity(on: start) {
            return entity.toDomain()
        }
        // Nothing logged for this date yet: an empty day with the default target.
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

    // MARK: - Helpers

    /// The predicate query for this domain: "the day record whose
    /// date is exactly this calendar day". Because every day is stored at its
    /// start-of-day, an exact match finds today's record and nothing else.
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
}
