import SwiftUI

/// 自定义滑动条视图
/// 实现了一个音乐播放器的进度控制器，具有以下特点：
/// - 自定义外观样式，包括背景线、进度线和滑块
/// - 支持拖动和点击操作
/// - 支持iPad和iPhone不同设备的适配
/// - 提供较大的点击响应区域，提升用户体验
struct CustomSlider: View {
    // MARK: - Properties
    
    /// 当前进度值，使用双向绑定
    /// 在音乐播放器中表示当前播放时间
    @Binding var value: Double
    
    /// 进度条的有效值范围
    /// 通常是 0...duration，表示从开始到结束
    let range: ClosedRange<Double>
    
    /// 判断当前设备是否为iPad
    /// 用于在不同设备上使用不同的尺寸配置
    private var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - 尺寸配置常量
    
    /// 滑动条的整体响应高度
    /// iPad: 40pt, iPhone: 20pt
    private var sliderHeight: CGFloat { isiPad ? 40 : 20 }
    
    /// 进度线的高度
    /// iPad: 6pt, iPhone: 2pt
    private var lineHeight: CGFloat { isiPad ? 6 : 2 }
    
    /// 滑块的大小
    /// iPad: 28x28pt, iPhone: 12x12pt
    private var thumbSize: CGFloat { isiPad ? 28 : 12 }
    
    /// 滑块的偏移量修正值
    /// iPad: 14pt, iPhone: 6pt
    private var thumbOffset: CGFloat { isiPad ? 14 : 6 }
    
    /// 可点击区域的高度
    /// iPad: 44pt, iPhone: 32pt
    /// 增加点击区域提升用户体验
    private var hitArea: CGFloat { isiPad ? 44 : 32 }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            sliderContent(geometry: geometry)
        }
        .frame(height: hitArea)  // 设置整体可点击区域的高度
    }
}

// MARK: - 滑动条内容布局
extension CustomSlider {
    /// 构建滑动条的主要内容视图
    /// - Parameter geometry: 父视图提供的几何信息
    /// - Returns: 组合后的滑动条视图
    private func sliderContent(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            // 透明的点击区域层
            // 扩大可点击范围，提升用户体验
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: hitArea)
                .contentShape(Rectangle())  // 确保整个区域可点击
            
            // 背景线层
            // 使用半透明白色表示未播放部分
            Rectangle()
                .frame(height: lineHeight)
                .foregroundColor(Color.white.opacity(0.2))
            
            // 进度线层
            // 使用白色表示已播放部分
            Rectangle()
                .frame(width: calculateProgressWidth(totalWidth: geometry.size.width), height: lineHeight)
                .foregroundColor(.white)
            
            // 滑块层
            // 使用圆形设计，突出当前进度位置
            Circle()
                .frame(width: thumbSize, height: thumbSize)
                .foregroundColor(.white)
                .offset(x: calculateThumbOffset(totalWidth: geometry.size.width))
        }
        .frame(height: hitArea)
        .gesture(
            // 添加拖动手势
            // 支持从任意位置开始拖动
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    updateProgress(dragLocation: gesture.location.x, totalWidth: geometry.size.width)
                }
        )
    }
}

// MARK: - Slider Components
extension CustomSlider {
    /// 计算进度条的实际宽度
    /// - Parameter totalWidth: 父视图的总宽度
    /// - Returns: 根据当前进度计算出的进度条宽度
    private func calculateProgressWidth(totalWidth: CGFloat) -> CGFloat {
        let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return totalWidth * CGFloat(progress)
    }
    
    /// 计算滑块的水平偏移量
    /// - Parameter totalWidth: 父视图的总宽度
    /// - Returns: 滑块应该偏移的距离
    private func calculateThumbOffset(totalWidth: CGFloat) -> CGFloat {
        calculateProgressWidth(totalWidth: totalWidth) - thumbOffset
    }
    
    /// 更新进度值
    /// - Parameters:
    ///   - dragLocation: 拖动位置的X坐标
    ///   - totalWidth: 父视图的总宽度
    private func updateProgress(dragLocation: CGFloat, totalWidth: CGFloat) {
        // 计算拖动位置对应的进度值
        let progress = dragLocation / totalWidth
        // 将进度值转换为实际的时间值
        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(progress)
        // 确保值在有效范围内
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview Provider
struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone预览
            CustomSlider(value: .constant(0.5), range: 0...1)
                .frame(height: 12)
                .padding()
                .background(Color.black)
                .previewDevice("iPhone 14 Pro")
            
            // iPad预览
            CustomSlider(value: .constant(0.5), range: 0...1)
                .frame(height: 40)
                .padding()
                .background(Color.black)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
} 