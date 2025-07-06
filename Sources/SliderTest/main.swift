import SwiftTUI

struct SliderTestView: View {
    @State private var volume: Double = 0.5
    @State private var brightness: Double = 0.7
    @State private var speed: Double = 1.0
    @State private var temperature: Double = 20.0
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Slider Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Text("Audio Settings")
                    .bold()
                    .padding(.bottom)
                
                Slider(value: $volume, in: 0...1, label: "Volume")
                    .padding()
                
                Slider(value: $brightness, in: 0...1, label: "Brightness")
                    .padding()
                
                Slider(value: $speed, in: 0.5...2.0, label: "Playback Speed")
                    .padding()
            }
            .border()
            .padding()
            
            VStack(spacing: 2) {
                Text("Environment")
                    .bold()
                    .padding(.bottom)
                
                Slider(value: $temperature, in: -10...40, label: "Temperature")
                    .padding()
                
                Slider(value: $progress, in: 0...100, label: "Progress")
                    .padding()
            }
            .border()
            .padding()
            
            Text("Instructions:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            VStack {
                Text("• Tab: Move focus between sliders")
                Text("• ←/→: Adjust value")
                Text("• Home/End: Jump to min/max")
                Text("• ESC: Exit program")
            }
            .foregroundColor(.white)
            .padding()
            
            VStack(spacing: 1) {
                Text("Current Values:")
                    .bold()
                HStack {
                    Text("Volume: \(String(format: "%.2f", volume))")
                    Text("Brightness: \(String(format: "%.2f", brightness))")
                }
                HStack {
                    Text("Speed: \(String(format: "%.2f", speed))x")
                    Text("Temp: \(String(format: "%.1f", temperature))°C")
                }
            }
            .padding()
            .foregroundColor(.yellow)
        }
    }
}

SwiftTUI.run {
    SliderTestView()
}