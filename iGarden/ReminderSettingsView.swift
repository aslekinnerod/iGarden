//
//  ReminderSettingsView.swift
//  iGarden
//

import SwiftUI

/// Innstillinger for vanningsvarsler: av/på og tidspunkt på dagen.
struct ReminderSettingsView: View {
    @Environment(GardenStore.self) private var gardenStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage(NotificationSettings.enabledKey) private var remindersEnabled = true
    @AppStorage(NotificationSettings.minutesKey) private var reminderMinutes = 9 * 60

    private var reminderTime: Binding<Date> {
        Binding {
            Calendar.current.date(
                bySettingHour: reminderMinutes / 60,
                minute: reminderMinutes % 60,
                second: 0,
                of: .now
            ) ?? .now
        } set: { newValue in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderMinutes = (components.hour ?? 9) * 60 + (components.minute ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Vanningspåminnelser", isOn: $remindersEnabled)
                    if remindersEnabled {
                        DatePicker("Tidspunkt", selection: reminderTime, displayedComponents: .hourAndMinute)
                    }
                } footer: {
                    Text("Du får ett varsel per plante den dagen den skal vannes.")
                }
            }
            .navigationTitle("Varsler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
            .onChange(of: remindersEnabled) { NotificationManager.rescheduleAll(gardenStore.plants) }
            .onChange(of: reminderMinutes) { NotificationManager.rescheduleAll(gardenStore.plants) }
        }
    }
}

#Preview {
    ReminderSettingsView()
        .environment(GardenStore())
}
