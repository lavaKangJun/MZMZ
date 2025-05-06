import Foundation

// DFS + 백트래킹
func solution(_ number: [Int]) {
    var isVisited = Array(repeating: false, count: number.count)
    var path = [Int]()
    dfs(isVisited: &isVisited, path: &path, number: number)
}

func dfs(isVisited: inout [Bool], path: inout [Int], number: [Int]) {
    if path.count == number.count {
        print(path)
        return
    }
    for index in 0..<number.count {
        if isVisited[index] == false {
            isVisited[index] = true
            path.append(number[index])
            dfs(isVisited: &isVisited, path: &path, number: number)
            
            isVisited[index] = false
            path.popLast()
        }
    }
}


print(solution([1, 2, 3]))
