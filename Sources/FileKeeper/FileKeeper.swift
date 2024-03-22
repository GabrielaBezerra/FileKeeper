//
//  FileKeeper.swift
//
//
//  Created by Gabriela Bezerra on 13/03/24.
//

import Foundation

/// This file contains useful functions for data persistence in two formats: JSON and Plain text, in the context of a swift made CLI Tool.
/// # JSON
/// ```javascript
/// {
///     "text": "hello world",
///     "number": 2,
///     "array": ["element"],
/// }
/// ```
/// To represent the example JSON as Data, create a model (custom type) as follows:
/// ```swift
/// struct Model: Codable { // Replace Model with the name of your data type
///     // Replace each variable with the keys of your JSON and their respective value types
///     let text: String
///     let number: Int
///     let array: [String]
/// }
/// ```
/// # Plain Text
/// ```
/// Adventures of Huckleberry Finn
/// Alice's Adventures in Wonderland
/// Moby-Dick
/// Pride and Prejudice
/// War and Peace
/// ```
/// To represent data in plain text files such as the`books.txt` example above, use an array of strings `[String]`.
public struct FileKeeper {

    /// You should setup this property the first thing in your project. Variable that should be configured with the name of your project to create the default directory ~/.projectname/
    /// ## Example:
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// // the final value will be "myproject"
    /// ```
    /// If your project name has more than one word separated by a space character, with both uppercase and lowercase letters, it will always be formatted like this:
    /// ```swift
    /// FileKeeper.projectName = "My Project"
    /// // the final value will be "my-project"
    /// ```
    public static var projectName: String {
        get {
            _projectName
        }
        set {
            _projectName = newValue
                .replacingOccurrences(of: " ", with: "-")
                .lowercased()
        }
    }
    private static var _projectName: String = ""
    
    // MARK: JSON
    /// Persists data as JSON in the directory ~/.projectname/path
    /// - Parameters:
    ///   - model: Object to be persisted. This data must conform to the Encodable protocol.
    ///   - path: Path where the data will be persisted in a JSON file
    /// - Returns: Object that was persisted.
    /// ## Example
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// let content = Content()
    /// try FileKeeper.saveJson(content, file: "folder/content.json")
    /// // saved in ~/.myproject/folder/content.json
    /// ```
    @discardableResult
    public static func saveJson<T: Encodable>(_ model: T, file path: String) throws -> T {
        let url = try buildURL(appending: path)
        let data = try JSONEncoder().encode(model)
        try data.write(to: url)
        return model
    }
    
    /// Reads data from a JSON in the directory ~/.projectname/path
    /// - Parameters:
    ///   - path: Path where the data is persisted in a JSON file
    /// - Returns: Object contained in the JSON file.
    /// ## Example
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// let content = try FileKeeper.readJson(file: "folder/content.json")
    /// // reads data from ~/.myproject/folder/content.json
    /// ```
    public static func readJson<T: Decodable>(file path: String) throws -> T {
        let url = try buildURL(appending: path)
        let data = try Data(contentsOf: url)
        let model = try JSONDecoder().decode(T.self, from: data)
        return model
    }
    
    // MARK: Plain Text
    /// Saves data in a plain text file in the directory ~/.projectname/path
    /// - Parameters:
    ///   - content: Array of textual data to be saved in the plain text file.
    ///   - path: Path where the data will be persisted in a plain text file
    ///   - separator: Character that defines a boundary between one data and another.
    /// ## Example 1
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// let array: [String] = ["data1", "data2", "data3"]
    /// try FileKeeper.savePlainText(content: array, path: "folder/content.txt")
    /// // saves data (one per line) in the file at ~/.myproject/folder/content.txt
    /// ```
    /// ## Example 2
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// let array: [String] = ["data1", "data2", "data3"]
    /// try FileKeeper.savePlainText(content: array, path: "folder/content.txt", separator: ",")
    /// // saves data (separated by commas) in the file at ~/.myproject/folder/content.txt
    /// ```
    public static func savePlainText(content: [String], path: String, separator: String = "\n") throws {
        let url = try buildURL(appending: path)
        if let data = content
            .joined(separator: separator)
            .data(using: .utf8) {
            try data.write(to: url)
        }
    }

    /// Reads data from a plain text file in the directory ~/.projectname/path
    /// - Parameters:
    ///   - path: Path where the data is persisted in a plain text file
    ///   - separator: Character that defines a boundary between one data and another.
    /// - Returns: An array of String with the data contained in the plain text file.
    /// ## Example
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// let content: [String] = try FileKeeper.readPlainText(path: "folder/content.txt")
    /// // reads data from ~/.myproject/folder/content.txt
    /// ```
    public static func readPlainText(path: String, separator: String = "\n") throws -> [String] {
        let url = try buildURL(appending: path)
        let data = try Data(contentsOf: url)
        let string = String(bytes: data, encoding: .utf8)
        var components = string?.components(separatedBy: separator) ?? []
        if components.last?.isEmpty ?? false { components.removeLast() }
        return components
    }
    
    // MARK: Utils
    /// Returns a list of strings representing the contents of a directory (folder)
    /// - Parameter path: Path to the folder to be read
    /// - Returns: List of names of the contents of that folder
    /// ## Example
    /// ```swift
    /// FileKeeper.projectName = "myproject"
    /// let content: [String] = try FileKeeper.listContents(in: "folder")
    /// // reads files in ~/.myproject/folder and prints:
    /// // ~/.myproject/folder
    /// // contents.json
    /// // contents.txt
    /// ```
    public static func listContents(in path: String) throws -> [String] {
        let url = try buildURL(appending: path)
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [])
        return contents.map { $0.lastPathComponent }
    }
    
    private static func buildURL(appending path: String) throws -> URL {
        assert(!_projectName.isEmpty, "FileKeeper.projectName is empty. Did you remember to setup it somewhere?")
        let home = FileManager.default.homeDirectoryForCurrentUser
        let projectFolder = home.appending(path: ".\(_projectName)")
        if !FileManager.default.fileExists(atPath: projectFolder.relativePath) {
            try FileManager.default.createDirectory(at: projectFolder, withIntermediateDirectories: true)
        }
        var components = path.components(separatedBy: "/")
        components.removeLast() // removing file from path components
        try components.indices.forEach { index in
            var folderURL = projectFolder.appending(path: components[0])
            if index != 0 {
                folderURL.append(path: Array(1...index).map { "/\(components[$0])" }.joined())
            }
            if !FileManager.default.fileExists(atPath: folderURL.relativePath) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
            }
        }
        return projectFolder.appending(path: path)
    }
    
}
