//
//  ContentView.swift
//  BetterRest
//
//  Created by Lindsey Kartvedt on 7/22/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 10
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var wakeUp = defaultWakeTime
    @State private var sleepTimeText = ""
    
    var body: some View {
        NavigationView {
                Form {
                    Section(header: Text("Wake Up Time")) {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                    }
                    
                    Section(header: Text("Desired amount of sleep")){
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in:4...12, step: 0.25)
                    }
                    
                    Section(header: Text("Coffee consumed today")){
                        Stepper(coffeeAmount == 1 ? "\(coffeeAmount) cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 0...20)
                    }
                    HStack {
                        Spacer()
                        Text("Recommended Bedtime: \(sleepTimeText)").font(.headline)
                        Spacer()
                    }
                    .padding()
                }
                
            .navigationTitle("BetterRest")
            .onChange(of: wakeUp) { _ in calculateBedtime() }
            .onChange(of: sleepAmount) { _ in calculateBedtime() }
            .onChange(of: coffeeAmount) { _ in calculateBedtime() }
            .onAppear { calculateBedtime() }
        }
    }
    
    func calculateBedtime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60 * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            sleepTimeText = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            sleepTimeText = "Error calculating bedtime."
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
