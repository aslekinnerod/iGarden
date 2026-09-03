//
//  GardenSharingView.swift
//  iGarden
//
//  Deling av hagen: invitasjonskoder, medlemsliste og innmelding
//  i andres hager med kode.
//

import SwiftUI

struct GardenSharingView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(GardenStore.self) private var gardenStore
    @Environment(\.dismiss) private var dismiss

    /// Kode fra en igarden://join-lenke, forhåndsutfylt.
    var prefilledCode: String = ""

    @State private var inviteCode: String?
    @State private var isCreatingInvite = false
    @State private var joinCode = ""
    @State private var isJoining = false
    @State private var errorMessage: String?
    @State private var memberToRemove: GardenMember?
    @State private var confirmLeave = false

    init(prefilledCode: String = "") {
        self.prefilledCode = prefilledCode
        _joinCode = State(initialValue: prefilledCode)
    }

    var body: some View {
        NavigationStack {
            Group {
                if authStore.hasAccount {
                    sharingContent
                } else {
                    signInPrompt
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.canvas)
            .navigationTitle("Del hagen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
            .alert(
                "Noe gikk galt",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    /// Deling krever ekte konto – mister man den anonyme kontoen,
    /// mister alle tilgang til den delte hagen.
    private var signInPrompt: some View {
        ContentUnavailableView {
            Label("Logg inn først", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("For å dele hagen eller bli med i andres må du være logget inn med Apple eller Google. Bruk konto-knappen på hovedskjermen.")
        }
    }

    private var sharingContent: some View {
        List {
            Section("Hagen") {
                LabeledContent("Navn", value: gardenStore.garden?.name ?? "")
                LabeledContent("Medlemmer", value: "\(gardenStore.members.count)")
            }

            Section("Medlemmer") {
                ForEach(gardenStore.members) { member in
                    memberRow(member)
                }
            }

            if gardenStore.isOwner {
                Section {
                    if let inviteCode {
                        VStack(alignment: .leading, spacing: DS.Spacing.s2) {
                            Text(inviteCode)
                                .font(.system(.title, design: .monospaced).bold())
                                .textSelection(.enabled)
                            Text("Gyldig i 7 dager.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ShareLink(item: shareMessage(code: inviteCode)) {
                            Label("Del invitasjonen", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Button {
                            createInvite()
                        } label: {
                            if isCreatingInvite {
                                ProgressView()
                            } else {
                                Label("Lag invitasjonskode", systemImage: "person.badge.plus")
                            }
                        }
                        .disabled(isCreatingInvite)
                    }
                } header: {
                    Text("Inviter")
                } footer: {
                    Text("Alle med koden kan bli med i hagen og se og stelle plantene.")
                }
            } else {
                Section {
                    Button("Forlat hagen", role: .destructive) {
                        confirmLeave = true
                    }
                }
            }

            Section {
                HStack {
                    TextField("Invitasjonskode", text: $joinCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onSubmit(join)
                    Button("Bli med", action: join)
                        .disabled(trimmedJoinCode.isEmpty || isJoining)
                }
            } header: {
                Text("Bli med i en annen hage")
            } footer: {
                Text("Du bytter til den delte hagen. Din egen hage blir liggende og kan ikke nås før du forlater den delte.")
            }
        }
        .confirmationDialog(
            "Fjerne \(memberToRemove?.displayName ?? String(localized: "medlemmet"))?",
            isPresented: Binding(
                get: { memberToRemove != nil },
                set: { if !$0 { memberToRemove = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Fjern", role: .destructive) {
                if let memberToRemove {
                    gardenStore.removeMember(memberToRemove)
                }
                memberToRemove = nil
            }
            Button("Avbryt", role: .cancel) { memberToRemove = nil }
        }
        .confirmationDialog(
            "Forlate hagen?",
            isPresented: $confirmLeave,
            titleVisibility: .visible
        ) {
            Button("Forlat", role: .destructive) {
                Task {
                    await gardenStore.leaveGarden()
                    dismiss()
                }
            }
            Button("Avbryt", role: .cancel) {}
        } message: {
            Text("Du mister tilgangen til plantene i denne hagen.")
        }
    }

    private func memberRow(_ member: GardenMember) -> some View {
        HStack {
            Image(systemName: member.isOwner ? "person.crop.circle.badge.checkmark" : "person.crop.circle")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(memberName(member))
                Text(member.isOwner ? "Eier" : "Medlem")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if gardenStore.isOwner, !member.isOwner {
                Button {
                    memberToRemove = member
                } label: {
                    Image(systemName: "person.crop.circle.badge.minus")
                        .foregroundStyle(Color.statusOverdue)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func memberName(_ member: GardenMember) -> String {
        if member.id == gardenStore.currentUserId {
            return String(localized: "Deg")
        }
        if let name = member.displayName, !name.isEmpty {
            return name
        }
        return String(localized: "Gartner uten navn")
    }

    private func shareMessage(code: String) -> String {
        String(localized: "Bli med i hagen min i iGarden! Åpne igarden://join?code=\(code) eller skriv inn koden \(code) under «Del hagen».")
    }

    private var trimmedJoinCode: String {
        joinCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func createInvite() {
        isCreatingInvite = true
        Task {
            defer { isCreatingInvite = false }
            do {
                inviteCode = try await gardenStore.createInvite()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func join() {
        guard !trimmedJoinCode.isEmpty else { return }
        isJoining = true
        Task {
            defer { isJoining = false }
            do {
                try await gardenStore.joinGarden(withCode: trimmedJoinCode)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    GardenSharingView()
        .environment(AuthStore())
        .environment(GardenStore())
}
