//
//  StatsVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 04/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import UIKit

import Charts
import LinearProgressBar
import SimplePDF
class ProgressStatsView:UIView{
    
    @IBOutlet weak var lblAudioValue: UILabel!
    @IBOutlet weak var lblVideoValue: UILabel!
    @IBOutlet weak var audioProgress: LinearProgressBar!
    @IBOutlet weak var videoProgress: LinearProgressBar!
    @IBOutlet weak var lblsbValue: UILabel!
    @IBOutlet weak var lblbgValue: UILabel!
    @IBOutlet weak var lblccValue: UILabel!
    @IBOutlet weak var lblvnsValue: UILabel!
    @IBOutlet weak var lblbhajansValue: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("ProgressStatsView : frame")
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("ProgressStatsView : coder")
        
    }
}

class CaustomStatsView:UIView{
    @IBOutlet weak var lblAudioValue: UILabel!
    @IBOutlet weak var lblVideoValue: UILabel!
    @IBOutlet weak var lblStartFrom: UILabel!
    @IBOutlet weak var lblEndto: UILabel!
    @IBOutlet weak var btnAllTime : UIButton!
    @IBOutlet weak var calendarView:FSCalendar!
    var startDate:Date? = nil
    var endDate:Date? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("CaustomStatsView : frame")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("CaustomStatsView : coder")
    }
    
    @IBAction func selectCaustomData(_ sender:UIButton){
        self.calendarView.isHidden = false
        self.calendarView.tag = sender.tag
        if sender.tag == 0{
            self.btnAllTime.setTitleColor(.systemGray, for: .normal)
            self.lblStartFrom.textColor = AppColors.primaryOring
        }else if sender.tag == 1{
            self.btnAllTime.setTitleColor(.systemGray, for: .normal)
            self.lblEndto.textColor = AppColors.primaryOring
        }else if sender.tag == 2{
            self.btnAllTime.setTitleColor(AppColors.primaryOring, for: .normal)
            self.lblEndto.textColor = .systemGray
            self.lblStartFrom.textColor = .systemGray
            self.lblStartFrom.text = "Start Date:"
            self.lblEndto.text = "End Date:"
        }
    }
}

class TotalRecordStats:UIView{
    @IBOutlet weak var txtTotalLectures: UITextField!
    @IBOutlet weak var txtTotalheard: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("TotalRecordStats : frame")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("TotalRecordStats : coder")
    }
    
}

class StatsVC: UIViewController {
    var listenRecords : [ListenRecord] = []
    @IBOutlet weak var lastWeekChart: BarChartView!
    @IBOutlet weak var weeklyProgressView: ProgressStatsView!
    @IBOutlet weak var monthlyProgressView: ProgressStatsView!
    @IBOutlet weak var customView: CaustomStatsView!
    @IBOutlet weak var totalRecordView: TotalRecordStats!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    private var  isMinutesMode : Bool = true{
        willSet{
            if newValue == true{
                lblyXas.text = "M I NUTES"
            }else{
                lblyXas.text = "HOURS"
            }
        }
    }
    @IBOutlet private weak var lblyXas:UILabel!
    
    let yearMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblyXas.text = "M I NUTES"
        getAllActivite()
    }
    
    @IBAction func openSideMenu(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareStatsWith(_ sender:UIButton){
        
        let a = self.totalRecordView.asImage()
        let b = self.monthlyProgressView.asImage()
        let c = self.weeklyProgressView.asImage()
        let d = self.barView.asImage()
        let e = self.customView.asImage()
        let pdf = SimplePDF(pageSize: self.scroll.contentSize,pageMarginLeft: 2.0,pageMarginTop: 10.0, pageMarginBottom: 0.0,pageMarginRight:2.0)
        // or
        // pdf.addText("Hello World!", font: myFont, textColor: myTextColor)
        pdf.addLineSpace(40)
        pdf.addImage(a)
        pdf.addImage(b)
        pdf.addImage(c)
        pdf.addImage(d)
        pdf.addImage(e)
        
        
        let pdfData = pdf.generatePDFdata()
        
        self.openShareActivityControler(userContent: [pdfData])
        
        
        //                //  LOCAL CREATEIONS
        //                let bottomOffset = CGPoint(x: 0, y: 0 )
        //                self.scroll.setContentOffset(bottomOffset, animated: true)
        //                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
        //                    let statsPDF  = ScrollViewSnapshotter.shared.PDFWithScrollView(scrollview: self.scroll)
        //                    self.openShareActivityControler(userContent: [statsPDF])//"User:\(GlobleVAR.appUser.email)"
        //                }
    }
    
    func generatePDFdata(withView view: UIView) -> NSData {
        
        let pageDimensions = view.bounds
        let outputData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(outputData, pageDimensions, nil)
        if let context = UIGraphicsGetCurrentContext() {
            UIGraphicsBeginPDFPage()
            view.layer.render(in: context)
        }
        UIGraphicsEndPDFContext()
        
        return outputData
    }
    
}
//MARK: set user activity BarGraph
extension StatsVC{
    func setGroupBarChart(audioVal:[Double],videoVal:[Double],unitName:[String]) {
        // Do any additional setup after loading the view, typically from a nib.
        lastWeekChart.noDataText = "You need to provide data for the chart."
        //lastWeekChart.chartDescription?.text = "YOUR WEEKLY ACTIVITY"
        //legend
        let legend = lastWeekChart.legend
        //        legend.enabled = true
        //        legend.horizontalAlignment = .right
        //        legend.verticalAlignment = .top
        //        legend.orientation = .vertical
        //        legend.drawInside = true
        //        legend.yOffset = 10.0;
        //        legend.xOffset = 10.0;
        //        legend.yEntrySpace = 0.0;
        legend.enabled = true
        legend.direction = Legend.Direction.rightToLeft//LegendDirection.RIGHT_TO_LEFT
        //legend.description.enabled = false
        
        let xaxis = lastWeekChart.xAxis
        xaxis.drawGridLinesEnabled = true
        xaxis.labelPosition = .bottom
        xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = IndexAxisValueFormatter(values:unitName)
        xaxis.granularity = 1
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 24
        leftAxisFormatter.alwaysShowsDecimalSeparator = false      
        let yaxis = lastWeekChart.leftAxis
        //yaxis.spaceTop = 10.35
        yaxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        
        yaxis.axisMinimum = 0
        yaxis.granularity = 1
        
        yaxis.drawGridLinesEnabled = false
        lastWeekChart.rightAxis.enabled = false
        setChart(audioVal: audioVal, videoVal: videoVal, unitName: unitName)
    }
    
    func setChart(audioVal:[Double],videoVal:[Double],unitName:[String]) {
        lastWeekChart.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        
        for i in 0..<unitName.count {
            let dataEntry = BarChartDataEntry(x: Double(i) , y: audioVal[i])
            dataEntries.append(dataEntry)
            
            let dataEntry1 = BarChartDataEntry(x: Double(i) , y: videoVal[i])
            dataEntries1.append(dataEntry1)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Audio")
        let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Video")
        chartDataSet.drawValuesEnabled = false
        chartDataSet1.drawValuesEnabled = false
        
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        let chartData = BarChartData(dataSets: dataSets)
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        let groupCount = unitName.count
        let startYear = 0
        chartData.barWidth = barWidth;
        lastWeekChart.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        print("Groupspace: \(gg)")
        lastWeekChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        lastWeekChart.notifyDataSetChanged()
        lastWeekChart.data = chartData
        //chart animation
        lastWeekChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
    }
    
    func animation(){
        lastWeekChart.xAxis.labelPosition = .bottom
        lastWeekChart.backgroundColor = .white
        lastWeekChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
}

import FSCalendar
extension StatsVC:FSCalendarDelegate,FSCalendarDataSource{
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell: FSCalendarCell = calendar.dequeueReusableCell(withIdentifier: "CELL", for: date, at: position)
        let dateFromStringFormatter = DateFormatter();
        dateFromStringFormatter.dateFormat = "YYYY-MM-dd";
        let calendarDate = dateFromStringFormatter.string(from: date)
        return cell;
        
    }
    // This delegate call when date is selected
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cDate = Date()
        
        if date > cDate{
            //
            self.popupAlert(title: "Error", message: "Selected date must be less than or equal to current date", actionTitles: ["OK"], actions: [nil])
            return
        }
        if calendar.tag == 0{
            //start
            if let eDate = self.customView.endDate ,date > eDate{
                self.popupAlert(title: "Error", message: "Selected date must be less than or equal to Start Date", actionTitles: ["OK"], actions: [nil])
                return
            }
            self.customView.startDate = date
            self.customView.lblStartFrom.text = "\(date.get(.day))-\(date.get(.month))-\(date.get(.year))"
            if self.customView.endDate == nil{
                
                self.customView.endDate = cDate
                self.customView.lblEndto.text = "\(cDate.get(.day))-\(cDate.get(.month))-\(cDate.get(.year))"
            }
        }else if calendar.tag == 1{
            //end
            if let sDate = self.customView.startDate ,date < sDate{
                self.popupAlert(title: "Error", message: "Selected date must be later than or same as starting date.", actionTitles: ["OK"], actions: [nil])
                return
            }
            self.customView.endDate = date
            self.customView.lblEndto.text = "\(date.get(.day))-\(date.get(.month))-\(date.get(.year))"
            
            
        }else{
            //All
            
        }
        self.customView.calendarView.isHidden = true
        
        
        
        guard let start = self.customView.startDate else{return}
        guard let end = self.customView.endDate else{return}
        setData(onView: self.customView, dispalyBy: .custome, startData: start, endeData: end)
        
    }
    
    // This delegate call when date is DeSelected
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
        self.customView.calendarView.isHidden = true
        print("selected Date:",calendar.selectedDate)
        print(" Date:",date)
        
    }
    @IBAction func selectAllRecoredAction(_sender:UIButton){
        self.customView.calendarView.isHidden = true
        self.customView.btnAllTime.setTitleColor(AppColors.primaryOring, for: .normal)
        self.customView.lblEndto.textColor = .systemGray
        self.customView.lblStartFrom.textColor = .systemGray
        self.customView.lblStartFrom.text = "Start Date:"
        self.customView.lblEndto.text = "End Date:"
        self.customView.startDate = nil
        self.customView.endDate = nil
        setData(onView: self.customView, dispalyBy: .all)
    }
}
//POPULATE DATA
extension StatsVC{
    func getAllActivite(){
        ListenRecord.getUserListenDetails(by: .all) { (lect) in
            print("---> ALL ACTIVITY RECIVED")
            // let finalPoint = 24*30*3600
            CommonFunc.shared.switchAppLoader(value: false)
            self.listenRecords = lect ?? []
            self.setData(onView: self.totalRecordView, dispalyBy: .all)
            self.setData(onView: self.weeklyProgressView, dispalyBy: .lastweek)
            self.setData(onView: self.monthlyProgressView, dispalyBy: .lastMonth)
            self.setData(onView: self.lastWeekChart, dispalyBy: .thisWeek)
            self.setData(onView: self.customView, dispalyBy: .all)
            self.customView.btnAllTime.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.customView.btnAllTime.setTitle("   All   \n Time ", for: .normal)
            self.customView.btnAllTime.setTitleColor(AppColors.primaryOring, for: .normal)
        }
    }
    func setData(onView customeView:UIView,dispalyBy:RetriveBy,startData:Date? = nil ,endeData:Date? = nil){
        var oprationalListion : [ListenRecord] = []
        //total second of day
        var finalPoint = 24*1*3600
        
        switch dispalyBy {
        case .day:
            //total second of day redusing 6 hrs as sleeping hrs
            
            finalPoint = 16*1*3600
            oprationalListion = Array(self.listenRecords.prefix(5))
        case .week:
            oprationalListion = Array(self.listenRecords.prefix(7))
        case .month:
            oprationalListion = Array(self.listenRecords.prefix(30))
        case .year:
            oprationalListion = Array(self.listenRecords.prefix(365))
        case .all:
            oprationalListion = self.listenRecords
        case .lastweek:
            guard let weekDate = Date().getDate(by: .lastweek) else {return}
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("*lastweek*")
            print(format.string(from: weekDate.lastDate))
            print(format.string(from: weekDate.currentDate))
            let lastWeekRecord = self.listenRecords.filter({$0.date >=  weekDate.lastDate && $0.date < weekDate.currentDate})
            oprationalListion = lastWeekRecord
            print("oprationalListion.count",oprationalListion.count)
            break
        case .lastMonth:
            guard let lastMonth = Date().getDate(by: .lastMonth) else {return}
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("*lastMonth*")
            print(format.string(from: lastMonth.lastDate))
            print(format.string(from: lastMonth.currentDate))
            let lastMonthRecord = self.listenRecords.filter({$0.date >=  lastMonth.lastDate && $0.date < lastMonth.currentDate})
            oprationalListion = lastMonthRecord
            print( "finalPoint",24*oprationalListion.count*3600)
            
            break
        case .thisWeek:
            print("*thisWeek*")
            guard let thisWeek = Date().getDate(by: .thisWeek) else {return}
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("thisWeek.lastDate",format.string(from: thisWeek.lastDate))
            print("thisWeek.currentDate",format.string(from: thisWeek.currentDate))
            let lastWeekRecord = self.listenRecords.filter({$0.date >=  thisWeek.lastDate && $0.date < thisWeek.currentDate})
            oprationalListion = lastWeekRecord
            print("oprationalListion.count",oprationalListion.count)
            
            break
        case .custome:
            let lastday  = endeData?.addingTimeInterval(60*60*24)
            oprationalListion = self.listenRecords.filter({$0.date >= startData! && $0.date <= lastday!})
        case .other:
            oprationalListion = self.listenRecords
        }
        finalPoint = 24*oprationalListion.count*3600
        if customeView == self.weeklyProgressView || customeView == self.monthlyProgressView{
            print("weeklyProgressView ++ monthlyProgressView")
            guard oprationalListion.count > 0 else{
                if customeView == self.weeklyProgressView{
                    print("weeklyProgressView")
                    self.weeklyProgressView.lblAudioValue.text = "0:00h"
                    self.weeklyProgressView.lblVideoValue.text = "0:00h"
                    self.weeklyProgressView.videoProgress.progressValue  = 0.0
                    self.weeklyProgressView.audioProgress.progressValue  = 0.0
                    self.weeklyProgressView.lblsbValue.text = "0h"
                    self.weeklyProgressView.lblbgValue.text = "0h"
                    self.weeklyProgressView.lblvnsValue.text = "0h"
                    self.weeklyProgressView.lblccValue.text = "0h"
                    self.weeklyProgressView.lblbhajansValue.text = "0h"
                    
                }else{
                    print("monthlyProgressView")
                    self.monthlyProgressView.lblAudioValue.text = "0:00h"
                    self.monthlyProgressView.lblVideoValue.text = "0:00h"
                    self.monthlyProgressView.videoProgress.progressValue  = 0.0
                    self.monthlyProgressView.audioProgress.progressValue  = 0.0
                    self.monthlyProgressView.lblsbValue.text = "0h"
                    self.monthlyProgressView.lblbgValue.text = "0h"
                    self.monthlyProgressView.lblvnsValue.text = "0h"
                    self.monthlyProgressView.lblccValue.text = "0h"
                    self.monthlyProgressView.lblbhajansValue.text = "0h"
                }
                return
            }
            let audioListenVal = oprationalListion.compactMap({$0.audioListen}).reduce(0) { $0 + $1 }
            let audioStrTime = Double(audioListenVal).secToMintasString(style: .abbreviated)
            let audiolastPoint = audioListenVal
            let audioFileProgreass =  CGFloat((audiolastPoint*100)/finalPoint)
            print("audioFileProgreass",audioFileProgreass)
            
            let videoListion = oprationalListion.compactMap({$0.videoListen}).reduce(0) { $0 + $1 }
            let videoSrtTime = Double(videoListion).secToMintasString(style: .abbreviated)
            let videoLastPoint = videoListion
            let videoFileProgreass =  CGFloat((videoLastPoint*100)/finalPoint)
            print("videoFileProgreass",videoFileProgreass)
            
            let listenSB = oprationalListion.compactMap({$0.listenDetails?.SB}).reduce(0) { $0 + $1 }
            let listenCC = oprationalListion.compactMap({$0.listenDetails?.CC}).reduce(0) { $0 + $1 }
            let listenBG = oprationalListion.compactMap({$0.listenDetails?.BG}).reduce(0) { $0 + $1 }
            let listenVNS = oprationalListion.compactMap({$0.listenDetails?.VSN}).reduce(0) { $0 + $1 }
            let listenBhajans = oprationalListion.compactMap({$0.listenDetails?.others}).reduce(0) { $0 + $1 }
            if customeView == self.weeklyProgressView{
                print("weeklyProgressView")
                self.weeklyProgressView.lblAudioValue.text = audioStrTime
                self.weeklyProgressView.lblVideoValue.text = videoSrtTime
                self.weeklyProgressView.videoProgress.progressValue  = videoFileProgreass
                self.weeklyProgressView.audioProgress.progressValue  = audioFileProgreass
                self.weeklyProgressView.lblsbValue.text = String(StopWatch(totalSeconds:listenSB).hours)+"h"
                self.weeklyProgressView.lblbgValue.text = String(StopWatch(totalSeconds:listenBG).hours)+"h"
                self.weeklyProgressView.lblvnsValue.text = String(StopWatch(totalSeconds:listenVNS).hours)+"h"
                self.weeklyProgressView.lblccValue.text = String(StopWatch(totalSeconds:listenCC).hours)+"h"
                self.weeklyProgressView.lblbhajansValue.text = String(StopWatch(totalSeconds:listenBhajans).hours)+"h"
            }else{
                print("monthlyProgressView")
                self.monthlyProgressView.lblAudioValue.text = audioStrTime
                self.monthlyProgressView.lblVideoValue.text = videoSrtTime
                self.monthlyProgressView.videoProgress.progressValue  = videoFileProgreass
                self.monthlyProgressView.audioProgress.progressValue  = audioFileProgreass
                self.monthlyProgressView.lblsbValue.text = String(StopWatch(totalSeconds:listenSB).hours)+"h"
                self.monthlyProgressView.lblbgValue.text = String(StopWatch(totalSeconds:listenBG).hours)+"h"
                self.monthlyProgressView.lblvnsValue.text = String(StopWatch(totalSeconds:listenVNS).hours)+"h"
                self.monthlyProgressView.lblccValue.text = String(StopWatch(totalSeconds:listenCC).hours)+"h"
                self.monthlyProgressView.lblbhajansValue.text = String(StopWatch(totalSeconds:listenBhajans).hours)+"h"
            }
        }else if customeView == self.totalRecordView{
            print("totalRecordView")
            let completLectures = GlobleDB.rawGloble.filter({$0.info?.isCompleted == true })
            self.totalRecordView.txtTotalheard.text = String(completLectures.count)
            self.totalRecordView.txtTotalLectures.text = String(GlobleDB.rawGloble.count)
            
        }else if customeView == self.lastWeekChart{
            print("lastWeekChart")
            CommonFunc.shared.switchAppLoader(value: false)
            var audioValue : [Double] = []
            var videoValue : [Double] = []
            var dayName : [String] = []
            for lDetail in oprationalListion{
                //SET DAY NAME
                let dName = String("\(lDetail.dateOfRecord!.day!) \(self.yearMonths[lDetail.dateOfRecord!.month!-1])")
                print(dName)
                dayName.append(dName)
                //AUDIO DETAIL SET
                
                let audioArray = lDetail.audioListen
                print(audioArray)
                let watch = StopWatch(totalSeconds:audioArray ?? 0)
                print("Y",watch.years) // Prints 1
                print("D",watch.days) // Prints 1
                print("H",watch.hours)
                print("M",watch.minutes)
                print("S",watch.seconds)// Prints 1
                //var  Avalue = Double("\(watch.hours).\(watch.minutes)")
                
                let aValue = watch.minutes>=10 ? Double("\(watch.hours).\(watch.minutes)") : Double("\(watch.hours).0\(watch.minutes)")
                audioValue.append(aValue ?? 0.0)
                
                
                //VIDEO BOCK
                let videoArray = lDetail.videoListen
                let vwatch = StopWatch(totalSeconds:videoArray ?? 0)
                print("Y",vwatch.years) // Prints 1
                print("D",vwatch.days) // Prints 1
                print("H",vwatch.hours) // Prints 1
                print("M",watch.minutes)
                print("S",vwatch.seconds)// Prints 1
                
                
                //let Vvalue = Double("\(vwatch.hours).\(vwatch.minutes)")?.roundTo(places: 2)
                let vValue = vwatch.minutes>=10 ? Double("\(vwatch.hours).\(vwatch.minutes)") : Double("\(vwatch.hours).0\(vwatch.minutes)")
                videoValue.append(vValue ?? 0.0)
                
                if aValue ?? 0.0 >= 1.0 || vValue ?? 0.0 >= 1.0{
                    isMinutesMode = false
                }
                
            }
            print(dayName)
            print(audioValue)
            print(videoValue)
            dayName = dayName.reversed()
            audioValue = audioValue.reversed()
            videoValue = videoValue.reversed()
            if isMinutesMode{
                audioValue = audioValue.map({$0 * 100})
                videoValue = videoValue.map({$0 * 100})
                print(dayName)
                print(audioValue)
                print(videoValue)
            }
            self.setGroupBarChart(audioVal: audioValue, videoVal: videoValue, unitName: dayName)
            
            
        }else if customeView == self.customView{
            
            let audioListion = oprationalListion.compactMap({$0.audioListen}).reduce(0) { $0 + $1 }
            let audioWatch = StopWatch(totalSeconds:audioListion)
            print(oprationalListion)
            print(oprationalListion.count)
            print("Y",audioWatch.years) // Prints 1
            print("D",audioWatch.days) // Prints 1
            print("H",audioWatch.hours)
            print("M",audioWatch.minutes)
            print("S",audioWatch.seconds)// Prints 1
            
            if audioWatch.hours > 0{
                self.customView.lblAudioValue.text = "\(audioWatch.hours)h"
            }else if audioWatch.minutes > 0{
                self.customView.lblAudioValue.text = "\(audioWatch.minutes)m"
            }else{
                self.customView.lblAudioValue.text = "\(audioWatch.seconds)s"
            }
            
            let videoListion = oprationalListion.compactMap({$0.videoListen}).reduce(0){ $0 + $1 }
            let videoWatch = StopWatch(totalSeconds:videoListion)
            print("Y",videoWatch.years) // Prints 1
            print("D",videoWatch.days) // Prints 1
            print("H",videoWatch.hours)
            print("M",videoWatch.minutes)
            print("S",videoWatch.seconds)// Prints 1
            if videoWatch.hours > 0{
                self.customView.lblVideoValue.text = "\(videoWatch.hours)h"
            }else if videoWatch.minutes > 0{
                self.customView.lblVideoValue.text = "\(videoWatch.minutes)m"
            }else{
                self.customView.lblVideoValue.text = "\(videoWatch.seconds)s"
            }
            
        }
    }
}







public class CustomPieValueFormatter: NSObject, IValueFormatter {
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        
        let number = modf(value)
        let hour = String(format: "%.0f", number.0)
        let minute = String(format: "%.0f", 60 * number.1)
        return "\(hour) hour \(minute) minute"
    }
}
