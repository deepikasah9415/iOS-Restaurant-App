import SwiftUI

struct SkeletonCuisineCard: View {
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                // Skeleton cuisine card background
                SkeletonRoundedRectangle(
                    width: 350,
                    height: 200,
                    cornerRadius: UIConstants.cornerRadiusExtraLarge
                )
                
                // Skeleton text for cuisine name
                SkeletonLine(width: 150, height: 40)
            }
            .frame(width: 350, height: 200)
        }
        .frame(width: 350, height: 200)
        .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
    }
}

struct SkeletonCuisineSection: View {
    var count: Int = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Skeleton for section title
            SkeletonLine(width: 200, height: 28)
                .padding(.leading)
            
            // Skeleton for cuisine cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<count, id: \.self) { _ in
                        SkeletonCuisineCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#if DEBUG
struct SkeletonCuisineCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SkeletonCuisineCard()
            SkeletonCuisineSection()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
