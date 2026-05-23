import SwiftUI

struct RegionTag: View {
    let region: BrainRegion

    var body: some View {
        Text(region.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, NeuroDesign.sm)
            .padding(.vertical, NeuroDesign.xs)
            .background(NeuroDesign.regionBackground(region))
            .foregroundColor(NeuroDesign.regionForeground(region))
            .clipShape(Capsule())
    }
}
