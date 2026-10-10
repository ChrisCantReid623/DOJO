import SwiftUI

struct ContentView: View {

    @StateObject private var healthKit = HealthKitManager()

    var body: some View {

        VStack(spacing: 24) {

            Image(systemName: "figure.martial.arts")
                .font(.system(size: 70))
                .foregroundStyle(.orange)

            Text("DOJO")
                .font(.largeTitle)
                .bold()

            Text("Your Personal Training Agent")
                .foregroundStyle(.secondary)

            Divider()

            Text("Today's Steps")
                .font(.headline)

            Text(healthKit.todaySteps.formatted())
                .font(.system(size: 48, weight: .bold))

            Text(healthKit.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Connect Apple Health") {
                healthKit.requestAuthorization()
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
