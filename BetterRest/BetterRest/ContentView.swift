import CoreML

import SwiftUI

struct SleepGoalView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .font(.largeTitle)
            .fontWeight(.bold)
        
    }
}
extension View {
    func sleepGoal() -> some View {
        modifier(SleepGoalView())
    }
}
struct ContentView: View {
    @State private var wakeUp = dayDefault
    @State private var sleepAmoun = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showGoal = ""
    static var dayDefault : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time",selection: $wakeUp,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section{
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmoun.formatted()) hours",value: $sleepAmoun, in: 4...12,step: 0.25)
                        .padding(.horizontal)
                }

                Section{
                    Text("Dayli cofee intake")
                        .font(.headline)
                    
                    Picker("How many cups of coffee",selection: $coffeeAmount) {
                        ForEach(0...20,id: \.self){
                            Text("\($0) cup")
                        }
                    }
                    .onChange(of: coffeeAmount){ _ in
                        calcutateBedTime()
                    }
                    
                    .pickerStyle(.menu)
                }
                Section{
                    Text("Your ideal bedtime is: ")
                    Text(showGoal)
                        .sleepGoal()
                        .foregroundStyle(.green)
                    
                }

            }
            .navigationTitle("BetterRest")
            
            
        }
    }
    func calcutateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let componentes = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (componentes.hour ?? 0) * 60 * 60
            let minute = (componentes.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmoun, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            showGoal = alertMessage
            
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problema calculating your sleep time. Try again later."
        }
        showAlert = true
    }
}
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
