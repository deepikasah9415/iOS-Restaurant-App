import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var activeIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showAllTopDishes = false
    
    // Timer for auto-scrolling cuisines
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: UIConstants.paddingLarge) {
                    // Header with language selector
                    HStack {
                        Text(viewModel.selectedLanguage.homeTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primaryText)
                        
                        Spacer()
                        
                        // Language toggle button
                        Button(action: {
                            viewModel.toggleLanguage()
                        }) {
                            Text(viewModel.selectedLanguage == .english ? "हिंदी" : "ENG")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, UIConstants.paddingSmall)
                                .padding(.vertical, 5)
                                .background(Color.accentGreen)
                                .cornerRadius(UIConstants.cornerRadiusSmall)
                        }
                    }
                    .padding(.horizontal, UIConstants.paddingStandard)
                    
                    // Cuisine Cards Carousel
                    cuisineCarousel
                        .padding(.bottom, UIConstants.paddingStandard)
                    
                    // Top Dishes Section
                    topDishesSection
                    
                    // Previous Orders Section
                    previousOrdersSection
                    
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color.pageBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CartView(viewModel: viewModel)) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.system(size: 22))
                                .foregroundColor(Color.primaryGreen)
                            
                            if !viewModel.cart.items.isEmpty {
                                Text("\(viewModel.cart.items.count)")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color.actionNotification)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                        .padding(.trailing, 8)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Cuisine Carousel
    private var cuisineCarousel: some View {
        VStack(spacing: UIConstants.paddingStandard) {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width - 40 // Full width with padding

                Group {
                    if viewModel.isLoading {
                        // Show skeleton UI while loading
                        SkeletonCuisineCard()
                            .frame(width: geometry.size.width, height: 200)
                    } else {
                        // Show actual content when loaded
                        ScrollViewReader { scrollViewProxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(Array(viewModel.cuisines.enumerated()), id: \.element.id) { index, cuisine in
                                        NavigationLink(destination: CuisineDetailView(cuisine: cuisine, homeViewModel: viewModel)) {
                                            CuisineCardView(cuisine: cuisine)
                                                .frame(width: cardWidth)
                                        }
                                        .id(cuisine.id)
                                    }
                                }
                                .background(
                                    GeometryReader { geometryProxy -> Color in
                                        let offset = -geometryProxy.frame(in: .named("cuisineScrollView")).origin.x
                                        let newIndex = Int((offset + cardWidth / 2) / cardWidth)
                                        DispatchQueue.main.async {
                                            if activeIndex != newIndex && newIndex >= 0 && newIndex < viewModel.cuisines.count {
                                                activeIndex = newIndex
                                            }
                                        }
                                        return Color.clear
                                    }
                                )
                            }
                            .coordinateSpace(name: "cuisineScrollView")
                            .frame(width: geometry.size.width, height: 200)
                            .contentShape(Rectangle())
                            .onReceive(timer) { _ in
                                if !viewModel.isLoading && !viewModel.cuisines.isEmpty {
                                    withAnimation(.spring()) {
                                        activeIndex = (activeIndex + 1) % viewModel.cuisines.count
                                        if activeIndex < viewModel.cuisines.count {
                                            let targetId = viewModel.cuisines[activeIndex].id
                                            scrollViewProxy.scrollTo(targetId, anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 200)
            
            // Pagination dots
            HStack(spacing: 8) {
                if viewModel.isLoading {
                    ForEach(0..<11, id: \.self) { _ in
                        Circle()
                            .fill(Color.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                } else {
                    ForEach(0..<viewModel.cuisines.count, id: \.self) { index in
                        if activeIndex == index {
                            Capsule()
                                .fill(Color.primaryGreen)
                                .frame(width: 24, height: 8)
                        } else {
                            Circle()
                                .fill(Color.secondaryText.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .animation(.spring(), value: activeIndex)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, UIConstants.paddingStandard)
        }
    }
    
    // MARK: - Top Dishes Section
    private var topDishesSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.paddingLarge) {
            HStack {
                Text(viewModel.selectedLanguage.topDishesTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button(action: { showAllTopDishes = true }) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primaryGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGreen)
                        .cornerRadius(8)
                }
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 16)
            
            if viewModel.isLoading {
                // Show skeleton UI while loading
                SkeletonDishSection(count: 3)
            } else {
                // Show actual content when loaded
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(viewModel.topDishes) { dish in
                            DishCard(
                                dish: dish,
                                viewModel: viewModel
                            )
                            .frame(width: 220)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(
            NavigationLink(destination: AllTopDishesView(dishes: viewModel.topDishes, viewModel: viewModel), isActive: $showAllTopDishes) { EmptyView() }
                .hidden()
        )
    }
    
    // MARK: - Previous Orders Section
    private var previousOrdersSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.paddingStandard) {
            HStack {
                Text(viewModel.selectedLanguage.previousOrdersTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText)
                
                Spacer()
                
                // View all orders button
                NavigationLink(destination: OrderHistoryView(homeViewModel: viewModel)) {
                    Text("View All")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primaryGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGreen)
                        .cornerRadius(8)
                }
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, UIConstants.paddingStandard)
            
            if viewModel.isLoading {
                // Skeleton loading UI for orders section
                HStack(spacing: UIConstants.paddingStandard) {
                    ForEach(0..<2, id: \.self) { _ in
                        SkeletonRoundedRectangle(width: 240, height: 120, cornerRadius: UIConstants.cornerRadiusLarge)
                    }
                }
                .padding(.horizontal, UIConstants.paddingStandard)
            } else if viewModel.orderHistory.isEmpty {
                // No orders state
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("No previous orders")
                            .font(.headline)
                        Text("Your order history will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 120)
                    .padding()
                    Spacer()
                }
            } else {
                // Actual orders data
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UIConstants.paddingStandard) {
                        ForEach(viewModel.orderHistory.prefix(5)) { orderRecord in
                            OrderHistoryCard(order: orderRecord)
                                .frame(width: 240)
                        }
                    }
                    .padding(.horizontal, UIConstants.paddingStandard)
                }
            }
        }
        .padding(.top, UIConstants.paddingStandard)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif 
