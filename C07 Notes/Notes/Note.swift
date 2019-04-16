//
//  Note.swift
//  Notes
//
//  Created by Rob Baldwin on 15/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation

// Using a class rather than a struct as 'selectedNote' in DetailVC is passed around as a reference type

class Note: Codable {
    
    var id: String
    var text: String
    var date: Date
    
    init(id: String, text: String, date: Date) {
        self.id = id
        self.text = text
        self.date = date
    }
    
    func title() -> String {
    
        // In Notes, "New Note" is displayed where there is no text
        guard !text.isEmpty else {
            return "New Note"
        }
        
        // In Notes, the first 45(ish) characters are displayed as the title in the cell and truncated.
        var length: Int

        // If the length of the text is <= 45 characters, get the actual length for the title, or use 45 as a maximum length
        if text.count <= 45 {
            length = text.count
        } else {
            length = 45
        }
        
        // If there are any line breaks in the title, return only the text up to the first line break
        let firstCharacters = text.prefix(length)
        if firstCharacters.contains("\n") {
            let lines = firstCharacters.components(separatedBy: "\n")
            return lines[0]
        } else {
            return String(firstCharacters)
        }
    }
    
    func subTitle() -> String {
        
        // If there is a line break in the first 45 characters, uses the second line as the subTitle
        // If there is no line break, "No additional text" is displayed, as in the Notes App
        if text.count <= 45 {
            if text.contains("\n") {
                let lines = text.components(separatedBy: "\n")
                return lines[1]
            } else {
                return "No additional text"
            }
        } else {
            // If text is over 45 characters, start the subTitle after the first space beyond 45 characters, so as not to split words
            let startIndex = text.index(text.startIndex, offsetBy: 45)
            let bodyText = String(text[startIndex...])
            
            if let indexOfFirstSpace = bodyText.firstIndex(of: " ") {
                let indexAfterFirstSpace = bodyText.index(after: indexOfFirstSpace)
                return String(bodyText[indexAfterFirstSpace...])
            } else {
                return bodyText
            }
        }
    }
    
    func dateString() -> String {

        // Notes App, displays:
        // - todays notes as the time only HH:mm
        // - yesterdays notes as 'Yesterday'
        // - anything older as dd/MM/YYYY
        
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "dd/MM/YYYY"
            return dateFormatter.string(from: date)
        }
    }

    // Sample data to populate app on first launch, with notes at different times to show all dateString combinations
    static func sampleData() -> [Note] {
        var notes: [Note] = []
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        
        notes.append(Note(id: UUID().uuidString, text: "Would you like me to give you a formula for success? It’s quite simple, really: Double your rate of failure. You are thinking of failure as the enemy of success. But it isn’t at all. You can be discouraged by failure or you can learn from it, so go ahead and make mistakes. Make all you can. Because remember that’s where you will find success.", date: Date()))
        notes.append(Note(id: UUID().uuidString, text: "Challenges are what make life interesting and overcoming them is what makes life meaningful", date: yesterday))
        notes.append(Note(id: UUID().uuidString, text: "The three great essentials to achieve anything worthwhile are, first, hard work; second, stick-to-itiveness; third, common sense.", date: twoDaysAgo))
        notes.append(Note(id: UUID().uuidString, text: "Watch your thoughts; they become words.\nWatch your words; they become actions.\nWatch your actions; they become habits.\nWatch your habits; they become character.\nWatch your character; it becomes your destiny.", date: lastWeek))
        return notes
    }
}
