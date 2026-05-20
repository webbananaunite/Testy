import SwiftUI

public struct TYButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.all, 8.0)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: 1.0)
                .frame(width: 200, height: 50, alignment: .center)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

public struct TYTextFieldStyle: TextFieldStyle {
    public init() {}

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8.0)
            .padding(.vertical, 16.0)
            .background(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.red, lineWidth: 1.0))
    }
}

public struct TestySceneBackground: View {
    public init() {}

    public var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.11, blue: 0.22),
                Color(red: 0.12, green: 0.32, blue: 0.48),
                Color(red: 0.78, green: 0.88, blue: 0.94)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(Color.white.opacity(0.20))
                .frame(width: 280, height: 280)
                .blur(radius: 24)
                .offset(x: -70, y: -110)
        }
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.cyan.opacity(0.22))
                .frame(width: 340, height: 340)
                .blur(radius: 30)
                .offset(x: 70, y: 120)
        }
        .ignoresSafeArea()
    }
}

public struct TestyGlassButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 18)
            .background {
                Group {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular.tint(.white.opacity(0.18)).interactive(), in: .rect(cornerRadius: 20))
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

public struct TestyGlassTextFieldStyle: TextFieldStyle {
    public init() {}

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background {
                Group {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular.tint(.white.opacity(0.08)), in: .rect(cornerRadius: 18))
                    } else {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            }
    }
}

public struct TestyScreenModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        ZStack {
            TestySceneBackground()
            content
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

public struct TestyGlassCardModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .padding(18)
            .background {
                Group {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular.tint(.white.opacity(0.10)), in: .rect(cornerRadius: 28))
                    } else {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
    }
}

public extension View {
    func testyScreen() -> some View {
        modifier(TestyScreenModifier())
    }

    func testyGlassCard() -> some View {
        modifier(TestyGlassCardModifier())
    }
}
