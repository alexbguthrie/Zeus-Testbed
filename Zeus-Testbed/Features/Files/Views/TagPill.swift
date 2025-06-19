//
//  TagPill.swift
//  Zeus-Testbed
//
// A small, pill-shaped view to display a tag.
//

import SwiftUI

struct TagPill: View {
    let tag: Tag
    var size: Size = .regular
    private let theme = FilesTheme.current
    
    enum Size {
        case regular, small
        
        var font: Font {
            switch self {
            case .regular: return FilesTheme.current.fonts.caption
            case .small: return .system(size: 11, weight: .medium)
            }
        }
        
        var circleSize: CGFloat {
            switch self {
            case .regular: return 8
            case .small: return 6
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(hex: tag.colorHex ?? "#FFFFFF"))
                .frame(width: size.circleSize, height: size.circleSize)
            Text(tag.name)
                .font(size.font)
                .foregroundColor(theme.colors.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: tag.colorHex ?? "#FFFFFF").opacity(0.2))
        .cornerRadius(100)
    }
}

#if DEBUG
struct TagPill_Previews: PreviewProvider {
    static var previews: some View {
        let theme = FilesTheme.current
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                TagPill(tag: SampleData.tags[0], size: .regular)
                TagPill(tag: SampleData.tags[1], size: .regular)
                TagPill(tag: SampleData.tags[2], size: .regular)
            }
            HStack {
                TagPill(tag: SampleData.tags[0], size: .small)
                TagPill(tag: SampleData.tags[1], size: .small)
                TagPill(tag: SampleData.tags[2], size: .small)
            }
        }
        .padding()
        .background(theme.colors.background)
        .preferredColorScheme(.dark)
    }
}
#endif 