//
//  ContentView.swift
//  AnthapMusicPlayer
//
//  Created by 张赛东手机15674119605 on 2025/4/15.
//

import SwiftUI

/// 音乐播放器主视图
/// 实现了一个完整的音乐播放界面，具有以下特点：
/// - 专辑封面展示，支持旋转动画效果
/// - 音乐播放控制，包括播放/暂停、上一首、下一首
/// - 自定义进度条，支持拖动调节进度
/// - 底部功能按钮，支持播放列表、下载、分享等操作
/// - 支持iPad和iPhone不同设备的自适应布局
struct ContentView: View {
    // MARK: - Properties
    
    /// 音乐播放器的视图模型
    /// 负责处理音频播放状态、进度控制等核心功能
    @StateObject private var viewModel = MusicPlayerViewModel()
    
    /// 专辑封面的旋转角度
    /// 用于实现唱片机旋转动画效果
    @State private var rotationDegree: Double = 0
    
    // MARK: - Body
    
    /// 主视图布局
    /// 使用ZStack实现背景和内容的叠加效果
    /// 通过GeometryReader实现自适应布局
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    titleSection
                    Spacer()
                    albumCoverSection(geometry: geometry)
                    Spacer()
                    musicInfoSection
                    progressSection
                    playControlSection
                    bottomControlSection(geometry: geometry)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Title Section
extension ContentView {
    /// 标题区域视图
    /// 显示"Producer"标题文本
    /// 根据设备类型自适应字体大小和间距
    private var titleSection: some View {
        Text("Producer")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(Color(#colorLiteral(red: 0.7, green: 0.75, blue: 0.8, alpha: 1)))
            .padding(.top, getSafeAreaTopInset() + 20)
    }
    
    /// 获取顶部安全区域高度
    /// 用于确保视图在不同设备上都有正确的顶部间距
    private func getSafeAreaTopInset() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top
        }
        return 20
    }
}

// MARK: - Album Cover Section
extension ContentView {
    /// 专辑封面区域视图
    /// - Parameter geometry: 父视图的几何信息，用于计算封面大小
    /// - Returns: 包含专辑封面和旋转动画的视图
    private func albumCoverSection(geometry: GeometryProxy) -> some View {
        ZStack {
            // 外层装饰圆环
            Circle()
                .fill(Color(#colorLiteral(red: 0.2, green: 0.25, blue: 0.3, alpha: 1)))
                .frame(width: min(geometry.size.width * 0.85, geometry.size.height * 0.42))
            
            // 内层装饰圆环
            Circle()
                .fill(Color.black.opacity(0.8))
                .frame(width: min(geometry.size.width * 0.75, geometry.size.height * 0.37))
            
            // 专辑封面图片
            if let image = UIImage(named: "CD") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: min(geometry.size.width * 0.7, geometry.size.height * 0.35))
                    .rotationEffect(Angle(degrees: rotationDegree))
                    // 监听播放状态变化，控制旋转动画
                    .onChange(of: viewModel.isPlaying) { oldValue, newValue in
                        handlePlayStateChange(isPlaying: newValue)
                    }
            }
        }
    }
    
    /// 处理播放状态变化时的动画效果
    /// - Parameter isPlaying: 当前是否正在播放
    private func handlePlayStateChange(isPlaying: Bool) {
        if isPlaying {
            // 播放时添加持续旋转动画
            // 使用线性动画确保旋转速度均匀
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationDegree += 360
            }
        } else {
            // 暂停时平滑停止在当前位置
            withAnimation(.linear(duration: 0.5)) {
                // 使用取余操作防止角度值过大
                rotationDegree = rotationDegree.truncatingRemainder(dividingBy: 360)
            }
        }
    }
}

// MARK: - Music Info Section
extension ContentView {
    /// 音乐信息区域视图
    /// 显示当前播放音乐的详细信息，包括：
    /// - 歌曲标题：使用大号粗体字显示
    /// - 作者信息：使用较小字号显示
    /// - 收藏按钮：右侧可点击的心形图标
    /// 布局特点：
    /// - 使用HStack水平布局，左侧信息右侧按钮
    /// - 文本信息使用VStack垂直布局
    /// - iPad和iPhone采用不同的字号和间距
    private var musicInfoSection: some View {
        // 水平布局：左侧文本信息，右侧收藏按钮
        HStack(alignment: .center) {
            // 垂直布局：上方歌曲名称，下方作者信息
            VStack(alignment: .leading, spacing: 8) {
                // 歌曲标题 - 使用较大字号突出显示
                Text("Test Music")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 28, weight: .semibold))
                    .foregroundColor(.white)
                
                // 作者名称 - 使用较小字号和灰色
                Text("Producer")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 17))
                    .foregroundColor(Color(#colorLiteral(red: 0.6, green: 0.65, blue: 0.7, alpha: 1)))
            }
            
            Spacer()
            
            // 收藏按钮 - 使用可点击的图标按钮
            Button(action: {}) {
                Image("love")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    // iPad上使用更大的图标尺寸
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24, 
                           height: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24)
                    // 使用统一的图标颜色
                    .foregroundColor(Color(#colorLiteral(red: 0.6, green: 0.65, blue: 0.7, alpha: 1)))
                    // iPad上增加右侧间距
                    .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 0)
            }
            // 微调按钮垂直位置，使其与文本对齐
            .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? -8 : -6)
        }
        // 设置整体水平内边距，iPad上使用更大的间距
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 64 : 24)
    }
}

// MARK: - Progress Section
extension ContentView {
    /// 进度控制区域视图
    /// 实现音频播放进度的显示和控制功能，包括：
    /// - 自定义进度滑动条：支持拖动调节播放进度
    /// - 时间显示：当前播放时间和总时长
    /// 布局特点：
    /// - 使用VStack垂直布局组织进度条和时间显示
    /// - 时间显示采用两端对齐的布局方式
    /// - iPad和iPhone采用不同的间距和字号
    private var progressSection: some View {
        // 垂直布局：上方进度条，下方时间显示
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2) {  // iPad和iPhone使用不同的垂直间距
            // 自定义进度滑动条
            // 通过Binding与视图模型进行双向绑定
            // 实现进度更新和拖动调节功能
            CustomSlider(
                value: Binding(
                    get: { viewModel.currentTime },  // 获取当前播放时间
                    set: { viewModel.seek(to: $0) }  // 设置新的播放时间
                ),
                range: 0...viewModel.duration  // 进度范围：从0到音频总时长
            )
            
            // 时间显示部分
            // 使用HStack实现两端对齐
            HStack {
                // 当前播放时间
                // 左对齐，显示已播放时长
                Text(viewModel.formatTime(viewModel.currentTime))
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 12))  // iPad上使用更大字号
                    .foregroundColor(Color(#colorLiteral(red: 0.6, green: 0.65, blue: 0.7, alpha: 1)))  // 使用统一的灰色调
                
                Spacer()  // 用于推开两端的时间显示
                
                // 总时长显示
                // 右对齐，显示音频总时长
                Text(viewModel.formatTime(viewModel.duration))
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 12))  // iPad上使用更大字号
                    .foregroundColor(Color(#colorLiteral(red: 0.6, green: 0.65, blue: 0.7, alpha: 1)))  // 使用统一的灰色调
            }
        }
        // 设置整体水平内边距
        // iPad上使用更大的边距以获得更好的视觉效果
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 64 : 24)
    }
}

// MARK: - Play Control Section
extension ContentView {
    /// 播放控制区域视图
    /// 包含上一首、播放/暂停、下一首按钮
    private var playControlSection: some View {
        HStack(spacing: 80) {
            Button(action: {}) {
                Image("last")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
            
            Button(action: { viewModel.togglePlayPause() }) {
                Image(viewModel.isPlaying ? "pause" : "play")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 65, height: 65)
            }
            
            Button(action: {}) {
                Image("next")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8)
    }
}

// MARK: - Bottom Control Section
extension ContentView {
    /// 底部功能区域视图
    /// - Parameter geometry: 父视图的几何信息，用于计算安全区域
    /// - Returns: 包含播放列表、下载、分享按钮的视图
    private func bottomControlSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: 80) {
            createBottomButton(imageName: "list")
            createBottomButton(imageName: "download")
            createBottomButton(imageName: "share")
        }
        .padding(.bottom, geometry.safeAreaInsets.bottom + (UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8))
    }
    
    /// 创建底部功能按钮
    /// - Parameter imageName: 按钮图标的资源名称
    /// - Returns: 统一样式的功能按钮视图
    private func createBottomButton(imageName: String) -> some View {
        Button(action: {}) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24, 
                       height: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24)
                .foregroundColor(Color(#colorLiteral(red: 0.6, green: 0.65, blue: 0.7, alpha: 1)))
        }
    }
}

// MARK: - Background
extension ContentView {
    /// 背景渐变视图
    /// 使用深色渐变效果创建沉浸式体验
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(#colorLiteral(red: 0.15, green: 0.17, blue: 0.20, alpha: 1)),
                Color(#colorLiteral(red: 0.10, green: 0.12, blue: 0.15, alpha: 1))
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Preview Provider

/// 预览提供者
/// 用于在Xcode预览画布中显示视图
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
