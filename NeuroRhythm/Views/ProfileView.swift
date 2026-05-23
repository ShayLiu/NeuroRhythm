import SwiftUI

struct ProfileView: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel

    @State private var window1Hour: Int = 9
    @State private var window1Min: Int = 30
    @State private var window2Hour: Int = 16
    @State private var window2Min: Int = 0
    @State private var showSignOutAlert = false
    @State private var showPrivacy = false

    var body: some View {
        @Bindable var vm = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: NeuroDesign.lg) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("我的")
                            .font(.system(size: 28, weight: .thin))
                            .tracking(1)
                            .foregroundColor(NeuroDesign.textPrimary)
                        if let name = viewModel.userName, !name.isEmpty {
                            Text(name)
                                .font(NeuroDesign.neuroData(size: 14))
                                .foregroundColor(NeuroDesign.textSecondary)
                        }
                    }
                    Spacer()
                    Button { showSignOutAlert = true } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18))
                            .foregroundColor(NeuroDesign.textTertiary)
                    }
                }
                .padding(.top, NeuroDesign.lg)

                // Peak Windows
                VStack(alignment: .leading, spacing: NeuroDesign.md) {
                    sectionTitle("认知高峰窗口")
                    Text("设定你的两个专注高峰时段")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(NeuroDesign.textTertiary)

                    Spacer().frame(height: NeuroDesign.xs)

                    windowPicker(label: "第一窗口", icon: "sun.max.fill", color: NeuroDesign.accentAmber, hourBinding: $window1Hour, minBinding: $window1Min, hourRange: 5...12)

                    windowPicker(label: "第二窗口", icon: "moon.stars.fill", color: NeuroDesign.accentMist, hourBinding: $window2Hour, minBinding: $window2Min, hourRange: 13...20)

                    Spacer().frame(height: NeuroDesign.xs)

                    Button {
                        viewModel.profile.peakWindow1Start = DateComponents(hour: window1Hour, minute: window1Min)
                        viewModel.profile.peakWindow2Start = DateComponents(hour: window2Hour, minute: window2Min)
                        viewModel.evaluateTasks()
                    } label: {
                        Text("保存设置")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(NeuroDesign.accentSage)
                            .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm))
                    }
                }
                .padding(NeuroDesign.lg)
                .background(NeuroDesign.card)
                .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusLg))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                // Rhythm params
                VStack(alignment: .leading, spacing: NeuroDesign.md) {
                    sectionTitle("节律参数")
                    profileRow("超日节律周期", value: "\(Int(viewModel.profile.ultradianCycleMinutes)) min")
                    profileRow("最佳睡眠时长", value: "\(String(format: "%.1f", viewModel.profile.optimalSleepHours)) h")
                    profileRow("FPN 日预算", value: "\(Int(viewModel.profile.dailyFPNBudgetMinutes)) min")
                }
                .padding(NeuroDesign.lg)
                .background(NeuroDesign.card)
                .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusLg))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                // Health Data
                if let state = viewModel.currentState {
                    VStack(alignment: .leading, spacing: NeuroDesign.md) {
                        sectionTitle("今日健康数据")
                        profileRow("HRV RMSSD", value: state.hrvRMSSD.map { "\(Int($0)) ms" } ?? "—")
                        profileRow("静息心率", value: state.restingHR.map { "\(Int($0)) bpm" } ?? "—")
                        profileRow("血氧", value: state.spo2.map { "\(Int($0))%" } ?? "—")
                        profileRow("深睡", value: state.deepSleepHours.map { "\(String(format: "%.1f", $0)) h" } ?? "—")
                        profileRow("REM", value: state.remSleepHours.map { "\(String(format: "%.1f", $0)) h" } ?? "—")
                    }
                    .padding(NeuroDesign.lg)
                    .background(NeuroDesign.card)
                    .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusLg))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                }

                // Brain Region Capacities
                if let state = viewModel.currentState {
                    VStack(alignment: .leading, spacing: NeuroDesign.md) {
                        sectionTitle("脑区容量")
                        capacityRow(.fpn, value: state.fpnCapacity)
                        capacityRow(.dmn, value: state.dmnCapacity)
                        capacityRow(.memory, value: state.memoryCapacity)
                        capacityRow(.dan, value: state.danCapacity)
                    }
                    .padding(NeuroDesign.lg)
                    .background(NeuroDesign.card)
                    .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusLg))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                }

                // Privacy
                Button { showPrivacy = true } label: {
                    HStack(spacing: NeuroDesign.sm) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(NeuroDesign.accentSage)
                        Text("隐私与数据")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(NeuroDesign.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11))
                            .foregroundColor(NeuroDesign.textTertiary)
                    }
                    .padding(NeuroDesign.md)
                    .background(NeuroDesign.card)
                    .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
                }

                Spacer().frame(height: NeuroDesign.xl)
            }
            .padding(.horizontal, NeuroDesign.lg)
            .padding(.bottom, NeuroDesign.xxl)
        }
        .background(NeuroDesign.bg)
        .onAppear {
            window1Hour = viewModel.profile.peakWindow1Start.hour ?? 9
            window1Min = viewModel.profile.peakWindow1Start.minute ?? 30
            window2Hour = viewModel.profile.peakWindow2Start.hour ?? 16
            window2Min = viewModel.profile.peakWindow2Start.minute ?? 0
        }
        .alert("退出登录", isPresented: $showSignOutAlert) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) { viewModel.signOut() }
        } message: {
            Text("退出后本地数据将保留，重新登录可恢复。")
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacySheetView()
        }
    }

    private func windowPicker(label: String, icon: String, color: Color, hourBinding: Binding<Int>, minBinding: Binding<Int>, hourRange: ClosedRange<Int>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(NeuroDesign.textSecondary)
            Spacer()
            Picker("", selection: hourBinding) {
                ForEach(hourRange, id: \.self) { h in
                    Text("\(h)").tag(h)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 56)
            Text(":")
                .foregroundColor(NeuroDesign.textPrimary)
            Picker("", selection: minBinding) {
                ForEach([0, 15, 30, 45], id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 56)
        }
    }

    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(NeuroDesign.textPrimary)
    }

    @ViewBuilder
    private func profileRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(NeuroDesign.textSecondary)
            Spacer()
            Text(value)
                .font(NeuroDesign.neuroData(size: 16))
                .foregroundColor(NeuroDesign.textPrimary)
        }
    }

    @ViewBuilder
    private func capacityRow(_ region: BrainRegion, value: Double) -> some View {
        HStack {
            RegionTag(region: region)
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(NeuroDesign.textTertiary.opacity(0.3))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(NeuroDesign.regionForeground(region))
                        .frame(width: geo.size.width * min(value / 100.0, 1.0), height: 8)
                }
            }
            .frame(width: 100, height: 8)
            Text("\(Int(value))%")
                .font(NeuroDesign.neuroData(size: 15))
                .foregroundColor(NeuroDesign.textPrimary)
                .frame(width: 40, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func privacyRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: NeuroDesign.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(NeuroDesign.accentSage)
                .frame(width: 24, alignment: .center)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(NeuroDesign.textPrimary)
                Text(desc)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(NeuroDesign.textSecondary)
                    .lineSpacing(3)
            }
        }
    }
}

struct PrivacySheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NeuroDesign.lg) {
                    privacyItem(icon: "lock.shield.fill", title: "数据存储", desc: "所有健康数据仅存储在你的设备本地，不会上传至任何服务器。")
                    privacyItem(icon: "heart.text.clipboard", title: "HealthKit", desc: "读取心率变异性、睡眠分析、血氧数据用于计算神经疲劳指数。数据不出设备，不与第三方共享。")
                    privacyItem(icon: "calendar", title: "日历", desc: "读取日历事件用于智能任务推荐。写入的排程事件仅存储在你的 iCloud 日历中。")
                    privacyItem(icon: "person.badge.key.fill", title: "Apple 登录", desc: "仅获取你授权的姓名和邮箱，用于本地显示。不收集、不存储、不上传任何账号信息。")
                    privacyItem(icon: "xmark.shield.fill", title: "无追踪", desc: "本 App 不包含任何广告 SDK、分析 SDK 或用户行为追踪。你的使用数据完全私密。")

                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                            Text("管理 App 权限")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.accentSage)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(NeuroDesign.accentSage.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm))
                    }
                }
                .padding(NeuroDesign.lg)
            }
            .background(NeuroDesign.bg)
            .navigationTitle("隐私与数据")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(NeuroDesign.accentSage)
                }
            }
        }
    }

    private func privacyItem(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: NeuroDesign.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(NeuroDesign.accentSage)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(NeuroDesign.textPrimary)
                Text(desc)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(NeuroDesign.textSecondary)
                    .lineSpacing(3)
            }
        }
    }
}
