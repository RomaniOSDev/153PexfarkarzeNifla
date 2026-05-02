//
//  GridExportService.swift
//  153PexfarkarzeNifla
//

import SwiftUI
import UIKit

enum GridExportService {
    static func exportWeavePNG(
        cells: [Int],
        dimension: Int,
        palette: [Color]
    ) -> URL? {
        let view = WeaveExportView(cells: cells, dimension: dimension, palette: palette)
            .frame(width: 360, height: 360)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        guard let image = renderer.uiImage,
              let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("weave-\(UUID().uuidString.prefix(8)).png")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}

private struct WeaveExportView: View {
    let cells: [Int]
    let dimension: Int
    let palette: [Color]

    var body: some View {
        let cell = 360.0 / CGFloat(max(2, dimension))
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: dimension),
            spacing: 1
        ) {
            ForEach(0..<cells.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color(at: index))
                    .frame(width: cell - 1, height: cell - 1)
            }
        }
        .padding(8)
        .background(
            LinearGradient(
                colors: [Color.appSurface, Color.appBackground.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func color(at index: Int) -> Color {
        let value = cells[index]
        if value < 0 { return Color.appSurface.opacity(0.4) }
        return palette[max(0, min(value, palette.count - 1))]
    }
}
