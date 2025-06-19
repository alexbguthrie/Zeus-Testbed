//
//  SearchFilters.swift
//  Zeus-Testbed
//
//  Data models for representing advanced search and filtering criteria.
//

import Foundation

// Represents the active search filters.
// This struct is designed to be easily extensible with new filter types.
struct SearchFilters: Equatable {
    var fileTypes: Set<FileType> = []
    var tags: Set<String> = []
    var dateRange: DateFilterRange? = nil
    
    // Computed property to quickly check if any filters are active.
    var isActive: Bool {
        !fileTypes.isEmpty || !tags.isEmpty || dateRange != nil
    }
}

// Defines predefined date ranges for filtering.
enum DateFilterRange: String, CaseIterable, Identifiable {
    case pastDay = "Past 24 Hours"
    case pastWeek = "Past Week"
    case pastMonth = "Past Month"
    case pastYear = "Past Year"
    
    var id: String { self.rawValue }
    
    // Calculates the start date for the given range.
    func startDate() -> Date {
        let calendar = Calendar.current
        switch self {
        case .pastDay:
            return calendar.date(byAdding: .day, value: -1, to: .now) ?? .now
        case .pastWeek:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: .now) ?? .now
        case .pastMonth:
            return calendar.date(byAdding: .month, value: -1, to: .now) ?? .now
        case .pastYear:
            return calendar.date(byAdding: .year, value: -1, to: .now) ?? .now
        }
    }
} 