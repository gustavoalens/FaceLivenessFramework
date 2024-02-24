import Foundation

extension Dictionary where Value == Array<Float> {
    mutating func add(onKey key: Key, value: Value.Element?) {
        guard let  value = value else { return }
        guard self[key] != nil else {
            self[key] = [value]
            return
        }
        self[key]?.append(value)
    }
}
