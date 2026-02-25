typealias MonthKey = String
typealias WorkDay = (day: Int, month: Int, year: Int)
typealias WorkDaysStorage = [MonthKey: [WorkDay]]

typealias Day = Int
typealias Bonus = Int
typealias BonusStorageItem = [Day: Bonus]
typealias BonusesStorage = [MonthKey: BonusStorageItem]




enum AppReport {
    case addDays(AddDaysReport)
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
        }
    }
}



enum AppErorr : Error {
    case emptyInput
    case nothingToRemove
    case emptyMonthForKey
    case missmutchBonusesAndDays
    case dublicateDetacted
    case noDaysForRange
    
    var logText : String {
        switch self {
        case .emptyInput:
            return "❌ Error: Empty input"
        case .nothingToRemove:
            return "❌ Error: Nothing to remove"
        case .emptyMonthForKey:
            return "❌ Error: Month not Found"
        case .dublicateDetacted:
            return "❌ Error: Days dublicate detected"
        case .missmutchBonusesAndDays:
            return "❌ Error: Days count != Bonuses count"
        case .noDaysForRange:
            return "❌ No found days for this Range"
        }
    }
}



struct RemoveDaysReport {
    let monthKey: MonthKey
    let requested: Int
    let removed: Int
    let notFoundDays: [Int]
    let monthRemoved: Bool
    let operationStatus: OperationStatus
    
    var logText : String {
        var text = "✅ Remove days | \(monthKey)\nRemoved: \(removed)/\(requested) days!"
        if operationStatus == .warning  {
            text += "\n⚠️ Not found days: \(notFoundDays.sorted())"
        }
        
        if monthRemoved {
            text += "\n🗑️ Now month is Empty. Removing Folder..."
        }
        return text
    }
}



struct SalaryReport {
    let realSalary: Int
    let guardSalary: Int
    let predictableSalary: Int
    let noDataCount: Int
    let workedCount: Int
    let plannedCount: Int
    let myBonuses: Int
    let myAvgBonuses: Int
    let avgBonuses: Int
    let noDataDays: [Int]
    let workedDays: [Int]
    let monthKey: MonthKey
    let range: ClosedRange<Int>
    let operationStatus: OperationStatus
    let warning : SalaryWarning?
    
    var logText : String {
        var text = """
        ======== SALARY REPORT ========
        Дата: \(monthKey)
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
    let monthKey: MonthKey
    let requested: Int
    let addCount: Int
    let dublicates: [Int]
    let operationStatus: OperationStatus
    
    var logText: String {
        var text = "✅ AddDays | \(monthKey)\nAdded: \(addCount)/\(requested)"
        if operationStatus == .warning {
            text += "\n⚠️ Duplicates ignored: \(dublicates.sorted())"
        }
    return text
    }
}

struct UpdateBonusReport {
    let monthKey: MonthKey
    let mode : UpdateMode
    let result : [(day: Int, bonus: Int)]
    let scippedDays : [Int]
    let operationStatus: OperationStatus
    
    var logText : String {
        var text = "=======✅ UpdateBonuses | \(monthKey) ======="
        text += "\nMode:\(mode.title)"
        text += "\nAdd \(result.count)/\(result.count + scippedDays.count) days\n"
        for (day, bonus) in result {
                text += "\(day) : \(bonus)\n"
            }
        if operationStatus == .warning {
            text += "\n⚠️ Skipped: \(scippedDays.sorted())"
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

// MARK: DataBase
var workDaysByMonth: WorkDaysStorage = [:]
var bonusesByMonth: BonusesStorage = [:]





// MARK: Month key
func makeMonthKey(year y: Int, month m: Int) -> MonthKey {
    if m < 10 {
        return "\(y)-0\(m)"
    } else {
        return "\(y)-\(m)"
    }
}



// MARK: UpdateDays
func updateDays(forYear y: Int, forMonth m: Int, daysData d: [Int]) -> ([WorkDay]) {
    var newMonthData : [WorkDay] = []
    for dayValue in d {
        newMonthData.append((day: dayValue, month: m, year: y))
    }
    return newMonthData
}


// TODO: Add Report

func addToDataBase(monthKey key: MonthKey, setFromUpdateDays monthData:[WorkDay], setDataBaseWorkDays dataBase: inout [MonthKey: [WorkDay]]) -> Result<AppReport,AppErorr> {
    
    guard !monthData.isEmpty else {
        return .failure(.emptyInput)
    }
    
    var currentMonthDays : [WorkDay] = dataBase[key] ?? []
    var addCount = 0
    var dublicateDays : [Int] = []
    
    for value in monthData {
        let isDublicate = currentMonthDays.contains { $0 == value }
        if isDublicate {
            dublicateDays.append(value.day)
        } else {
            addCount += 1
            currentMonthDays.append(value)
        }
    }
    let status : OperationStatus = (addCount > 0) && (dublicateDays.isEmpty) ? .success : .warning
    let report = AddDaysReport(monthKey: key, requested: monthData.count, addCount: addCount, dublicates: dublicateDays, operationStatus: status)
    dataBase[key] = currentMonthDays.sorted { $0.day < $1.day }
    return .success(.addDays(report))

}

    
func updateDateForHalfMonth (year y: Int, month m: Int, addDays d: [Int], selectDataBase: inout WorkDaysStorage) -> Result<AppReport,AppErorr> {
    let month = updateDays(forYear: y, forMonth: m, daysData: d)
    let monthKey = makeMonthKey(year: y, month: m)
    let report = addToDataBase(monthKey: monthKey, setFromUpdateDays: month, setDataBaseWorkDays: &selectDataBase)
    return report
}






// MARK: Update Bonuses
// TODO: UpdateBonuses Report
func updateBonus (days d: [Int], bonuses b: [Int]) -> Result<BonusStorageItem, AppErorr> {
    var newBonusData : BonusStorageItem = [:]
    let set = Set(d)
    
    guard d.count == b.count else {
        return .failure(.missmutchBonusesAndDays)
    }
    
    guard set.count == d.count else {
        return .failure(.dublicateDetacted)
    }
   
    for (day,bonus) in zip(d, b) {
        newBonusData[day] = bonus
    }
    return .success(newBonusData)
}

// MARK: Update Bonuses Mode
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

func addBonusesToDataBase (monthKey key: MonthKey, setFromUpdateBonus newBonuses: BonusStorageItem, setBonusesStorage bonusData: inout BonusesStorage, updateMode mode: UpdateMode) -> Result<AppReport,AppErorr> {
    guard !newBonuses.isEmpty else {
        return .failure(.missmutchBonusesAndDays)
    }
    
    var monthBonuses : BonusStorageItem = bonusData[key] ?? [:]
    var applied : [Int:Int] = [:]
    var skippedDays : [Int] = []
    switch mode {
        
    case .override :
        for (day, bonus) in newBonuses {
            monthBonuses[day] = bonus
            applied[day] = bonus
        }
    case .onlyAdd :
        for (day, bonus) in newBonuses {
            if monthBonuses[day] == nil {
                monthBonuses[day] = bonus
                applied[day] = bonus
            } else {
                skippedDays.append(day)
            }
        }
    }
    
    bonusData[key] = monthBonuses
    let sorted = sortDict(applied)
    let status : OperationStatus = skippedDays.isEmpty ? .success : .warning
    let report = UpdateBonusReport(monthKey: key, mode: mode, result: sorted, scippedDays: skippedDays, operationStatus: status)
    return .success(.addBonus(report))
}

func sortDict (_ d:[Int:Int]) -> [(day:Int,bonus:Int)] {
    return d.sorted { $0.key < $1.key }.map {(day: $0.key, bonus: $0.value)}
}

func updateBonusesForRange (updateMode mode: UpdateMode, year y: Int, month m: Int, addDays days: [Int], addBonuses bonuses: [Int], setBonusesStorage bonusData: inout BonusesStorage) -> Result<AppReport,AppErorr> {
    
    let monthKey = makeMonthKey(year: y, month: m)
    switch updateBonus(days: days, bonuses: bonuses) {
      case .success(let newBonuses):
          return addBonusesToDataBase(
              monthKey: monthKey,
              setFromUpdateBonus: newBonuses,
              setBonusesStorage: &bonusData,
              updateMode: mode
          )

      case .failure(let error):
          return .failure(error)
      }
  }






// MARK: Remove days
func removeSelectDays (selectDaysToRemove rDays: [Int], year y: Int, month m: Int, selectDateBase dateBase: inout WorkDaysStorage) -> Result<AppReport,AppErorr> {
    let removeSet : Set<Int> = Set(rDays)
    let monthKey = makeMonthKey(year: y, month: m)
    var updatedData : [WorkDay] = []
    
    
    guard let monthDays = dateBase[monthKey] else {
        return .failure(.emptyMonthForKey)
    }
    
    let monthDaysSet = Set(monthDays.map {$0.day})
    let foundToRemove = Set(removeSet.filter {monthDaysSet.contains($0)})
    let notFound = Set(removeSet.filter {!monthDaysSet.contains($0)})
    
    if foundToRemove.isEmpty {
        return .failure(.nothingToRemove)
    }
    
    updatedData = monthDays.filter {!foundToRemove.contains($0.day)}
    let status : OperationStatus = foundToRemove.count == removeSet.count ? .success : .warning
    let report = RemoveDaysReport(monthKey: monthKey, requested: removeSet.count, removed: foundToRemove.count, notFoundDays: Array(notFound), monthRemoved: updatedData.isEmpty, operationStatus: status)
   
    
    if updatedData.isEmpty {
        dateBase[monthKey] = nil
    } else {
        dateBase[monthKey] = updatedData
    }
    return .success(.removeDays(report))
}



func removeAllMonth (year y: Int, month m: Int, selectDateBase dataBase: inout WorkDaysStorage) -> Result<AppReport,AppErorr> {
    let monthKey = makeMonthKey(year: y, month: m)
    if let tempBase = dataBase[monthKey] {
        let report = RemoveDaysReport(monthKey: monthKey, requested: tempBase.count, removed: tempBase.count, notFoundDays: [], monthRemoved: true, operationStatus: .success)
        dataBase[monthKey] = nil
        return .success(.removeDays(report))
    } else {
        return .failure(.nothingToRemove)
    }
}



func removeRangeDays (selectDaysToRemove rDays: ClosedRange<Int>, year y: Int, month m: Int, selectDateBase dateBase: inout WorkDaysStorage) -> Result<AppReport,AppErorr> {
    let array = Array(rDays)
    return removeSelectDays(selectDaysToRemove: array, year: y, month: m, selectDateBase: &dateBase)
}






// MARK: Filter days
func filterDaysRange (monthKey key: MonthKey, rangeDays d:ClosedRange<Int>, selectDateBase dateBase: WorkDaysStorage) -> [Int] {
    let monthDays = dateBase[key] ?? []
    let outputWorkDays : [Int] = monthDays
        .map{ $0.day }
        .filter { d.contains($0) }
        .sorted{ $0 < $1 }
    return outputWorkDays
}






// MARK: Calculate
func calcMyShiftStats (
    filterDays: [Int],
    monthBonuses: [Int: Int]
) -> (
    myBonuses: Int,
    workedCount: Int,
    noDataCount: Int,
    workedDays: [Int],
    noDataDays: [Int]
) {
    var myBonuses = 0
    var workedCount = 0
    var noDataCount = 0
    var workedDays : [Int] = []
    var noDataDays : [Int] = []
    
    for day in filterDays {
        if let realBonuses = monthBonuses[day] {
            myBonuses += realBonuses
            workedCount += 1
            workedDays.append(day)
        } else {
            noDataCount += 1
            noDataDays.append(day)
        }
    }
    
    return (myBonuses,workedCount,noDataCount,workedDays,noDataDays)
}


    

func calcAvgBonusForRange (
    monthBonuses: [Int:Int],
    range: ClosedRange<Int>
) -> (
    allBonuses: Int,
    avgBonuses:Int,
    allBonusesCount: Int
) {
    let filtered = monthBonuses.filter {range.contains($0.key)}
    let allBonusesCount = filtered.count
    let allBonuses = filtered.reduce(0) {$0 + $1.value}
    let avgBonuses = allBonusesCount > 0 ? allBonuses / allBonusesCount : 0
    
    return (allBonuses,avgBonuses,allBonusesCount)
}

// FIXME: IF BONUS = [:] NEED ADD ALERT!
func SalaryCalculateRange (selectDaysRange range: ClosedRange<Int>, monthKey key: MonthKey, funcFilterDays filterDays: [Int], setFixedPay fixedPay: Int = 1000, selectBonusDateBase bonusDb: BonusesStorage) -> Result<AppReport,AppErorr> {
    
    
    guard !filterDays.isEmpty else {
        return .failure(.noDaysForRange)
    }
    let monthBonuses : [Int:Int] = bonusDb[key] ?? [:]
    
    let stats = calcMyShiftStats(filterDays: filterDays, monthBonuses: monthBonuses)
    let avgStats = calcAvgBonusForRange(monthBonuses: monthBonuses, range: range)
    
    let plannedCount = filterDays.count
    let guardSalary = (fixedPay * plannedCount) + stats.myBonuses
    let realSalaryToday = stats.myBonuses + (fixedPay * stats.workedCount)
    
    var myAvgBonus = 0
    if stats.workedCount > 0 {
        myAvgBonus = (stats.myBonuses / stats.workedCount)
    }
    let predictableSalary = (fixedPay * plannedCount) + (myAvgBonus * stats.noDataCount) + stats.myBonuses
    let status: OperationStatus
    let warning : SalaryWarning?
    if monthBonuses.isEmpty || stats.workedCount == 0 {
        status = .warning
        warning = .noBonusesForPeriod
    } else if stats.noDataCount > 0 {
        status = .warning
        warning = .bonusesNotForAllShifts
    } else {
        status = .success
        warning = nil
    }
    
    let report = SalaryReport(
        realSalary: realSalaryToday,
        guardSalary: guardSalary,
        predictableSalary: predictableSalary,
        noDataCount: stats.noDataCount,
        workedCount: stats.workedCount,
        plannedCount: plannedCount,
        myBonuses: stats.myBonuses,
        myAvgBonuses: myAvgBonus,
        avgBonuses: avgStats.avgBonuses,
        noDataDays: stats.noDataDays,
        workedDays: stats.workedDays,
        monthKey: key,
        range: range,
        operationStatus: status,
        warning: warning)
    return .success(.salary(report))
}




// обертка калькулятора
func salaryHalfMonth (
    year y: Int,
    month m: Int,
    setPeriod range: ClosedRange<Int>,
    workDaysDB: WorkDaysStorage,
    bonusDB: BonusesStorage
) -> Result<AppReport,AppErorr> {
    let monthKey = makeMonthKey(year: y, month: m)
    let filterDays = filterDaysRange(monthKey: monthKey, rangeDays: range, selectDateBase: workDaysDB)
    let allStats = SalaryCalculateRange(selectDaysRange: range, monthKey: monthKey, funcFilterDays: filterDays, selectBonusDateBase: bonusDB)

    return allStats
    
}


// helper
func printResult (_ result: Result<AppReport, AppErorr>) {
    switch result {
    case .success(let report):
        print(report.logText)
    case .failure(let error):
        print(error.logText)
    }
}





printResult(updateDateForHalfMonth(year: 2026, month: 01, addDays: [4,5,6,9,10,11,14,15,19,20,21,24,25,26,29,30,31], selectDataBase: &workDaysByMonth))
let rep02 = updateDateForHalfMonth(year: 2026, month: 02, addDays: [1,2,3,6,7,9,12,13,15], selectDataBase: &workDaysByMonth)
printResult(rep02)
let rep03 = updateBonusesForRange(updateMode: .override, year: 2026, month: 2, addDays: [1,2,3,4,5,6,7,8,9], addBonuses: [450,0,250,100,450,600,1200,600,0], setBonusesStorage: &bonusesByMonth)
printResult(rep03)
let rep04 = updateBonusesForRange(updateMode: .override, year: 2026, month: 01, addDays: [2,3,4,5,6,7,8,9,10,11,12,13,14,15], addBonuses: [400,200,150,150,100,150,100,300,250,350,250,400,300,250], setBonusesStorage: &bonusesByMonth)
printResult(rep04)
let rep05 = updateBonusesForRange(updateMode: .override, year: 2026, month: 1, addDays: [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31], addBonuses: [500,1000,500,200,1400,350,900,1050,1000,350,200,100,150,0,550,400], setBonusesStorage: &bonusesByMonth)
printResult(rep05)
let rep06 = updateBonusesForRange(updateMode: .onlyAdd, year: 2026, month: 2, addDays: [10,11,12,13,14,15], addBonuses: [150,250,200,250,950,450], setBonusesStorage: &bonusesByMonth)
printResult(rep06)
let report = salaryHalfMonth(year: 2026, month: 2, setPeriod: 1...15, workDaysDB: workDaysByMonth, bonusDB: bonusesByMonth)
printResult(report)
 
