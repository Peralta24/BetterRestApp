import CoreML

import SwiftUI


struct ContentView: View {
    @State private var wakeUp = dayDefault
    @State private var sleepAmoun = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var dayDefault : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack{
            Form{
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time",selection: $wakeUp,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing : 20){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmoun.formatted()) hours",value: $sleepAmoun, in: 4...12,step: 0.25)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing : 0){
                    Text("Dayli cofee intake")
                        .font(.headline)
                    
                    Stepper("^[\(coffeeAmount) cup](inflect:true)",value: $coffeeAmount,in: 0...20)
                        .padding(.horizontal)
                }

            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate",action: calcutateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("Ok"){
                    
                }
            }message: {
                Text(alertMessage)
            }
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
