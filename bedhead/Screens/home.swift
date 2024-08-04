// Swipe Navigation between Alarm list and Friends gallery
import SwiftUI
import AVFoundation
// This struct handles the swiping navigation between the alarmList screen & friends view
struct Home: View {
    var body: some View {
        ZStack {
            Color(("background")).ignoresSafeArea()
            TabView {
                AlarmList()
                    .tabItem {
                        Label("Alarm List", systemImage: "star.fill") // Move these down
                    }
                    .tag(0)
                Friends()
                    .tabItem {
                        Label("Friends", systemImage: "person.2.fill")
                    }
                    .tag(1)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
    }
}

// eventually i want to make it so there is an active alarm spot, at the top. Which ever alarm is active, it gets moved to the top
// For now, I'll just make a list of alarms, with only one active alarm.
// TODO: put in order
// the main page for alarms
struct AlarmList: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @State private var showNewAlarm = false
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var path = NavigationPath()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack {
            HStack { // Top screen
                Button(action: { // Buttton that makes new alarm screen show up
                    showNewAlarm.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(Color("selected"))
                        .frame(width: 20, height: 20)
                }
                .padding()
                .offset(x: 168, y: -10)
                .sheet(isPresented: $showNewAlarm) {
                    AlarmScreen(viewModel: viewModel)
                }
            }
            Rectangle() // Dividing line
                .padding(.horizontal, 7.0)
                .padding(.bottom, -1)
                .frame(height: 1.0)
                .foregroundColor(.gray)
            
            ScrollView { // List of alarms
                Text("Other Alarms")
                    .font(.system(size: 35))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 150.0)
                    .padding(.bottom, -1)
                    .padding(.top, 12)
                    .foregroundColor(.black)
                Rectangle()
                    .padding(.horizontal, 18.0)
                    .frame(height: 2.0)
                    .foregroundColor(.gray)
                VStack(spacing: 0.0) {
                    // Iterates through each alarm, and creates a visual for them
                    ForEach(viewModel.alarms) { alarm in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(alarm.time, formatter: timeFormatter)")
                                    .font(.system(size: 35))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("textColor"))
                                    .bold()
                                Text(alarm.effectiveSound.name)
                                    .font(.caption)
                                    .padding(.leading, 4)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Toggle("", isOn: Binding<Bool>( // Toggle button for each alarm. Determines active alarm
                                get: { alarm.id == viewModel.activeAlarm?.id },
                                set: { isOn in
                                    if isOn {
                                        viewModel.activeAlarm = alarm
                                    } else {
                                        viewModel.activeAlarm = nil
                                    }
                                }
                            )).labelsHidden()
                        }
                        .padding()
                        .frame(width:375.0, height: 75.0)
                        .background(Color("background"))
                        .contextMenu {
                            Button(role: .destructive) { // Hold an alarm -> delete button show up
                                viewModel.removeAlarm(alarm: alarm)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }.padding([.leading, .bottom, .trailing]).background(Color("background"))
            }.background(Color("background"))
        }
    }
}


struct Friends: View {
    var body: some View {
        Text("Friends")
            .font(.largeTitle)
            .foregroundColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
