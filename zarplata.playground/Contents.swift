typealias MonthKey = String
typealias WorkDay = (day: Int, month: Int, year: Int)
typealias WorkDaysStorage = [MonthKey: [WorkDay]]

typealias Day = Int
typealias Bonus = Int
typealias BonusStorageItem = [Day: Bonus]
typealias BonusesStorage = [MonthKey: BonusStorageItem]



// data base
var workDaysByMonth: WorkDaysStorage = [:]
var bonusesByMonth: BonusesStorage = [:]






// хранение дней

// создать ключ месяца для хранения по пакам
func makeMonthKey(year y: Int, month m: Int) -> MonthKey {
    if m < 10 {
        return "\(y)-0\(m)"
    } else {
        return "\(y)-\(m)"
    }
}



// создает массив с новыми днями (обновление данных)
func updateDays(forYear y: Int, forMonth m: Int, daysData d: [Int]) -> ([WorkDay]) {
    var newMonthData : [WorkDay] = []
    for dayValue in d {
        newMonthData.append((day: dayValue, month: m, year: y))
    }
    return newMonthData
}



// обновляет дни в общей базе данных дней и проверяет на дубликаты
func addToDataBase(monthKey key: MonthKey, setFromUpdateDays monthData:[WorkDay], setDataBaseWorkDays dataBase: inout [MonthKey: [WorkDay]]) -> () {
    var currentMonthDays : [WorkDay] = dataBase[key] ?? []
    var addCount = 0
    for value in monthData {
        var isDublicate = false
        for exiting in currentMonthDays {
            if value.day == exiting.day && value.month == exiting.month && value.year == exiting.year {
                isDublicate = true
                print("Warning day \(value.day) already exist!")
                break
            }
        }
        if !isDublicate {
            addCount += 1
            currentMonthDays.append(value)
        }
    }
    dataBase[key] = currentMonthDays
    if addCount > 0 {
        print("Add \(addCount)/\(monthData.count) days succes!")
    } else {
        print("\(addCount) days not add!")
    }
}

    
    
// обертка
func updateDateForHalfMonth (year y: Int, month m: Int, addDays d: [Int], selectDataBase: inout WorkDaysStorage) {
    let month = updateDays(forYear: y, forMonth: m, daysData: d)
    let monthKey = makeMonthKey(year: y, month: m)
    addToDataBase(monthKey: monthKey, setFromUpdateDays: month, setDataBaseWorkDays: &selectDataBase)
}






// хранение бонусов

// создает словарь бонусов за определенный ренж
func updateBonus (days d: [Int], bonuses b: [Int]) -> BonusStorageItem {
    var newBonusData : BonusStorageItem = [:]
    let set = Set(d)
    if d.count != b.count {
        print("Error! days.count != bonuses.count")
        return newBonusData
    } else if set.count != d.count {
        print("Error! Dublicate detected!")
        return newBonusData
    }
    for index in 0..<b.count {
        newBonusData[d[index]] = b[index]
    }
    return newBonusData
}



// добавляет созданный словарь в базу данных
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



// обертка
func updateBonusesForRange (overRide ovr: Bool, year y: Int, month m: Int, addDays days: [Int], addBonuses bonuses: [Int], setBonusesStorage bonusData: inout BonusesStorage) -> () {
    let month = updateBonus(days: days, bonuses: bonuses)
    let monthKey = makeMonthKey(year: y, month: m)
    addBonusesToDataBase(monthKey: monthKey, setFromUpdateBonus: month, setBonusesStorage: &bonusData, overRide: ovr)
}






// удаление данных (1. Выбранные дни)
func removeSelectDays (selectDaysToRemove rDays: [Int], year y: Int, month m: Int, selectDateBase dateBase: inout WorkDaysStorage) -> () {
    let removeSet : Set<Int> = Set(rDays)
    let monthKey = makeMonthKey(year: y, month: m)
    
    var updatedData : [WorkDay] = []
    var deletedItems = 0
    var notFoundedSet : Set<Int> = Set(rDays)
    
    if let tempDateBase = dateBase[monthKey] {
        for i in 0..<tempDateBase.count {
            if !removeSet.contains(tempDateBase[i].day) {
                updatedData.append(tempDateBase[i])
            } else {
                deletedItems += 1
                notFoundedSet.remove(tempDateBase[i].day)
            }
        }
    } else {
        print("No data for this month")
        return
    }
    if updatedData.isEmpty {
        print("Now month is emtpy, removing folder... \(deletedItems) / \(removeSet.count) items have been removed ")
        dateBase[monthKey] = nil
        return
    } else {
        dateBase[monthKey] = updatedData
        switch notFoundedSet.count {
            case 0:
                print("Success! \(deletedItems) / \(removeSet.count) items have been removed")
            case removeSet.count:
                print("Your data not found, \(deletedItems) / \(removeSet.count) items have been removed")
            default:
            print("Warning! \(deletedItems) / \(removeSet.count) items have been removed, not founded: \(notFoundedSet)")

        }
    }
    
}



// удаление данных (весь месяц)
func removeAllMonth (year y: Int, month m: Int, selectDateBase dataBase: inout WorkDaysStorage) -> () {
    let monthKey = makeMonthKey(year: y, month: m)
    if dataBase[monthKey] != nil {
        dataBase[monthKey] = nil
        print("\(monthKey) has been removed")
    } else {
        print("\(monthKey) not Found!")
    }
}



// удаление данных (диапазон)
func removeRangeDays (selectDaysToRemove rDays: ClosedRange<Int>, year y: Int, month m: Int, selectDateBase dateBase: inout WorkDaysStorage) -> () {
    let array = Array(rDays)
    removeSelectDays(selectDaysToRemove: array, year: y, month: m, selectDateBase: &dateBase)
}







// фильтрация дней по диапазону
func filterDaysRange (monthKey key: MonthKey, rangeDays d:ClosedRange<Int>, selectDateBase dateBase: WorkDaysStorage) -> [Int] {
    let monthDays = dateBase[key] ?? []
    var outputWorkDays :[Int] = []
    
    if !monthDays.isEmpty {
        for workDay in monthDays {
            if d.contains(workDay.day) {
                outputWorkDays.append(workDay.day)
            }
            }
        } else {
            print("No data for this month")
            return []
    }
    
    return outputWorkDays.sorted()
}





// подсчитать мой бонус за период
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
    
    
// подсчитать средний бонус за период
func calcAvgBonusForRange (
    monthBonuses: [Int:Int],
    range: ClosedRange<Int>
) -> (
    allBonuses: Int,
    avgBonuses:Int,
    allBonusesCount: Int
) {
    var allBonuses = 0
    var avgBonuses = 0
    var allBonusesCount = 0
    for (day,bonus) in monthBonuses {
        if range.contains(day) {
            allBonuses += bonus
            allBonusesCount += 1
        }
    }
    if allBonusesCount > 0 {
        avgBonuses = allBonuses / allBonusesCount
    }
    return (allBonuses,avgBonuses,allBonusesCount)
}
    





// функция калькулятор
func SalaryCalculateRange (selectDaysRange range: ClosedRange<Int>, monthKey key: MonthKey, funcFilterDays filterDays: [Int], setFixedPay fixedPay: Int = 1000, selectBonusDateBase bonusDb: BonusesStorage) -> (realSalary: Int, guardSalary: Int, predictableSalary: Int, noDataCount: Int, workedCount: Int, plannedCount: Int, myBonuses: Int, myAvgBonuses: Int, avgBonuses: Int, noDataDays: [Int], workedDays: [Int] ) {
    
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
    return (realSalaryToday,guardSalary,predictableSalary,stats.noDataCount,stats.workedCount,plannedCount,stats.myBonuses,myAvgBonus,avgStats.avgBonuses,stats.noDataDays, stats.workedDays)
}


// красивый табличный вывод
func printReport (
    monthKey: MonthKey,
    range: ClosedRange<Int>,
    report: (realSalary: Int,
             guardSalary: Int,
             predictableSalary: Int,
             noDataCount: Int,
             workedCount: Int,
             plannedCount: Int,
             myBonuses: Int,
             myAvgBonuses: Int,
             avgBonuses: Int,
             noDataDays: [Int],
             workedDays: [Int])
) -> () {
    print("""
        ======== SALARY REPORT ========
        Дата: \(monthKey)
        Дни:   \(range)
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
) -> (
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
    workedDays: [Int]
) {
    let monthKey = makeMonthKey(year: y, month: m)
    let filterDays = filterDaysRange(monthKey: monthKey, rangeDays: range, selectDateBase: workDaysDB)
    let allStats = SalaryCalculateRange(selectDaysRange: range, monthKey: monthKey, funcFilterDays: filterDays, selectBonusDateBase: bonusDB)
    
    printReport(monthKey: monthKey, range: range, report: allStats)
    return(allStats)
    
}







updateDateForHalfMonth(year: 2026, month: 01, addDays: [4,5,6,9,10,11,14,15,19,20,21,24,25,26,29,30,31], selectDataBase: &workDaysByMonth)
updateDateForHalfMonth(year: 2026, month: 02, addDays: [1,2,3,6,7,9,12,13,15], selectDataBase: &workDaysByMonth)
updateBonusesForRange(overRide: true, year: 2026, month: 2, addDays: [1,2,3,4,5,6,7,8,9], addBonuses: [450,0,250,100,450,600,1200,600,0], setBonusesStorage: &bonusesByMonth)
updateBonusesForRange(overRide: true, year: 2026, month: 1, addDays: [2,3,4,5,6,7,8,9,10,11,12,13,14,15], addBonuses: [400,200,150,150,100,150,100,300,250,350,250,400,300,250], setBonusesStorage: &bonusesByMonth)
updateBonusesForRange(overRide: false, year: 2026, month: 1, addDays: [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31], addBonuses: [500,1000,500,200,1400,350,900,1050,1000,350,200,100,150,0,550,400], setBonusesStorage: &bonusesByMonth)
//print("\(workDaysByMonth) \n\n\(bonusesByMonth)")
//bonusesByMonth

salaryHalfMonth(year: 2026, month: 1, setPeriod: 16...31, workDaysDB: workDaysByMonth, bonusDB: bonusesByMonth)




