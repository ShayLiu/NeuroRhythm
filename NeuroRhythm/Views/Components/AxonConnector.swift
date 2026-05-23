import SwiftUI

struct AxonConnector: View {
    var active: Bool = true

    @State private var dotOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "D1D9E0").opacity(0.25))
                .frame(width: 2)

            Circle()
                .fill(Color(hex: "7DBCB5").opacity(active ? 0.7 : 0.2))
                .frame(width: 6, height: 6)
                .blur(radius: active ? 2 : 0)
                .offset(y: dotOffset)
        }
        .frame(width: 20)
        .onAppear {
            if active {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    dotOffset = -15
                }
            }
        }
    }
}
