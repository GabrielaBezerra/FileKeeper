# FileKeeper

FileKeeper is your easy-to-use solution for persisting your files when building CLI tools with Swift. With FileKeeper, you can store and access data as needed in both JSON format or Plain Text. FileKeeper is built on top of the FileManager API, making it easy to use and understand.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/GabrielaBezerra/FileKeeper.git", branch: "main")
]
```

## Usage

### Initial setup

```swift
FileKeeper.projectName = "YourProjectName"
```

### Save a JSON file

```swift
let encodableModel = Model()
try FileKeeper.saveJson(encodableModel, at: "yourfolder/yourfilename.json")
// saved in `~/.yourprojectname/yourfolder/yourfilename.json`
```

### Read a JSON file

```swift
let encodableModel = try FileKeeper.readJson(at: "yourfolder/yourfilename.json")
// read from `~/.yourprojectname/yourfolder/yourfilename.json`
```

### Save a Plain Text file

```swift
let array = ["Adventures of Huckleberry Finn", "Alice's Adventures in Wonderland", "Moby-Dick"]
try FileKeeper.savePlainText(content: array, at: "yourfolder/yourfilename.txt")
// saved in `~/.yourprojectname/yourfolder/yourfilename.txt`
```

### Read a Plain Text file

```swift
try FileKeeper.readPlainText(at: "yourfolder/yourfilename.txt")
// read from `~/.yourprojectname/yourfolder/yourfilename.txt`
```
