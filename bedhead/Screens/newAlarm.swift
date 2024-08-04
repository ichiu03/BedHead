// New alarm screen. Reached through the home screen/alarm list
import SwiftUI

struct AlarmScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AlarmViewModel
    @StateObject private var soundViewModel = SoundViewModel()
    @State private var showSounds = false
    @State private var alarmTime = Date()
    @State private var selectedSound: AlarmSound?

    var body: some View {
        NavigationView {
            ZStack {
                Color("background") // Background
                    .ignoresSafeArea()
                VStack {
                    // Text at top (subject to change)
                    Text("Set the time to share your Bed Head!")
                        .font(.largeTitle)
                        .foregroundColor(Color("textColor"))
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 35)
                    Spacer()
                    ZStack {
                        Rectangle() // dividing line
                            .fill(Color(.lightGray))
                            .frame(width: 325, height: 150)
                            .cornerRadius(20)
                        // Time display to create the alarm
                        DatePicker("Alarm Time", selection: $alarmTime, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle()) // Wheel picker style
                            .frame(height: 100)
                            .clipped()
                            .scaleEffect(x: 1.25, y: 1.25, anchor: .center)
                            .padding(.top, 40)
                            .padding(.bottom, 40)
                    }
                    Spacer()
                    // Alarm sound button, takes user to a list of available sounds
                    Button {
                        showSounds.toggle()
                    } label: {
                        Text("Select Alarm Sound")
                            .font(.system(size: 20))
                            .fontWeight(.heavy)
                            .foregroundColor(Color("selected"))
                            .bold()
                    }
                    .sheet(isPresented: $showSounds) {
                        SoundSelectionView(soundViewModel: soundViewModel, selectedSound: $selectedSound)
                    }
                    // New alarm button
                    Button(action: {
                        let newAlarm = Alarm(time: alarmTime, isEnabled: false, sound: selectedSound ?? AlarmSound.defaultSound)
                        viewModel.addAlarm(alarm: newAlarm)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Alarm")
                            .padding()
                            .background(Color("selected"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    Spacer()
                    .padding()
                    .onAppear {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("Error requesting authorization: \(error)")
                                }
                            }
                        }
                }
            }.navigationBarItems(leading: Button(action: { // Back arrow button
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.backward")
                    .foregroundColor(Color("selected"))
            })
        }
    }
}

struct AlarmScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlarmScreen()
    }
}
