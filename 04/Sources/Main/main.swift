import Foundation

typealias Passeport = [String: String]

func main() {
    var passeports: [Passeport] = []
    
    while let passeport = readNextPasseport() {
        passeports.append(passeport)
    }
    
    part1(passeports: passeports)
    part2(passeports: passeports)
}

func readNextPasseport() -> Passeport? {
    var passeport = Passeport()
    while let line = readLine(), !line.isEmpty {
        let fields = line.split(separator: " ")
        fields.forEach { field in
            let fieldParts = field.split(separator: ":")
            passeport[String(fieldParts[0])] = String(fieldParts[1])
        }
    }
    return passeport.isEmpty ? nil : passeport
}

func part1(passeports: [Passeport]) {
    let requiredFields = [
        "byr",
        "iyr",
        "eyr",
        "hgt",
        "hcl",
        "ecl",
        "pid"
//        , "cid"
    ]
    let validPasseportsCount = passeports
        .filter { isValid($0, requiredFields: requiredFields) }
        .count
    print("#1 validPasseportsCount: \(validPasseportsCount)")
}

func isValid(_ passeport: Passeport, requiredFields: [String]) -> Bool {
    for field in requiredFields {
        if !passeport.keys.contains(field) {
            return false
        }
    }
    return true
}

typealias Validator = (String) -> Bool

func part2(passeports: [Passeport]) {
    let validECL = Set<String>(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])
    let requiredFields: [(String, Validator)] = [
        ("byr", { value -> Bool in
            guard let number = Int(value) else { return false }
            return 1920 <= number && number <= 2002
        }),
        ("iyr", { value -> Bool in
            guard let number = Int(value) else { return false }
            return 2010 <= number && number <= 2020
        }),
        ("eyr", { value -> Bool in
            guard let number = Int(value) else { return false }
            return 2020 <= number && number <= 2030
        }),
        ("hgt", { value -> Bool in
            guard
                value.count > 2,
                let number = Int(value.prefix(value.count - 2))
            else { return false }
            switch value.suffix(2) {
            case "cm":
                return 150 <= number && number <= 193
            case "in":
                return 59 <= number && number <= 76
            default:
                return false
            }
        }),
        ("hcl", { value -> Bool in
            return value.range(of: #"^#[0-9a-f]{6}$"#, options: .regularExpression) != nil
        }),
        ("ecl", { validECL.contains($0) }),
        ("pid", { value -> Bool in
            return value.range(of: #"^[0-9]{9}$"#, options: .regularExpression) != nil
        })
//        , "cid"
    ]
    let validPasseportsCount = passeports
        .filter { isValid($0, requiredFields: requiredFields) }
        .count
    print("#2 validPasseportsCount: \(validPasseportsCount)")
}

func isValid(_ passeport: Passeport, requiredFields: [(String, Validator)]) -> Bool {
    for (fieldKey, validator) in requiredFields {
        guard let value = passeport[fieldKey] else { return false }
        if !validator(value) {
            return false
        }
    }
    return true
}




main()
