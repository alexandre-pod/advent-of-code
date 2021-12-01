import Foundation

typealias Response = Set<String>
typealias GroupResponse = [Response]

func main() {
    var groupResponses: [GroupResponse] = []
    
    while let groupResponse = parseGroupResponse() {
        groupResponses.append(groupResponse)
    }
    
    partOne(groupResponses: groupResponses)
    partTwo(groupResponses: groupResponses)
}

func parseGroupResponse() -> GroupResponse? {
    var groupResponse = GroupResponse()
    
    while let line = readLine(), !line.isEmpty {
        groupResponse.append(parseResponse(from: line))
    }
    
    return groupResponse.isEmpty ? nil : groupResponse
}

func parseResponse(from line: String) -> Response {
    var response = Response()
    line.forEach {
        response.insert(String($0))
    }
    return response
}

// MARK: - Part 1

func partOne(groupResponses: [GroupResponse]) {
    let sumOfAllDifferentAnswers = groupResponses
        .map { $0.countDifferentAnswers() }
        .reduce(0, { $0 + $1 })
    print("sumOfAllDifferentAnswers: \(sumOfAllDifferentAnswers)")
}

extension GroupResponse {
    func countDifferentAnswers() -> Int {
        return mergeAllAnswersSet().count
    }
    
    func mergeAllAnswersSet() -> Set<String> {
        return reduce(Set<String>()) { (set, response) -> Set<String> in
            return set.union(response)
        }
    }
}

// MARK: - Part two

func partTwo(groupResponses: [GroupResponse]) {
    let sumOfAllCommonAnswers = groupResponses
        .map { $0.countSameAnswers() }
        .reduce(0, { $0 + $1 })
    print("sumOfAllCommonAnswers: \(sumOfAllCommonAnswers)")
}

extension GroupResponse {
    func countSameAnswers() -> Int {
        return mergeCommonAnswersSet().count
    }
    
    func mergeCommonAnswersSet() -> Set<String> {
        return reduce(first ?? Set<String>()) { (set, response) -> Set<String> in
            return set.intersection(response)
        }
    }
}

main()
