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
    var title: Label = Label(text: "", size: 80, frame: NSRect())
    var subtitle: Label = Label(text: "", size: 40, frame: NSRect())
    var allEntries = HSKDictionaryReader(fileName: "hsk2").getEntries()
    var remainingEntries: [DictionaryEntry] = []
    var timer = Timer()

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        if !isPreview {
            remainingEntries = allEntries

            let titleFrame = NSRect(x: 0, y: bounds.height / 2 + 200, width: bounds.width, height: 100)
            title.frame = titleFrame
            title.makeBold()
            addSubview(title)

            let subtitleFrame = NSRect(x: 0, y: bounds.height / 2 - 50, width: bounds.width, height: 100)
            subtitle.frame = subtitleFrame
            addSubview(subtitle)

            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(cycleWords), userInfo: nil, repeats: true)
            timer.fire()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.black.setFill()
        __NSRectFill(self.bounds)
        NSColor.white.set()
    }


    @objc func cycleWords() {
        if remainingEntries.count == 0 {
            remainingEntries = allEntries
        }

        let index = Int(SSRandomIntBetween(0, Int32(remainingEntries.count)))

        title.update(text: remainingEntries[index].word)
        subtitle.update(text: remainingEntries[index].definition)

        remainingEntries.remove(at: index)
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
            textStorage?.addAttribute(NSAttributedStringKey.font, value: NSFont.boldSystemFont(ofSize: fontSize), range: NSRange(location: 0, length: string.count))
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
            if let path = Bundle(for: LanguageScreenSaverView.self).path(forResource: "hsk2", ofType: "txt") {
                return try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            }
        } catch {
            print(error)
            return ""
        }

        return ""
    }
}



