//
//  PrivacySettingsViewController.swift
//  TelegramMac
//
//  Created by keepcoder on 10/01/2017.
//  Copyright © 2017 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import TelegramCoreMac
import SwiftSignalKitMac
import PostboxMac

private final class PrivacyAndSecurityControllerArguments {
    let account: Account
    let openBlockedUsers: () -> Void
    let openLastSeenPrivacy: () -> Void
    let openGroupsPrivacy: () -> Void
    let openVoiceCallPrivacy: () -> Void
    let openPasscode: () -> Void
    let openTwoStepVerification: () -> Void
    let openActiveSessions: () -> Void
    let setupAccountAutoremove: () -> Void
    let openProxySettings:() ->Void
    init(account: Account, openBlockedUsers: @escaping () -> Void, openLastSeenPrivacy: @escaping () -> Void, openGroupsPrivacy: @escaping () -> Void, openVoiceCallPrivacy: @escaping () -> Void, openPasscode: @escaping () -> Void, openTwoStepVerification: @escaping () -> Void, openActiveSessions: @escaping () -> Void, setupAccountAutoremove: @escaping () -> Void, openProxySettings:@escaping() ->Void) {
        self.account = account
        self.openBlockedUsers = openBlockedUsers
        self.openLastSeenPrivacy = openLastSeenPrivacy
        self.openGroupsPrivacy = openGroupsPrivacy
        self.openVoiceCallPrivacy = openVoiceCallPrivacy
        self.openPasscode = openPasscode
        self.openTwoStepVerification = openTwoStepVerification
        self.openActiveSessions = openActiveSessions
        self.setupAccountAutoremove = setupAccountAutoremove
        self.openProxySettings = openProxySettings
    }
}


private enum PrivacyAndSecurityEntry: Comparable, Identifiable {
    case privacyHeader(sectionId:Int)
    case blockedPeers(sectionId:Int)
    case lastSeenPrivacy(sectionId: Int, String)
    case groupPrivacy(sectionId: Int, String)
    case voiceCallPrivacy(sectionId: Int, String)
    case securityHeader(sectionId:Int)
    case passcode(sectionId:Int)
    case twoStepVerification(sectionId:Int)
    case activeSessions(sectionId:Int)
    case accountHeader(sectionId:Int)
    case accountTimeout(sectionId: Int, String)
    case accountInfo(sectionId:Int)
    case proxyHeader(sectionId:Int)
    case proxySettings(sectionId:Int, String)
    case section(sectionId:Int)
    
    var sectionId: Int {
        switch self {
        case let .privacyHeader(sectionId):
            return sectionId
        case let .blockedPeers(sectionId):
            return sectionId
        case let .lastSeenPrivacy(sectionId, _):
            return sectionId
        case let .groupPrivacy(sectionId, _):
            return sectionId
        case let .voiceCallPrivacy(sectionId, _):
            return sectionId
        case let .securityHeader(sectionId):
            return sectionId
        case let .passcode(sectionId):
            return sectionId
        case let .twoStepVerification(sectionId):
            return sectionId
        case let .activeSessions(sectionId):
            return sectionId
        case let .accountHeader(sectionId):
            return sectionId
        case let .accountTimeout(sectionId, _):
            return sectionId
        case let .accountInfo(sectionId):
            return sectionId
        case let .proxySettings(sectionId, _):
            return sectionId
        case let .proxyHeader(sectionId):
            return sectionId
        case let .section(sectionId):
            return sectionId
        }
    }
    
    var stableId:Int {
        switch self {
        case .privacyHeader:
            return 0
        case .blockedPeers:
            return 1
        case .lastSeenPrivacy:
            return 2
        case .groupPrivacy:
            return 3
        case .voiceCallPrivacy:
            return 4
        case .securityHeader:
            return 5
        case .passcode:
            return 6
        case .twoStepVerification:
            return 7
        case .activeSessions:
            return 8
        case .accountHeader:
            return 9
        case .accountTimeout:
            return 10
        case .accountInfo:
            return 11
        case .proxyHeader:
            return 12
        case .proxySettings:
            return 13
        case let .section(sectionId):
            return (sectionId + 1) * 1000 - sectionId
        }
    }
    
    
    private var stableIndex:Int {
        switch self {
        case let .section(sectionId):
            return (sectionId + 1) * 1000 - sectionId
        default:
            return (sectionId * 1000) + stableId
        }

    }
    
    static func ==(lhs: PrivacyAndSecurityEntry, rhs: PrivacyAndSecurityEntry) -> Bool {
        switch lhs {
        case .privacyHeader, .blockedPeers, .securityHeader, .passcode, .twoStepVerification, .activeSessions, .accountHeader, .accountInfo, .proxyHeader, .section:
            return lhs.stableId == rhs.stableId && lhs.sectionId == rhs.sectionId
        case let .lastSeenPrivacy(sectionId, text):
            if case .lastSeenPrivacy(sectionId, text) = rhs {
                return true
            } else {
                return false
            }
        case let .groupPrivacy(sectionId, text):
            if case .groupPrivacy(sectionId, text) = rhs {
                return true
            } else {
                return false
            }
        case let .proxySettings(sectionId, text):
            if case .proxySettings(sectionId, text) = rhs {
                return true
            } else {
                return false
            }
        case let .voiceCallPrivacy(sectionId, text):
            if case .voiceCallPrivacy(sectionId, text) = rhs {
                return true
            } else {
                return false
            }
        case let .accountTimeout(sectionId, text):
            if case .accountTimeout(sectionId, text) = rhs {
                return true
            } else {
                return false
            }
        }
    }
    
    static func <(lhs: PrivacyAndSecurityEntry, rhs: PrivacyAndSecurityEntry) -> Bool {
        return lhs.stableIndex < rhs.stableIndex
    }
    func item(_ arguments: PrivacyAndSecurityControllerArguments, initialSize: NSSize) -> TableRowItem {
        switch self {
        case .privacyHeader:
            return GeneralTextRowItem(initialSize, stableId: stableId, text: tr(.privacySettingsPrivacyHeader), drawCustomSeparator: true, inset: NSEdgeInsets(left: 30.0, right: 30.0, top:2, bottom:6))
        case .blockedPeers:
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsBlockedUsers), type: .next, action: {
                arguments.openBlockedUsers()
            })
        case let .lastSeenPrivacy(_, text):
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsLastSeen), type: .next, action: {
                arguments.openLastSeenPrivacy()
            })
        case let .groupPrivacy(_, text):
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsGroups), type: .next, action: {
                arguments.openGroupsPrivacy()
            })
        case let .voiceCallPrivacy(_, text):
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsVoiceCalls), type: .next, action: {
                arguments.openVoiceCallPrivacy()
            })
        case .securityHeader:
            return GeneralTextRowItem(initialSize, stableId: stableId, text: tr(.privacySettingsSecurityHeader), drawCustomSeparator: true, inset: NSEdgeInsets(left: 30.0, right: 30.0, top:2, bottom:6))
        case .passcode:
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsPasscode), action: {
                arguments.openPasscode()
            })
        case .twoStepVerification:
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsTwoStepVerification), action: {
                arguments.openVoiceCallPrivacy()
            })
        case .activeSessions:
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsActiveSessions), action: {
                arguments.openActiveSessions()
            })
        case .accountHeader:
            return GeneralTextRowItem(initialSize, stableId: stableId, text: "tr(.privacySettingsDeleteAccountHeader)", drawCustomSeparator: true, inset: NSEdgeInsets(left: 30.0, right: 30.0, top:2, bottom:6))
        case let .accountTimeout(_, text):
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: "tr(.privacySettingsDeleteAccount)", action: {
                arguments.setupAccountAutoremove()
            })
        case .accountInfo:
            return GeneralTextRowItem(initialSize, stableId: stableId, text: "tr(.privacySettingsDeleteAccountDescription)")
        case .proxyHeader:
            return GeneralTextRowItem(initialSize, stableId: stableId, text: tr(.privacySettingsProxyHeader), drawCustomSeparator: true, inset: NSEdgeInsets(left: 30.0, right: 30.0, top:2, bottom:6))
        case let .proxySettings(_, text):
            return GeneralInteractedRowItem(initialSize, stableId: stableId, name: tr(.privacySettingsUseProxy), type: .context(stateback: { () -> String in
                return text
            }), action: {
                arguments.openProxySettings()
            })
        case .section :
            return GeneralRowItem(initialSize, height:20, stableId: stableId)
        }
    }
}

private struct PrivacyAndSecurityControllerState: Equatable {
    init() {
    }
    
    static func ==(lhs: PrivacyAndSecurityControllerState, rhs: PrivacyAndSecurityControllerState) -> Bool {
        return true
    }
}

fileprivate func prepareTransition(left:[AppearanceWrapperEntry<PrivacyAndSecurityEntry>], right: [AppearanceWrapperEntry<PrivacyAndSecurityEntry>], initialSize:NSSize, arguments:PrivacyAndSecurityControllerArguments) -> TableUpdateTransition {
    
    let (removed, inserted, updated) = proccessEntriesWithoutReverse(left, right: right) { entry -> TableRowItem in
        return entry.entry.item(arguments, initialSize: initialSize)
    }
    
    return TableUpdateTransition(deleted: removed, inserted: inserted, updated: updated, animated: true)
}

private func privacyAndSecurityControllerEntries(state: PrivacyAndSecurityControllerState, privacySettings: AccountPrivacySettings?, proxy: ProxySettings?) -> [PrivacyAndSecurityEntry] {
    var entries: [PrivacyAndSecurityEntry] = []
    
    var sectionId:Int = 1
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    
    entries.append(.privacyHeader(sectionId: sectionId))
    entries.append(.blockedPeers(sectionId: sectionId))
    entries.append(.lastSeenPrivacy(sectionId: sectionId, ""))
    entries.append(.groupPrivacy(sectionId: sectionId, ""))
    entries.append(.voiceCallPrivacy(sectionId: sectionId, ""))
    
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    
    entries.append(.securityHeader(sectionId: sectionId))
    entries.append(.passcode(sectionId: sectionId))
   // entries.append(.twoStepVerification(sectionId: sectionId))
    entries.append(.activeSessions(sectionId: sectionId))
    
    entries.append(.section(sectionId: sectionId))
    sectionId += 1
    
    entries.append(.proxyHeader(sectionId: sectionId))
    entries.append(.proxySettings(sectionId: sectionId, proxy != nil ? tr(.proxySettingsSocks5) : tr(.proxySettingsDisabled)))
    
//    entries.append(.section(sectionId: sectionId))
//    sectionId += 1
//
//    entries.append(.accountHeader(sectionId: sectionId))
//    entries.append(.accountTimeout(sectionId: sectionId, ""))
//    entries.append(.accountInfo(sectionId: sectionId))
    
    return entries
}


class PrivacyAndSecurityViewController: TableViewController {
    private let initialSettings: Signal<AccountPrivacySettings?, NoError>
    
//    override var removeAfterDisapper: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let statePromise = ValuePromise(PrivacyAndSecurityControllerState(), ignoreRepeated: true)
        let stateValue = Atomic(value: PrivacyAndSecurityControllerState())
        let updateState: ((PrivacyAndSecurityControllerState) -> PrivacyAndSecurityControllerState) -> Void = { f in
            statePromise.set(stateValue.modify { f($0) })
        }
        
        let actionsDisposable = DisposableSet()
        let account = self.account
        
        let pushControllerImpl: ((ViewController) -> Void) = { [weak self] c in
            self?.navigationController?.push(c)
        }

        let currentInfoDisposable = MetaDisposable()
        actionsDisposable.add(currentInfoDisposable)
        
        let privacySettingsPromise = Promise<AccountPrivacySettings?>()
        privacySettingsPromise.set(initialSettings)
        
        let arguments = PrivacyAndSecurityControllerArguments(account: account, openBlockedUsers: { [weak self] in
            if let account = self?.account {
                pushControllerImpl(BlockedPeersViewController(account))
            }
        }, openLastSeenPrivacy: {
            let signal = privacySettingsPromise.get()
                |> take(1)
                |> deliverOnMainQueue
            currentInfoDisposable.set(signal.start(next: { [weak currentInfoDisposable] info in
                if let info = info {
                    pushControllerImpl(SelectivePrivacySettingsController(account: account, kind: .presence, current: info.presence, updated: { updated in
                        if let currentInfoDisposable = currentInfoDisposable {
                            let applySetting: Signal<Void, NoError> = privacySettingsPromise.get()
                                |> filter { $0 != nil }
                                |> take(1)
                                |> deliverOnMainQueue
                                |> mapToSignal { value -> Signal<Void, NoError> in
                                    if let value = value {
                                        privacySettingsPromise.set(.single(AccountPrivacySettings(presence: updated, groupInvitations: value.groupInvitations, voiceCalls: value.voiceCalls, accountRemovalTimeout: value.accountRemovalTimeout)))
                                    }
                                    return .complete()
                            }
                            currentInfoDisposable.set(applySetting.start())
                        }
                    }))
                }
            }))
        }, openGroupsPrivacy: {
            let signal = privacySettingsPromise.get()
                |> take(1)
                |> deliverOnMainQueue
            currentInfoDisposable.set(signal.start(next: { [weak currentInfoDisposable] info in
                if let info = info {
                    pushControllerImpl(SelectivePrivacySettingsController(account: account, kind: .groupInvitations, current: info.groupInvitations, updated: { updated in
                        if let currentInfoDisposable = currentInfoDisposable {
                            let applySetting: Signal<Void, NoError> = privacySettingsPromise.get()
                                |> filter { $0 != nil }
                                |> take(1)
                                |> deliverOnMainQueue
                                |> mapToSignal { value -> Signal<Void, NoError> in
                                    if let value = value {
                                        privacySettingsPromise.set(.single(AccountPrivacySettings(presence: value.presence, groupInvitations: updated, voiceCalls: value.voiceCalls, accountRemovalTimeout: value.accountRemovalTimeout)))
                                    }
                                    return .complete()
                            }
                            currentInfoDisposable.set(applySetting.start())
                        }
                    }))
                }
            }))
        }, openVoiceCallPrivacy: {
            let signal = privacySettingsPromise.get()
                |> take(1)
                |> deliverOnMainQueue
            currentInfoDisposable.set(signal.start(next: { [weak currentInfoDisposable] info in
                if let info = info {
                    pushControllerImpl(SelectivePrivacySettingsController(account: account, kind: .voiceCalls, current: info.voiceCalls, updated: { updated in
                        if let currentInfoDisposable = currentInfoDisposable {
                            let applySetting: Signal<Void, NoError> = privacySettingsPromise.get()
                                |> filter { $0 != nil }
                                |> take(1)
                                |> deliverOnMainQueue
                                |> mapToSignal { value -> Signal<Void, NoError> in
                                    if let value = value {
                                        privacySettingsPromise.set(.single(AccountPrivacySettings(presence: value.presence, groupInvitations: value.groupInvitations, voiceCalls: updated, accountRemovalTimeout: value.accountRemovalTimeout)))
                                    }
                                    return .complete()
                            }
                            currentInfoDisposable.set(applySetting.start())
                        }
                    }))
                }
            }))
        }, openPasscode: { [weak self] in
            if let account = self?.account {
                self?.navigationController?.push(PasscodeSettingsViewController(account))
            }
        }, openTwoStepVerification: {
            
        }, openActiveSessions: { [weak self] in
            if let account = self?.account {
                self?.navigationController?.push(RecentSessionsController(account))
            }
        }, setupAccountAutoremove: {
            
        }, openProxySettings: { [weak self] in
            if let account = self?.account {
                self?.navigationController?.push(ProxySettingsViewController(account))
            }
        })
        
        
        let previous:Atomic<[AppearanceWrapperEntry<PrivacyAndSecurityEntry>]> = Atomic(value: [])
        let initialSize = self.atomicSize
        let privacySettings: Signal<AccountPrivacySettings?, NoError> = .single(nil) |> then(requestAccountPrivacySettings(account: account) |> map { Optional($0) })
        |> deliverOnMainQueue
        
        let proxySettings:Signal<ProxySettings?, Void> = account.postbox.preferencesView(keys: [PreferencesKeys.proxySettings]) |> map { view in
            return view.values[PreferencesKeys.proxySettings] as? ProxySettings
        } |> deliverOnMainQueue
        
        genericView.merge(with: combineLatest(statePromise.get() |> deliverOnMainQueue, privacySettings |> deliverOnMainQueue, appearanceSignal, proxySettings)
            |> map { state, privacySettings, appearance, proxy -> TableUpdateTransition in
                let entries = privacyAndSecurityControllerEntries(state: state, privacySettings: privacySettings, proxy: proxy).map{AppearanceWrapperEntry(entry: $0, appearance: appearance)}
                return prepareTransition(left: previous.swap(entries), right: entries, initialSize: initialSize.modify {$0}, arguments: arguments)
            } |> afterDisposed {
                actionsDisposable.dispose()
        })
        
        
        readyOnce()
    }
    
    init(_ account:Account, initialSettings: Signal<AccountPrivacySettings?, NoError>) {
        self.initialSettings = initialSettings
        super.init(account)
    }
}
