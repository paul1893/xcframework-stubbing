import SwiftUI
import MyFramework

struct ContentView: View {
    var body: some View {
        Text(MySuperApi.amazingResult)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
