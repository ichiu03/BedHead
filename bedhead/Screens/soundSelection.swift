// List of sounds to play

import SwiftUI

struct SoundSelectionView: View {
    @ObservedObject var soundViewModel: SoundViewModel
    @Binding var selectedSound: AlarmSound?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("background").ignoresSafeArea()
                List(soundViewModel.sounds) { sound in
                    HStack {
                        Text(sound.name)
                            .font(.system(size: 17))
                            .foregroundColor(Color("textColor"))
                        Spacer()
                        if selectedSound?.id == sound.id {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSound = sound
                        presentationMode.wrappedValue.dismiss()
                    }.listRowBackground(Color("background"))
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Alarm sound")
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Color("selected"))
                })
            }
        }
    }
}

struct SoundSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        // Use a simple constant binding for the preview
        SoundSelectionView(
            soundViewModel: SoundViewModel(),
            selectedSound: .constant(AlarmSound.defaultSound)
        )
        .previewLayout(.sizeThatFits)
        .background(Color("background")) // Add a background color for preview
    }
}


