
typealias Day = Int
typealias Month = Int
typealias Year = Int
typealias Bonus = Int?
typealias WorkDaysStorage = [WorkDay]





enum AppReport {
    case addDays(AddDaysReport)
    case createMonth(CreateMonthReport)
    case removeDays(RemoveDaysReport)
    case addBonus(UpdateBonusReport)
    case salary(SalaryReport)
    
    var logText: String {
        switch self {
        case .addDays(let r) :
            return r.logText
        case .removeDays(let r) :
            return r.logText
        case .addBonus(let r):
            return r.logText
        case .salary(let r):
            return r.logText
        case .createMonth(let r) :
            return r.logText
        }
    }
}



enum AppError : Error {
    case emptyInput
    case nothingToRemove
    case emptyMonthForKey
    case mismatchBonusesAndDays
    case duplicateDetected
    case noDaysForRange
    case emptyMonth
    case wrongInput
    
    var logText : String {
        switch self {
        case .emptyInput:
            return "❌ Error: Empty input"
        case .nothingToRemove:
            return "❌ Error: Nothing to remove"
        case .emptyMonthForKey:
            return "❌ Error: Month not Found"
        case .duplicateDetected:
            return "❌ Error: Days dublicate detected"
        case .mismatchBonusesAndDays:
            return "❌ Error: Days count != Bonuses count"
        case .noDaysForRange:
            return "❌ No found days for this Range"
        case .emptyMonth:
            return "❌ Month is empty"
        case .wrongInput:
            return "❌ Wrong input"
        }
    }
}

enum UpdateMode {
    case override
    case onlyAdd
    
    var title : String {
        switch self {
        case .override: return "OverRide"
        case .onlyAdd: return "Only Add"
        }
    }
}



struct CreateMonthReport {
    let daysCount : Int
    let month : Int
    let year : Int
    
    var logText : String {
        var text = "✅ Created month \(month)/\(year) with \(daysCount) days"
        return text
    }
}

struct RemoveDaysReport {
    let removedCount: Int
    let operationStatus : OperationStatus
    
    var logText : String {
        var text = "✅ Remove \(removedCount) days"
        
        if operationStatus == .warning {
            text += "Warning. Nothing to remove"
        }
        return text
        }

    }



struct SalaryReport {
    let realSalary: Int
    let guardSalary: Int
    let predictableSalary: Int
    let plannedCount: Int
    let myBonuses: Int
    let myAvgBonuses: Int
    let avgBonuses: Int
    let noDataDays: [Int]
    let workedDays: [Int]
    let range: [Int]
    let operationStatus: OperationStatus
    let warning : SalaryWarning?
    
    var workedCount : Int {
        return workedDays.count
    }
    
    var noDataCount : Int {
        return noDataDays.count
    }
    
    var logText : String {
        var text = """
        ======== SALARY REPORT ========
        Дата: 
        Дни:   \(range)
        -------------------------------
        Кол-во смен:            \(plannedCount)
        Отработано:             \(workedCount)
        Не отработано:          \(noDataCount)
        -------------------------------
        Мои бонусы:             \(myBonuses)
        Средний бонус:          \(myAvgBonuses)
        Общий средний бонус:    \(avgBonuses)
        -------------------------------
        Зарплата сейчас:        \(realSalary)
        Прогноз зп:             \(predictableSalary)
        Гарантированная зп:     \(guardSalary)
        -------------------------------
        Отработанные дни:       \(workedDays)
        Не отработанные дни:    \(noDataDays)
        ================================
        """
        if operationStatus == .warning, let warning {
                   switch warning {
                   case .noBonusesForPeriod:
                       text += "\n⚠️ Нет бонусов за выбранный период"
                   case .bonusesNotForAllShifts:
                       text += "\n⚠️ Бонусы есть не для всех смен"
                   }
               }

        
    return text
    }
}

struct AddDaysReport {
    let requested: Int
    let addCount: Int
    let problems: [Int]
    let operationStatus: OperationStatus
    let myShifts : [Int]
    
    var logText: String {
        var text = "✅ AddDays | \nAdded: \(addCount)/\(requested)"
        if operationStatus == .warning {
            text += "\n⚠️ Duplicates ignored: \(problems.sorted())"
        }
    return text
    }
    
    init(_ requested: Int,_ addCount: Int,_ problems: [Int],_ operationStatus: OperationStatus,_ myShifts : [Int]) {
        self.requested = requested
        self.addCount = addCount
        self.problems = problems
        self.operationStatus = operationStatus
        self.myShifts = myShifts
    }
}



struct BonusResult {
    var day : Day
    var bonus : Bonus
    var overRidden : Bool
}


struct UpdateBonusReport {
    let mode : UpdateMode
    let logs : [BonusResult]
    let skippedDays : [Day]
    let operationStatus: OperationStatus
    
    var overridenValues : [Int] {
        return logs.filter { $0.overRidden }.map { $0.day }
    }
    
    
    var logText : String {
        var text = "=======✅ UpdateBonuses |  ======="
        text += "\nMode:\(mode.title)"
        
        
        text += "\nAdd \(logs.count)/\(logs.count + skippedDays.count) days"
        if mode == .override {
            text += "\nOverriden \(overridenValues.count)/\(logs.count)\n"
        }
        
        for value in logs {
            let safeBonus = value.bonus ?? 0
            let mark = value.overRidden ? "🔄" : "🆕"
            text += "\(value.day) : \(safeBonus)\(mark)\n"
            }
        if operationStatus == .warning {
            text += "\n⚠️ Skipped: \(skippedDays.sorted())"
        }
        text += "===============================\n"
        return text
    }
}


enum OperationStatus {
    case success
    case warning
}

enum SalaryWarning {
    case noBonusesForPeriod
    case bonusesNotForAllShifts
}


enum ShiftUpdateMode {
    case add
    case remove
    
    var isWorking : Bool {
        switch self {
        case .add:
        return true
        case .remove:
        return false
        }
    }
}

struct WorkDay {
    var day: Day
    var month: Month
    var year: Year
    var bonus: Bonus
    var isMyShift : Bool
    
    var sortKey : Int  {
        return year * 10000 + month * 100 + day
    }
}



struct SalaryCalculator {
    let rate = 1000
    
//    let realSalary: Int

    
    func calculate(_ days: [WorkDay],_ range: [Day]) -> SalaryReport {
        // group
        let plannedShifts = days.filter {$0.isMyShift}
        let workedShifts = plannedShifts.filter {$0.bonus != nil}
        
        let noDataShifts = plannedShifts.filter {$0.bonus == nil}
        
        let allDaysWithBonuses =  days.filter {$0.bonus != nil}
        
        // map
        let workedDays = workedShifts.map {$0.day}
        let noDataDays = noDataShifts.map {$0.day}
        
        // count
        let myBonuses = workedShifts.compactMap {$0.bonus} .reduce(0, +)
        let allBonuses = days.compactMap {$0.bonus} .reduce(0, +)
        
        var status : OperationStatus = .success
        var warning : SalaryWarning?
        
        if noDataDays.count > 0 {
            status = .warning
            warning = .bonusesNotForAllShifts
        }
        
        var myAvgBonuses = 0
        if workedShifts.count > 0 {
            myAvgBonuses = myBonuses / workedShifts.count
        } else {
            status = .warning
            warning = .noBonusesForPeriod
        }
        
        var avgBonuses = 0
        if allDaysWithBonuses.count > 0 {
            avgBonuses = allBonuses / allDaysWithBonuses.count
        } else {
            status = .warning
            warning = .noBonusesForPeriod
        }
        
        
        let guardSalary = (plannedShifts.count * rate) + myBonuses
        let realSalary = ((workedShifts.count) * rate) + myBonuses
        let predictableSalary = (realSalary) + (noDataDays.count * (myAvgBonuses + rate))
        
        
        
        let report = SalaryReport(realSalary: realSalary, guardSalary: guardSalary, predictableSalary: predictableSalary, plannedCount: plannedShifts.count, myBonuses: myBonuses, myAvgBonuses: myAvgBonuses, avgBonuses: avgBonuses, noDataDays: noDataDays, workedDays: workedDays, range: range, operationStatus: status, warning: warning)
        return report
    }
}

//TODO: добавить везде защиту валид дня
class SalaryManager {
    private var workDaysByMonth : WorkDaysStorage = []
    
    private var validYear = 2025...2035
    private func isValidDate (forYear year: Year, month: Month, days: [Day]? = nil) -> Bool {
        
        guard validYear.contains(year) else {
            return false
        }
        
        guard (1...12).contains(month) else {
            return false
        }
        
        if let tempDays = days {
            guard let maxDay = tempDays.max(), let minDay = tempDays.min() else {
                return false
            }
            
            guard maxDay <= maxDays(year,month) && minDay >= 1 else {
                return false
            }
        }
        
        return true
    }
    private func maxDays(_ year: Year,_ month: Month) -> Int {
        switch month {
        case 4, 6, 9, 11: return 30
        case 2:
            // Високосный год: делится на 4, но не на 100 (кроме тех, что на 400)
            let isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            return isLeap ? 29 : 28
        default: return 31
        }
    }
    
    func daysCount (forYear year: Year, month: Month) -> Int? {
        guard isValidDate(forYear: year, month: month) else {
            return nil
        }
        
        let filtered = workDaysByMonth.filter {$0.year == year && $0.month == month}
        return filtered.count
    }
    
    func createMonth (forYear year: Year, month: Month) -> Result<AppReport,AppError> {
        guard isValidDate(forYear: year, month: month) else {
            return .failure(.wrongInput)
        }
        let lastDay = maxDays(year, month)
        for day in 1...lastDay {
            
            let isDublicate = workDaysByMonth.contains {$0.day == day && $0.month == month && $0.year == year }
            
            if !isDublicate {
                workDaysByMonth.append(WorkDay(day: day, month: month, year: year, bonus: nil, isMyShift: false))
            }
        }
        
        workDaysByMonth.sort {$0.sortKey < $1.sortKey}
        return .success(.createMonth(.init(daysCount: lastDay, month: month, year: year)))
        
    }
    
    func shiftsGetDays (forYear year: Year, month: Month) -> [Day] {
        
        guard isValidDate(forYear: year, month: month) else {
            return []
        }
        
        let myShifts = workDaysByMonth.filter {$0.year == year && $0.month == month && $0.isMyShift == true}
        return myShifts.map {$0.day}
    }
    
    func shiftsUpdateDays (_ mode: ShiftUpdateMode, forYear year: Year, month: Month, setDays days: [Day]) -> Result<AppReport, AppError> {
        guard isValidDate(forYear: year, month: month, days: days) else {
            return .failure(.wrongInput)
        }
        
        guard !days.isEmpty else {
            return .failure(AppError.emptyInput)
        }
        
        guard workDaysByMonth.contains(where: {$0.year == year && $0.month == month}) else {
            return .failure(AppError.emptyMonth)
        }
        
        let requested = days.count
        var addCount = 0
        var problems : [Int] = []
        var operationStatus = OperationStatus.warning
        
        for day in days {
            
            if let index = workDaysByMonth.firstIndex(where: {$0.year == year && $0.month == month && $0.day == day}) {
                workDaysByMonth[index].isMyShift = mode.isWorking
                addCount += 1
            } else {
                problems.append(day)
            }
        }
        
        if problems.isEmpty {
            operationStatus = OperationStatus.success
        }
        
        let mySifts = shiftsGetDays(forYear: year, month: month)
        
        return .success(.addDays(AddDaysReport(requested, addCount, problems, operationStatus, mySifts)))
    }
    
    func removeMonth (forYear year: Year, month: Month) -> Result<AppReport, AppError> {
        
        guard isValidDate(forYear: year, month: month) else {
            return .failure(.wrongInput)
        }
        
        let tempCount = workDaysByMonth.count
        
        workDaysByMonth.removeAll {$0.month == month && $0.year == year}
        let removedCount = tempCount - workDaysByMonth.count
        
        let operationStatus : OperationStatus = removedCount > 0 ? .success : .warning
        
        return .success(.removeDays(.init(removedCount: removedCount, operationStatus: operationStatus)))

        
    }
    
    func bonusesUpdateFor (year: Year, month: Month, days: [Day], setBonuses bonuses: [Bonus], updateMode mode: UpdateMode) -> Result<AppReport,AppError> {
        
        
        let set = Set(days)
        
        guard isValidDate(forYear: year, month: month, days: days) else {
            return .failure(.wrongInput)
        }
        
        guard workDaysByMonth.firstIndex(where:  {$0.year == year && $0.month == month}) != nil else {
            return .failure(.emptyMonth)
        }
        
        guard days.count == bonuses.count else {
            return .failure(.mismatchBonusesAndDays)
        }
        
        guard set.count == days.count else {
            return .failure(.duplicateDetected)
        }
        
        var skippedDays : [Day] = []
        var logs : [BonusResult] = []
        
        
        
        for (day,bonus) in zip(days, bonuses) {
            
            if let index = workDaysByMonth.firstIndex(where: {$0.year == year && $0.month == month && $0.day == day}) {
                let hasValue = workDaysByMonth[index].bonus != nil
                
                switch mode {
                case .onlyAdd:
                    if !hasValue {
                        workDaysByMonth[index].bonus = bonus
                        logs.append(BonusResult(day: day, bonus: bonus, overRidden: false))
                    } else {
                        skippedDays.append(day)
                    }
                case .override:
                    workDaysByMonth[index].bonus = bonus
                    logs.append(BonusResult(day: day, bonus: bonus, overRidden: hasValue))
                }
                
            } else {
                skippedDays.append(day)
            }
        }
    
        let status : OperationStatus = skippedDays.isEmpty ? .success : .warning
        let report = UpdateBonusReport(mode: mode, logs: logs, skippedDays: skippedDays, operationStatus: status)
        return .success(.addBonus(report))
    }
    
    func getSalaryFor (year: Year, month: Month, days: [Day]? = nil ) -> Result<AppReport, AppError> {
        
        guard isValidDate(forYear: year, month: month, days: days) else {
            return .failure(.wrongInput)
        }
        
        let actualRange = days ?? Array(1...maxDays(year, month))
        let daysToCalculate = workDaysByMonth.filter {$0.year == year && $0.month == month && actualRange.contains($0.day)}
        
        let calculator = SalaryCalculator()
        let report = calculator.calculate(daysToCalculate, actualRange)
        
        return  .success(.salary(report))
    }
    
}


// helper
func printResult (_ result: Result<AppReport, AppError>) {
    switch result {
    case .success(let report):
        print(report.logText)
    case .failure(let error):
        print(error.logText)
    }
}

var app = SalaryManager()

app.createMonth(forYear: 2026, month: 01)
app.createMonth(forYear: 2026, month: 02)
app.createMonth(forYear: 2026, month: 03)
app.createMonth(forYear: 2026, month: 04)

app.shiftsUpdateDays(.add, forYear: 2026, month: 01, setDays: [4,5,6,9,10,11,14,15,19,20,21,24,25,26,29,30,31])
app.shiftsUpdateDays(.add, forYear: 2026, month: 02, setDays: [1,2,3,6,7,9,12,13,15])
app.shiftsUpdateDays(.add, forYear: 2026, month: 02, setDays: [16,17,20,21,22,25,26,27])
app.shiftsUpdateDays(.add, forYear: 2026, month: 03, setDays: [1,5,6,7,10,11,14,15])
app.shiftsUpdateDays(.add, forYear: 2026, month: 03, setDays: [16,17,20,21,22,23,26,27,28])

app.bonusesUpdateFor(year: 2026, month: 01, days: [2,3,4,5,6,7,8,9,10,11,12,13,14,15], setBonuses: [400,200,150,150,100,150,100,300,250,350,250,400,300,250], updateMode: .onlyAdd)

app.bonusesUpdateFor(year: 2026, month: 01, days: [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31], setBonuses: [500,1000,500,200,1400,350,900,1050,1000,350,200,100,150,0,550,400], updateMode: .onlyAdd)

app.bonusesUpdateFor(year: 2026, month: 02, days: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], setBonuses: [450,0,250,100,450,600,1200,600,0,150,250,200,250,950,450], updateMode: .onlyAdd)

app.bonusesUpdateFor(year: 2026, month: 02, days: [16,17,18,19,20,21,22,23,24,25,26,27,28], setBonuses: [0,0,400,0,250,1150,350,0,0,100,100,350,650], updateMode: .onlyAdd)

app.bonusesUpdateFor(year: 2026, month: 03, days: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], setBonuses: [850,0,0,200,350,350,450,1200,100,450,300,350,600,600,750], updateMode: .onlyAdd)

printResult(app.getSalaryFor(year: 2026, month: 03))

