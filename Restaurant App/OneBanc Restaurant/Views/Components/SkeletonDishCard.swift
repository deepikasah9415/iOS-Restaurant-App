import SwiftUI

struct SkeletonDishCard: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                // Skeleton image
                SkeletonRoundedRectangle(
                    width: .infinity,
                    height: 150,
                    cornerRadius: UIConstants.cornerRadiusLarge
                )
                .padding(.top, 8)
                
                // Skeleton dish name
                SkeletonLine(width: 150, height: 20)
                
                // Skeleton price and add to cart button
                HStack {
                    SkeletonLine(width: 60, height: 18)
                    
                    Spacer()
                    
                    SkeletonRoundedRectangle(
                        width: 90,
                        height: 32,
                        cornerRadius: UIConstants.cornerRadiusSmall
                    )
                }
                .padding(.bottom, 8)
            }
            .padding(UIConstants.paddingMedium)
            .background(Color.cardBackground)
            .cornerRadius(UIConstants.cornerRadiusLarge)
            .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: -UIConstants.shadowY)
            .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
        }
        .frame(width: 220)
        .padding(.vertical, 8)
    }
}

struct SkeletonDishSection: View {
    var count: Int = 4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Skeleton for section title
            SkeletonLine(width: 200, height: 24)
                .padding(.leading)
            
            // Skeleton for dish cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<count, id: \.self) { _ in
                        SkeletonDishCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#if DEBUG
struct SkeletonDishCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SkeletonDishCard()
            SkeletonDishSection()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
