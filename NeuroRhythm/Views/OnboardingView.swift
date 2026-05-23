import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    @Environment(NeuroRhythmViewModel.self) var viewModel
    @State private var step: OnboardingStep = .welcome
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    private let mintColor = Color(hex: "7DBCB5")

    enum OnboardingStep {
        case welcome
        case permissions
        case done
    }

    var body: some View {
        ZStack {
            NeuroDesign.bg.ignoresSafeArea()
            NeuralBackground()
                .opacity(0.5)
                .ignoresSafeArea()

            switch step {
            case .welcome:
                welcomeStep
            case .permissions:
                permissionsStep
            case .done:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: step)
    }

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

            NeuroRhythmLogo(size: 160)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
            }

            Spacer().frame(height: NeuroDesign.lg)

            Text("NeuroRhythm")
                .font(.system(size: 36, weight: .thin, design: .rounded))
                .tracking(2)
                .foregroundColor(NeuroDesign.textPrimary)

            Spacer().frame(height: NeuroDesign.sm)

            Text("三维神经节律引擎")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)

            Spacer().frame(height: NeuroDesign.sm)

            Text("基于脑科学的认知调度系统\n让每个任务在最佳神经窗口执行")
                .font(.system(size: 15, weight: .light, design: .rounded))
                .foregroundColor(NeuroDesign.textTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            Spacer()

            // Sign in with Apple
            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            }, onCompletion: { result in
                switch result {
                case .success(let auth):
                    handleAppleSignIn(auth)
                case .failure:
                    break
                }
            })
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
            .padding(.horizontal, NeuroDesign.xl)

            Spacer().frame(height: NeuroDesign.md)

            // Skip login
            Button {
                withAnimation { step = .permissions }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 16))
                    Text("跳过登录，直接体验")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .foregroundColor(mintColor)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: NeuroDesign.radiusMd)
                        .fill(mintColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: NeuroDesign.radiusMd)
                                .stroke(mintColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, NeuroDesign.xl)

            Spacer().frame(height: NeuroDesign.md)

            Text("Apple 登录可跨设备同步神经画像")
                .font(.system(size: 13, weight: .light, design: .rounded))
                .foregroundColor(NeuroDesign.textTertiary)

            Spacer().frame(height: NeuroDesign.xl)
        }
    }

    private var permissionsStep: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(mintColor)

            Spacer().frame(height: NeuroDesign.lg)

            Text("数据授权")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .tracking(1)
                .foregroundColor(NeuroDesign.textPrimary)

            Spacer().frame(height: NeuroDesign.sm)

            Text("所有数据仅在本地处理，不上传云端")
                .font(.system(size: 15, weight: .light, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)

            Spacer().frame(height: NeuroDesign.xl)

            VStack(spacing: NeuroDesign.md) {
                permissionCard(
                    icon: "heart.text.clipboard",
                    color: .red.opacity(0.8),
                    title: "HealthKit",
                    desc: "HRV · 心率 · 血氧 · 睡眠分期",
                    detail: "用于计算 NFI 神经疲劳指数"
                )
                permissionCard(
                    icon: "calendar.badge.clock",
                    color: mintColor,
                    title: "日历",
                    desc: "读取日程 · 推荐任务窗口",
                    detail: "智能避开会议，匹配认知高峰"
                )
            }
            .padding(.horizontal, NeuroDesign.xl)

            Spacer()

            Button {
                Task {
                    await viewModel.requestAllPermissions()
                    withAnimation { step = .done }
                    viewModel.completeLogin()
                }
            } label: {
                Text("授权并开始")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [mintColor, mintColor.opacity(0.8)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
                    .shadow(color: mintColor.opacity(0.3), radius: 12, y: 4)
            }
            .padding(.horizontal, NeuroDesign.xl)

            Spacer().frame(height: NeuroDesign.md)

            Button {
                withAnimation { step = .done }
                viewModel.completeLogin()
            } label: {
                Text("稍后在设置中授权")
                    .font(.system(size: 15, weight: .light, design: .rounded))
                    .foregroundColor(NeuroDesign.textTertiary)
            }

            Spacer().frame(height: NeuroDesign.xl)
        }
    }

    private func permissionCard(icon: String, color: Color, title: String, desc: String, detail: String) -> some View {
        HStack(spacing: NeuroDesign.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(NeuroDesign.textPrimary)
                Text(desc)
                    .font(NeuroDesign.neuroData(size: 14))
                    .foregroundColor(NeuroDesign.textSecondary)
                Text(detail)
                    .font(.system(size: 13, weight: .light, design: .rounded))
                    .foregroundColor(NeuroDesign.textTertiary)
            }
            Spacer()
        }
        .padding(NeuroDesign.md)
        .background(
            RoundedRectangle(cornerRadius: NeuroDesign.radiusMd)
                .fill(.white.opacity(0.5))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        )
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: mintColor.opacity(0.05), radius: 8, y: 2)
    }

    private func handleAppleSignIn(_ auth: ASAuthorization) {
        if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
            viewModel.appleUserID = credential.user
            if let name = credential.fullName {
                viewModel.userName = [name.givenName, name.familyName].compactMap { $0 }.joined(separator: " ")
            }
        }
        withAnimation { step = .permissions }
    }
}
