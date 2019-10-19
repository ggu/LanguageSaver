//
//  LanguageSaverView.swift
//  LanguageSaver
//
//  Created by Gabriel Uribe on 8/12/18.
//  Copyright © 2018 Gabriel Uribe. All rights reserved.
//

import Cocoa
import ScreenSaver

class LanguageScreenSaverView: ScreenSaverView {
    @IBOutlet var configurePanel: NSPanel!
    @IBOutlet weak var popupButton: NSPopUpButton!

    var title: Label = Label(text: "", size: 80, frame: NSRect())
    var subtitle: Label = Label(text: "", size: 40, frame: NSRect())
    var allEntries: [DictionaryEntry] = []
//    var prevEntries: [DictionaryEntry] = []
//    var prevEntries: [DictionaryEntry] = []

    var currentIndex = 0

//    var remainingEntries: [DictionaryEntry] = []
    var timer = Timer()

    var defaults: UserDefaults?

    static let LevelKey = "level"

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        if let bundleIdentifier = Bundle(for: LanguageScreenSaverView.self).bundleIdentifier {
            defaults = ScreenSaverDefaults.init(forModuleWithName: bundleIdentifier )
        }

        allEntries = HSKDictionaryReader(fileName: getFileName()).getEntries()
        allEntries.shuffle()
        
        let titleFrame = NSRect(x: 0, y: bounds.height / 2 + 200, width: bounds.width, height: 100)
        title.frame = titleFrame
        title.makeBold()
        addSubview(title)

        let subtitleFrame = NSRect(x: 0, y: bounds.height / 2 - 50, width: bounds.width, height: 100)
        subtitle.frame = subtitleFrame
        addSubview(subtitle)

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.black.setFill()
        __NSRectFill(self.bounds)
        NSColor.white.set()
    }


    @objc func cycleRight() {
        currentIndex += 1

        if currentIndex == allEntries.count {
            currentIndex = 0
        }
        title.update(text: allEntries[currentIndex].word)
        subtitle.update(text: allEntries[currentIndex].definition)
    }

    @objc func cycleLeft() {
        currentIndex -= 1

        if currentIndex == 0 {
            currentIndex = allEntries.count - 1
        }
        title.update(text: allEntries[currentIndex].word)
        subtitle.update(text: allEntries[currentIndex].definition)
    }

    override func flagsChanged(with event: NSEvent) {
        cycleLeft()
        super.flagsChanged(with: event)
    }

    override func moveLeft(_ sender: Any?) {
        cycleLeft()
        super.moveLeft(sender)
    }

    override var canBecomeKeyView: Bool {
        get {
            return true
        }
    }

    override func lockFocus() {
        super.lockFocus()
        cycleLeft()

    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        cycleLeft()

        switch Int(event.keyCode) {
        case 123:
            cycleLeft()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        case 124:
            timer.fire()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        case NSLeftArrowFunctionKey:
            cycleLeft()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        case NSRightArrowFunctionKey:
            cycleRight()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        default:
            break
        }
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        cycleLeft()
        super.performKeyEquivalent(with: event)
        return true
    }


    override func keyUp(with event: NSEvent) {
        cycleLeft()
        super.keyUp(with: event)
        switch Int(event.keyCode) {
        case 123:
            cycleLeft()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        case 124:
            timer.fire()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        case NSLeftArrowFunctionKey:
            cycleLeft()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        case NSRightArrowFunctionKey:
            cycleRight()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleRight), userInfo: nil, repeats: true)
        default:
            break
        }
    }

    override var acceptsFirstResponder: Bool { get { return true } }

    @IBAction func cancelClicked(_ sender: NSButton) {
        window?.endSheet(configurePanel)
    }

    @IBAction func okClicked(_ sender: NSButton) {
        let level = popupButton.indexOfSelectedItem + 1
        setLanguage(level: level)
        window?.endSheet(configurePanel)
    }

    private func setLanguage(level: Int) {
        defaults?.set(level, forKey: LanguageScreenSaverView.LevelKey)
        defaults?.synchronize()
    }

    private func getLanguageLevel() -> Int {
        if let level = defaults?.object(forKey: LanguageScreenSaverView.LevelKey) as? Int {
            return level
        }
        return 1
    }

    private func getFileName() -> String {
        return "hsk\(getLanguageLevel())"
    }

    override var hasConfigureSheet: Bool {
        get {
            return true
        }
    }

    override var configureSheet: NSWindow? {
        get {
            Bundle(for: LanguageScreenSaverView.self).loadNibNamed(NSNib.Name("ConfigureSheet"), owner: self, topLevelObjects: nil)

            if let bundleIdentifier = Bundle(for: LanguageScreenSaverView.self).bundleIdentifier {
                defaults = ScreenSaverDefaults.init(forModuleWithName: bundleIdentifier )
            }

            let languageLevelIndex = getLanguageLevel() - 1
            popupButton.selectItem(at: languageLevelIndex)

            return configurePanel
        }
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Label: NSTextView {
    init(text: String, size: CGFloat, frame: NSRect) {
        super.init(frame: frame)

        alignment = NSTextAlignment.center
        font = NSFont.userFont(ofSize: size)
        isEditable = false

        backgroundColor = .black
        textColor = .white
        string = text
    }

    func makeBold() {
        if let fontSize = font?.pointSize {
            textStorage?.addAttribute(NSAttributedString.Key.font, value: NSFont.boldSystemFont(ofSize: fontSize), range: NSRange(location: 0, length: string.count))
        }
    }

    func update(text: String) {
        string = text
        needsDisplay = true
    }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DictionaryEntry {
    let word: String
    let definition: String
}

class HSKDictionaryReader {
    let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func getEntries() -> [DictionaryEntry] {
        let textFileContents = getTextFileContents()
        let lines = textFileContents.components(separatedBy: CharacterSet.newlines)
        var dictionaryEntries: [DictionaryEntry] = []

        for line in lines {
            if line != "" {
                let lineData = line.components(separatedBy: "\t")

                let character = lineData[0]
                let pinyin = lineData[3]
                let definition = lineData[4]

                let entry = DictionaryEntry(word: "\(character) \(pinyin)", definition: definition)
                dictionaryEntries.append(entry)
            }
        }

        return dictionaryEntries
    }

    private func getTextFileContents() -> String {
        do {
            if let path = Bundle(for: LanguageScreenSaverView.self).path(forResource: fileName, ofType: "txt") {
                return try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            }
        } catch {
            print(error)
            return ""
        }

        return ""
    }
}

// https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
