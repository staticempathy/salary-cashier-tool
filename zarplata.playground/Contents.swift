typealias MonthKey = String
typealias WorkDay = (day: Int, month: Int, year: Int)
typealias WorkDaysStorage = [MonthKey: [WorkDay]]

typealias Day = Int
typealias Bonus = Int
typealias BonusStorageItem = [Day: Bonus]
typealias BonusesStorage = [MonthKey: BonusStorageItem]

typealias RemoveDaysReport = (
    monthKey: MonthKey,
    requested: Int,
    removed: Int,
    notFoundDays: [Int],
    monthRemoved: Bool
)

typealias SalaryReport = (
    realSalary: Int,
    guardSalary: Int,
    predictableSalary: Int,
    noDataCount: Int,
    workedCount: Int,
    plannedCount: Int,
    myBonuses: Int,
    myAvgBonuses: Int,
    avgBonuses: Int,
    noDataDays: [Int],
    workedDays: [Int],
    monthKey: MonthKey,
    range: ClosedRange<Int>
)

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



func addToDataBase(monthKey key: MonthKey, setFromUpdateDays monthData:[WorkDay], setDataBaseWorkDays dataBase: inout [MonthKey: [WorkDay]]) -> () {
    var currentMonthDays : [WorkDay] = dataBase[key] ?? []
    var addCount = 0
    for value in monthData {
        let isDublicate = currentMonthDays.contains { $0 == value }
            if !isDublicate {
            addCount += 1
            currentMonthDays.append(value)
        }
    }

    dataBase[key] = currentMonthDays.sorted { $0.day < $1.day }
    if addCount > 0 {
        print("Add \(addCount)/\(monthData.count) days succes!")
    } else {
        print("\(addCount) days not add!")
    }
}

    
    
func updateDateForHalfMonth (year y: Int, month m: Int, addDays d: [Int], selectDataBase: inout WorkDaysStorage) {
    let month = updateDays(forYear: y, forMonth: m, daysData: d)
    let monthKey = makeMonthKey(year: y, month: m)
    addToDataBase(monthKey: monthKey, setFromUpdateDays: month, setDataBaseWorkDays: &selectDataBase)
}






// MARK: Update Bonuses
func updateBonus (days d: [Int], bonuses b: [Int]) -> BonusStorageItem? {
    var newBonusData : BonusStorageItem = [:]
    let set = Set(d)
    
    guard d.count == b.count else {
        print("Error! days.count != bonuses.count")
        return nil
    }
    
    guard set.count == d.count else {
        print("Error! Dublicate detected!")
        return nil
    }
   
    for (day,bonus) in zip(d, b) {
        newBonusData[day] = bonus
    }
    return newBonusData
}



func addBonusesToDataBase (monthKey key: MonthKey, setFromUpdateBonus newBonuses: BonusStorageItem, setBonusesStorage bonusData: inout BonusesStorage, overRide ovr: Bool) -> () {
    var monthBonuses : BonusStorageItem = bonusData[key] ?? [:]
    if ovr {
        for (day, bonus) in newBonuses {
            monthBonuses[day] = bonus
        }
    } else {
        for (day, bonus) in newBonuses {
            if monthBonuses[day] == nil {
                monthBonuses[day] = bonus
            } else {
                continue
            }
        }
        
    }
    bonusData[key] = monthBonuses
    print("Update bonuses succes!")
}


func updateBonusesForRange (overRide ovr: Bool, year y: Int, month m: Int, addDays days: [Int], addBonuses bonuses: [Int], setBonusesStorage bonusData: inout BonusesStorage) -> () {
    
    let monthKey = makeMonthKey(year: y, month: m)
    if let month = updateBonus(days: days, bonuses: bonuses) {
        addBonusesToDataBase(monthKey: monthKey, setFromUpdateBonus: month, setBonusesStorage: &bonusData, overRide: ovr)
    }
}






// MARK: printRemoveReport
func printRemoveReport (_ report: RemoveDaysReport) -> Void {
    print("======= REMOVE REPORT =======")
     print("Month: \(report.monthKey)")
     print("Requested: \(report.requested)")
     print("Removed: \(report.removed)")
     
     if !report.notFoundDays.isEmpty {
         print("Not found: \(report.notFoundDays)")
     }
     
     if report.monthRemoved {
         print("Month folder removed (empty)")
     }
     
     print("=============================")
}



// MARK: Remove days
func removeSelectDays (selectDaysToRemove rDays: [Int], year y: Int, month m: Int, selectDateBase dateBase: inout WorkDaysStorage) -> (RemoveDaysReport) {
    let removeSet : Set<Int> = Set(rDays)
    let monthKey = makeMonthKey(year: y, month: m)
    var updatedData : [WorkDay] = []
    
    
    guard let monthDays = dateBase[monthKey] else {
        return (monthKey,removeSet.count,0,Array(removeSet),false)
    }
    
    let monthDaysSet = Set(monthDays.map {$0.day})
    let foundToRemove = Set(removeSet.filter {monthDaysSet.contains($0)})
    let notFound = Set(removeSet.filter {!monthDaysSet.contains($0)})
    
    if foundToRemove.isEmpty {
        return (monthKey,removeSet.count,0,Array(notFound),false)
    }
    updatedData = monthDays.filter {!foundToRemove.contains($0.day)}
    
    if updatedData.isEmpty {
        dateBase[monthKey] = nil
        return (monthKey,removeSet.count,foundToRemove.count,Array(notFound),true)
    } else {
        dateBase[monthKey] = updatedData
        return (monthKey,removeSet.count,foundToRemove.count,Array(notFound),false)
    }
}



func removeAllMonth (year y: Int, month m: Int, selectDateBase dataBase: inout WorkDaysStorage) -> (RemoveDaysReport) {
    let monthKey = makeMonthKey(year: y, month: m)
    if let tempBase = dataBase[monthKey] {
        dataBase[monthKey] = nil
        return (monthKey,tempBase.count, tempBase.count, [], true)
    } else {
        return (monthKey,0,0,[],false)
    }
}



func removeRangeDays (selectDaysToRemove rDays: ClosedRange<Int>, year y: Int, month m: Int, selectDateBase dateBase: inout WorkDaysStorage) -> (RemoveDaysReport) {
    let array = Array(rDays)
    return removeSelectDays(selectDaysToRemove: array, year: y, month: m, selectDateBase: &dateBase)
}






// MARK: Filter days
func filterDaysRange (monthKey key: MonthKey, rangeDays d:ClosedRange<Int>, selectDateBase dateBase: WorkDaysStorage) -> [Int] {
    let monthDays = dateBase[key] ?? []
    var outputWorkDays : [Int] = monthDays
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
func SalaryCalculateRange (selectDaysRange range: ClosedRange<Int>, monthKey key: MonthKey, funcFilterDays filterDays: [Int], setFixedPay fixedPay: Int = 1000, selectBonusDateBase bonusDb: BonusesStorage) -> SalaryReport {
    
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
    var predictableSalary = (fixedPay * plannedCount) + (myAvgBonus * stats.noDataCount) + stats.myBonuses
    return (realSalaryToday,guardSalary,predictableSalary,stats.noDataCount,stats.workedCount,plannedCount,stats.myBonuses,myAvgBonus,avgStats.avgBonuses,stats.noDataDays, stats.workedDays,key,range)
}


// MARK: TableReport
func printReport (report: (SalaryReport) ) -> () {
    print("""
        ======== SALARY REPORT ========
        Дата: \(report.monthKey)
        Дни:   \(report.range)
        -------------------------------
        Кол-во смен:            \(report.plannedCount)
        Отработано:             \(report.workedCount)
        Не отработано:          \(report.noDataCount)
        -------------------------------
        Мои бонусы:             \(report.myBonuses)
        Средний бонус:          \(report.myAvgBonuses)
        Общий средний бонус:    \(report.avgBonuses)
        -------------------------------
        Зарплата сейчас:        \(report.realSalary)
        Прогноз зп:             \(report.predictableSalary)
        Гарантированная зп:     \(report.guardSalary)
        -------------------------------
        Отработанные дни:       \(report.workedDays)
        Не отработанные дни:    \(report.noDataDays)
        ================================
        """)
}




// обертка калькулятора
func salaryHalfMonth (
    year y: Int,
    month m: Int,
    setPeriod range: ClosedRange<Int>,
    workDaysDB: WorkDaysStorage,
    bonusDB: BonusesStorage
) -> (SalaryReport) {
    let monthKey = makeMonthKey(year: y, month: m)
    let filterDays = filterDaysRange(monthKey: monthKey, rangeDays: range, selectDateBase: workDaysDB)
    let allStats = SalaryCalculateRange(selectDaysRange: range, monthKey: monthKey, funcFilterDays: filterDays, selectBonusDateBase: bonusDB)

    return(allStats)
    
}







updateDateForHalfMonth(year: 2026, month: 01, addDays: [4,5,6,9,10,11,14,15,19,20,21,24,25,26,29,30,31], selectDataBase: &workDaysByMonth)
updateDateForHalfMonth(year: 2026, month: 02, addDays: [1,2,3,6,7,9,12,13,15], selectDataBase: &workDaysByMonth)
updateBonusesForRange(overRide: true, year: 2026, month: 2, addDays: [1,2,3,4,5,6,7,8,9], addBonuses: [450,0,250,100,450,600,1200,600,0], setBonusesStorage: &bonusesByMonth)
updateBonusesForRange(overRide: true, year: 2026, month: 1, addDays: [2,3,4,5,6,7,8,9,10,11,12,13,14,15], addBonuses: [400,200,150,150,100,150,100,300,250,350,250,400,300,250], setBonusesStorage: &bonusesByMonth)
updateBonusesForRange(overRide: false, year: 2026, month: 1, addDays: [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31], addBonuses: [500,1000,500,200,1400,350,900,1050,1000,350,200,100,150,0,550,400], setBonusesStorage: &bonusesByMonth)
//print("\(workDaysByMonth) \n\n\(bonusesByMonth)")
//bonusesByMonth
updateBonusesForRange(overRide: false, year: 2026, month: 2, addDays: [10,11,12,13,14,15], addBonuses: [150,250,200,250,950,450], setBonusesStorage: &bonusesByMonth)
let report = salaryHalfMonth(year: 2026, month: 2, setPeriod: 1...15, workDaysDB: workDaysByMonth, bonusDB: bonusesByMonth)
printReport(report: report)
