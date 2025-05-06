import Foundation

func solution(_ word:String) -> Int {
    var array = ["A", "E", "I", "O", "U"]
    var total = [String]()
    
    func dfs(compose: String) {
        if compose.count > 5 {
            return
        }
        
        total.append(compose)
        
        for char in array {
            dfs(compose: compose + char)
        }
    }
    
    dfs(compose: "")

    return (total.firstIndex(where: { $0 == word }) ?? 0)
}

print(solution("AA"))
