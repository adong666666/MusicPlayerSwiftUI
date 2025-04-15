import Foundation
import AVFoundation

/// 音乐播放器视图模型
/// 负责管理音频播放状态、进度控制和时间格式化
/// 使用 AVAudioPlayer 实现音频播放功能
class MusicPlayerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 当前是否正在播放
    /// 用于控制播放/暂停状态和UI更新
    @Published var isPlaying: Bool = false
    
    /// 当前播放时间（秒）
    /// 实时更新，用于更新进度条和时间显示
    @Published var currentTime: TimeInterval = 0
    
    /// 音频总时长（秒）
    /// 用于设置进度条范围和显示总时长
    @Published var duration: TimeInterval = 0
    
    // MARK: - Private Properties
    
    /// 音频播放器实例
    /// 负责实际的音频播放控制
    private var player: AVAudioPlayer?
    
    /// 计时器，用于更新播放进度
    /// 每0.1秒更新一次当前播放时间
    private var timer: Timer?
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// 设置音频播放器和相关属性
    init() {
        setupAudioPlayer()
    }
    
    // MARK: - Deinitialization
    
    /// 析构方法
    /// 清理资源，停止计时器
    deinit {
        cleanupResources()
    }
}

// MARK: - Audio Setup & Cleanup
extension MusicPlayerViewModel {
    /// 设置音频播放器
    /// 加载音频文件并初始化播放器
    private func setupAudioPlayer() {
        // 获取音频文件路径
        guard let path = Bundle.main.path(forResource: "Test Music", ofType: "mp3") else {
            print("错误：无法找到音频文件")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            // 初始化音频播放器
            player = try AVAudioPlayer(contentsOf: url)
            // 设置音频总时长
            duration = player?.duration ?? 0
        } catch {
            print("错误：音频播放器初始化失败: \(error)")
        }
    }
    
    /// 清理资源
    /// 停止计时器和播放器
    private func cleanupResources() {
        // 停止计时器
        timer?.invalidate()
        timer = nil
        // 停止播放
        player?.stop()
        player = nil
    }
}

// MARK: - Playback Control
extension MusicPlayerViewModel {
    /// 切换播放/暂停状态
    /// 控制音频的播放和暂停，同时更新UI状态
    func togglePlayPause() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
        // 更新播放状态
        isPlaying.toggle()
    }
    
    /// 开始播放
    private func startPlayback() {
        player?.play()
        setupTimer()
    }
    
    /// 暂停播放
    private func pausePlayback() {
        player?.pause()
        stopTimer()
    }
    
    /// 跳转到指定时间点
    /// - Parameter time: 目标时间点（秒）
    func seek(to time: TimeInterval) {
        // 设置播放器的当前时间
        player?.currentTime = time
        // 更新UI显示的当前时间
        currentTime = time
    }
}

// MARK: - Timer Management
extension MusicPlayerViewModel {
    /// 设置进度更新计时器
    /// 创建一个定时器来更新播放进度
    private func setupTimer() {
        // 创建一个每0.1秒触发一次的计时器
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // 更新当前播放时间
            self.currentTime = self.player?.currentTime ?? 0
        }
    }
    
    /// 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Time Formatting
extension MusicPlayerViewModel {
    /// 格式化时间为字符串
    /// - Parameter time: 要格式化的时间（秒）
    /// - Returns: 格式化后的时间字符串，格式为 "mm:ss"
    func formatTime(_ time: TimeInterval) -> String {
        // 计算分钟和秒数
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        // 返回格式化的时间字符串
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 