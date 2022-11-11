//
//  G7SettingsView.swift
//  CGMBLEKitUI
//
//  Created by Pete Schwamb on 9/25/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import Foundation
import SwiftUI
import CGMBLEKit

struct G7SettingsView: View {

    private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        return formatter
    }()

    @Environment(\.guidanceColors) private var guidanceColors
    @Environment(\.glucoseTintColor) private var glucoseTintColor

    var didFinish: (() -> Void)
    var deleteCGM: (() -> Void)
    @ObservedObject var viewModel: G7SettingsViewModel

    init(didFinish: @escaping () -> Void, deleteCGM: @escaping () -> Void, viewModel: G7SettingsViewModel) {
        self.didFinish = didFinish
        self.deleteCGM = deleteCGM
        self.viewModel = viewModel
    }

    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter
    }()

    var body: some View {
        List {
            Section() {
                VStack {
                    headerImage
                    progressBar
                }
            }
            if let activatedAt = viewModel.activatedAt {
                HStack {
                    Text(LocalizedString("Sensor Start", comment: "title for g7 settings row showing sensor start time"))
                    Spacer()
                    Text(timeFormatter.string(from: activatedAt))
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(LocalizedString("Sensor Expires", comment: "title for g7 settings row showing sensor expiration time"))
                    Spacer()
                    Text(timeFormatter.string(from: activatedAt.addingTimeInterval(G7Sensor.lifetime)))
                        .foregroundColor(.secondary)
                }
            }
            if let name = viewModel.sensorName {
                HStack {
                    Text(LocalizedString("Name", comment: "title for g7 settings row showing BLE Name"))
                    Spacer()
                    Text(name)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                if viewModel.scanning {
                    HStack {
                        Text(LocalizedString("Scanning", comment: "title for g7 settings connection status when scanning"))
                        Spacer()
                        ProgressView()
                    }
                } else {
                    if viewModel.connected {
                        Text(LocalizedString("Connected", comment: "title for g7 settings connection status when connected"))
                    } else {
                        HStack {
                            Text(LocalizedString("Connecting", comment: "title for g7 settings connection status when connecting"))
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                if let lastConnect = viewModel.lastConnect {
                    HStack {
                        Text(LocalizedString("Last Connect", comment: "title for g7 settings row showing sensor last connect time"))
                        Spacer()
                        Text(timeFormatter.string(from: lastConnect))
                    }
                }
            }

            Section () {
                if !self.viewModel.scanning {
                    Button("Scan for new sensor", action: {
                        self.viewModel.scanForNewSensor()
                    })
                }

                Button("Delete CGM", action: {
                    self.deleteCGM()
                })
            }
        }
        .insetGroupedListStyle()
        .navigationBarItems(trailing: doneButton)
        .navigationBarTitle(LocalizedString("Dexcom G7", comment: "Navigation bar title for G7SettingsView"))
    }

    var headerImage: some View {
        VStack(alignment: .center) {
            Image(frameworkImage: "g7")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(height: 150)
                .padding(.horizontal)
        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.progressBarState.label)
                    .font(.system(size: 17))
                    .foregroundColor(color(for: viewModel.progressBarState.labelColor))

                Spacer()
                if let duration = viewModel.progressValue {
                    Text(durationFormatter.string(from: duration)!)
                        .foregroundColor(.secondary)
                }
            }
            ProgressView(value: viewModel.progressBarProgress)
                .accentColor(color(for: viewModel.progressBarColorStyle))
        }
    }

    private func color(for colorStyle: ColorStyle) -> Color {
        switch colorStyle {
        case .glucose:
            return glucoseTintColor
        case .warning:
            return guidanceColors.warning
        case .critical:
            return guidanceColors.critical
        case .normal:
            return .primary
        case .dimmed:
            return .secondary
        }
    }


    private var doneButton: some View {
        Button("Done", action: {
            self.didFinish()
        })
    }

}
