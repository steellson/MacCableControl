//
//  ColoredSwitchToggleStyle.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import SwiftUI

struct ColoredSwitchToggleStyle: ToggleStyle {
    private var onColor: Color = .green
    private var offColor: Color = .gray

    init(onColor: Color, offColor: Color) {
        self.onColor = onColor
        self.offColor = offColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 50, height: 30)

                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .padding(4)
                    .shadow(radius: 2)
            }
            .animation(
                .easeInOut(duration: 0.2),
                value: configuration.isOn
            )
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}
