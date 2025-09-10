//
//  TrayView.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import SwiftUI

struct TrayView: View {
    @ObservedObject private var viewModel: TrayViewModel

    init(viewModel: TrayViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Toggle(isOn: $viewModel.isCharging) {}
            .toggleStyle(ColoredSwitchToggleStyle(onColor: .green, offColor: .gray))
            .padding(4)
    }
}
