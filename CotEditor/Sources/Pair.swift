/*
 
 Pair.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-08-19.
 
 ------------------------------------------------------------------------------
 
 © 2016-2018 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

struct Pair<T> {
    
    var begin: T
    var end: T
    
    
    init(_ begin: T, _ end: T) {
        
        self.begin = begin
        self.end = end
    }
}


extension Pair where T: Hashable {
    
    static func == (lhs: Pair, rhs: Pair) -> Bool {
        
        return lhs.begin == rhs.begin && lhs.end == rhs.end
    }
    
    
    var hashValue: Int {
        
        return self.begin.hashValue + self.end.hashValue
    }
    
}



// MARK: BracePair

typealias BracePair = Pair<Character>

extension Pair where T == Character {
    
    static let braces: [BracePair] = [BracePair("(", ")"),
                                      BracePair("{", "}"),
                                      BracePair("[", "]")]
    static let ltgt = BracePair("<", ">")
    static let doubleQuotes = BracePair("\"", "\"")
    
    
    enum PairIndex {
        
        case begin(String.Index)
        case end(String.Index)
        case odd
    }
    
}



extension String {
    
    ///
    func indexOfBracePair(at index: Index, candidates: [BracePair], ignoringRanges: [Range<Index>] = []) -> BracePair.PairIndex? {
        
        let character = self[index]
        
        guard let pair = candidates.first(where: { $0.begin == character || $0.end == character }) else { return nil }
        
        switch character {
        case pair.begin:
            guard let endIndex = self.indexOfBracePair(beginIndex: index, pair: pair, ignoringRanges: ignoringRanges) else { return .odd }
            return .end(endIndex)
            
        case pair.end:
            guard let beginIndex = self.indexOfBracePair(endIndex: index, pair: pair, ignoringRanges: ignoringRanges) else { return .odd }
            return .begin(beginIndex)
            
        default: preconditionFailure()
        }
    }
    
    
    /// find character index of matched opening brace before a given index.
    func indexOfBracePair(endIndex: Index, pair: BracePair, ignoringRanges: [Range<Index>] = []) -> Index? {
        
        var nestDepth = 0
        let subsequence = self[..<endIndex]
        
        for (index, character) in zip(subsequence.indices, subsequence).reversed() {
            guard
                !self.isCharacterEscaped(at: index),
                !ignoringRanges.contains(where: { $0.contains(index) })
                else { continue }
            
            switch character {
            case pair.begin where nestDepth == 0:
                return index
            case pair.begin:
                nestDepth -= 1
            case pair.end:
                nestDepth += 1
            default: break
            }
        }
        
        return nil
    }
    
    
    /// find character index of matched closing brace after a given index.
    func indexOfBracePair(beginIndex: Index, pair: BracePair, ignoringRanges: [Range<Index>] = []) -> Index? {
        
        guard beginIndex != self.endIndex else { return nil }
        
        var nestDepth = 0
        let subsequence = self[self.index(after: beginIndex)...]
        
        for (index, character) in zip(subsequence.indices, subsequence) {
            guard
                !self.isCharacterEscaped(at: index),
                !ignoringRanges.contains(where: { $0.contains(index) })
                else { continue }
            
            switch character {
            case pair.end where nestDepth == 0:
                return index
            case pair.end:
                nestDepth -= 1
            case pair.begin:
                nestDepth += 1
            default: break
            }
        }
        
        return nil
    }
    
}
